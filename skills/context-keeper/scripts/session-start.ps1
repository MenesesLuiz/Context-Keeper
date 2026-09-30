# Claude Code SessionStart hook, Windows version of session-start.sh (same behavior).
#   - Every time: brings the map in the root file up to date; prints it only if it changed.
#   - Only after a compaction: prints the now file and the latest journal entry.
# With no brain configured it prints nothing.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File session-start.ps1 [brain-folder]
# Must stay saved as UTF-8 with BOM (Windows PowerShell 5.1).

. (Join-Path $PSScriptRoot 'lib.ps1')
$Brain = CK-ResolveBrain ([string]($args | Select-Object -First 1))
if (-not $Brain) { exit 0 }
$N = CK-LoadNames $Brain
$maxChars = if ($env:CONTEXT_KEEPER_MAX_BYTES) { [int]$env:CONTEXT_KEEPER_MAX_BYTES } else { 8000 }

$source = ''
try {
  $raw = [Console]::In.ReadToEnd()
  if ($raw) { $source = [string]($raw | ConvertFrom-Json).source }
} catch { }

$mapReport = (& (Join-Path $PSScriptRoot 'update-map.ps1') $Brain 2>$null | Out-String)
$out = New-Object System.Text.StringBuilder

if ($mapReport -match 'map: updated') {
  [void]$out.AppendLine((CK-Msg $N.Lang 'title' $Brain))
  [void]$out.AppendLine((CK-Msg $N.Lang 'map' $N.Root))
  $text = CK-ReadText (Join-Path $Brain $N.Root)
  $m = [regex]::Match($text, '<!-- context-keeper:map:start -->\n([\s\S]*?)\n<!-- context-keeper:map:end -->')
  if ($m.Success) { [void]$out.AppendLine($m.Groups[1].Value) }
  $missing = [regex]::Match($mapReport, 'map: without description:(.*)')
  if ($missing.Success) { [void]$out.AppendLine((CK-Msg $N.Lang 'nodesc' $missing.Groups[1].Value.TrimEnd())) }
  [void]$out.AppendLine('')
}

if ($source -eq 'compact') {
  if ($mapReport -notmatch 'map: updated') { [void]$out.AppendLine((CK-Msg $N.Lang 'title' $Brain)) }
  if ($N.Now) { [void]$out.AppendLine((CK-Msg $N.Lang 'compacted' $N.Now)) }
  if ($N.Root) { [void]$out.AppendLine((CK-Msg $N.Lang 'rules' (Join-Path $Brain $N.Root))) }
  [void]$out.AppendLine('')
  if ($N.Now) {
    [void]$out.AppendLine("## $($N.Now)")
    [void]$out.AppendLine((CK-ReadText (Join-Path $Brain $N.Now)))
  }
  if ($N.Journal) {
    $latest = Get-ChildItem -LiteralPath (Join-Path $Brain $N.Journal) -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}\.md$' } | Sort-Object Name | Select-Object -Last 1
    if ($latest) {
      [void]$out.AppendLine((CK-Msg $N.Lang 'journal' "$($N.Journal)/$($latest.Name)"))
      $lines = (CK-ReadText $latest.FullName) -split "`n"
      [void]$out.AppendLine((($lines | Select-Object -Last 25) -join "`n"))
    }
  }
}

$result = $out.ToString()
if ($result.Length -gt $maxChars) { $result = $result.Substring(0, $maxChars) }
if ($result) { [Console]::Out.Write($result) }
exit 0
