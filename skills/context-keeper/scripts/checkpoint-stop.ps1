# Claude Code Stop hook, Windows version of checkpoint-stop.sh (same behavior): asks for a
# checkpoint when the context has grown by CONTEXT_KEEPER_CHECKPOINT_TOKENS (default 50000)
# since the last one, measured from the last "usage" block in the transcript.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File checkpoint-stop.ps1 [brain-folder]
# Must stay saved as UTF-8 with BOM (Windows PowerShell 5.1).

. (Join-Path $PSScriptRoot 'lib.ps1')
$Brain = CK-ResolveBrain ([string]($args | Select-Object -First 1))
if (-not $Brain) { exit 0 }
$N = CK-LoadNames $Brain
$limit = if ($env:CONTEXT_KEEPER_CHECKPOINT_TOKENS) { [long]$env:CONTEXT_KEEPER_CHECKPOINT_TOKENS } else { 50000 }

try { $hook = [Console]::In.ReadToEnd() | ConvertFrom-Json } catch { exit 0 }
if (-not $hook) { exit 0 }
# The AI is already continuing because of a Stop hook: let it stop.
if ($hook.stop_hook_active -eq $true) { exit 0 }

$session = ([string]$hook.session_id) -replace '[^A-Za-z0-9_-]', ''
$transcript = [string]$hook.transcript_path
if (-not $session -or -not $transcript -or -not (Test-Path -LiteralPath $transcript -PathType Leaf)) { exit 0 }

# Context size in tokens from the last "usage" block; fallback: ~30 transcript bytes per token.
$fs = [System.IO.File]::Open($transcript, 'Open', 'Read', 'ReadWrite')
try {
  $len = $fs.Length
  $take = [Math]::Min($len, 400000)
  [void]$fs.Seek($len - $take, 'Begin')
  $buf = New-Object byte[] $take
  [void]$fs.Read($buf, 0, $take)
} finally { $fs.Close() }
$tail = [System.Text.Encoding]::UTF8.GetString($buf)
$usages = [regex]::Matches($tail, '"usage":\{[^}]*\}')
if ($usages.Count -gt 0) {
  $u = $usages[$usages.Count - 1].Value
  $size = [long]0
  foreach ($k in @('input_tokens', 'cache_read_input_tokens', 'cache_creation_input_tokens')) {
    $m = [regex]::Match($u, '"' + $k + '":(\d+)')
    if ($m.Success) { $size += [long]$m.Groups[1].Value }
  }
} else {
  $size = [long]([Math]::Floor($len / 30))
}

$stateDir = Join-Path $Brain '.context-keeper\state'
if (-not (Test-Path -LiteralPath $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
$baselineFile = Join-Path $stateDir "$session.checkpoint"
$nowPath = if ($N.Now) { Join-Path $Brain $N.Now } else { '' }

function Save-Baseline([long]$Value) {
  [System.IO.File]::WriteAllText($baselineFile, "$Value`n", (New-Object System.Text.UTF8Encoding($false)))
}

# First stop of the session, or a checkpoint happened since last time: only record the baseline.
if (-not (Test-Path -LiteralPath $baselineFile) -or
    ($nowPath -and (Test-Path -LiteralPath $nowPath) -and
     (Get-Item -LiteralPath $nowPath).LastWriteTime -gt (Get-Item -LiteralPath $baselineFile).LastWriteTime)) {
  Save-Baseline $size
  exit 0
}

$baselineText = (Get-Content -LiteralPath $baselineFile -Raw) -replace '[^0-9]', ''
$baseline = if ($baselineText) { [long]$baselineText } else { [long]0 }

# The context shrank (compaction or /clear): follow it down.
if ($size -lt $baseline) { Save-Baseline $size; exit 0 }

if (($size - $baseline) -ge $limit) {
  Save-Baseline $size
  $rootPath = (Join-Path $Brain $(if ($N.Root) { $N.Root } else { 'CLAUDE.md' })) -replace '\\', '/'
  $payload = @{ hookSpecificOutput = @{ hookEventName = 'Stop'; additionalContext = (CK-Msg $N.Lang 'checkpoint' $rootPath) } }
  [Console]::Out.Write(($payload | ConvertTo-Json -Compress -Depth 3) + "`n")
}

# Clean up state from old sessions.
Get-ChildItem -LiteralPath $stateDir -Filter '*.checkpoint' -ErrorAction SilentlyContinue |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force -ErrorAction SilentlyContinue
exit 0
