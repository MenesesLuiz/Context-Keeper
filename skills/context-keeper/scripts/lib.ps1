# Shared helpers for the context-keeper PowerShell scripts (Windows). Same behavior as lib.sh.
# Load with: . (Join-Path $PSScriptRoot 'lib.ps1')
#
# Written for Windows PowerShell 5.1, which ships with every Windows. This file must stay saved
# as UTF-8 with BOM, or PowerShell 5.1 reads the accented messages below as another encoding.
#
# Where the brain is, in order of priority:
#   1. the argument passed to the script;
#   2. the CONTEXT_KEEPER_BRAIN variable;
#   3. the "brain_path=..." line in ~/.context-keeper/config (written by the skill at setup).
# Tests can point "~" elsewhere with the CONTEXT_KEEPER_HOME variable.

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
[Console]::InputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = New-Object System.Text.UTF8Encoding($false)

function CK-Home {
  if ($env:CONTEXT_KEEPER_HOME) { return $env:CONTEXT_KEEPER_HOME }
  return [Environment]::GetFolderPath('UserProfile')
}

function CK-ResolveBrain([string]$Arg) {
  $b = $Arg
  if (-not $b) { $b = $env:CONTEXT_KEEPER_BRAIN }
  if (-not $b) {
    $cfg = Join-Path (CK-Home) '.context-keeper\config'
    if (Test-Path -LiteralPath $cfg) {
      $line = Get-Content -LiteralPath $cfg -Encoding UTF8 | Where-Object { $_ -match '^brain_path=' } | Select-Object -First 1
      if ($line) { $b = $line.Substring('brain_path='.Length).Trim() }
    }
  }
  if ($b -and (Test-Path -LiteralPath $b -PathType Container)) { return $b }
  return $null
}

# First name in the list that exists in the brain, as it is really written on disk.
function CK-FirstExisting([string]$Brain, [string]$Kind, [string[]]$Names) {
  $items = if ($Kind -eq 'dir') { Get-ChildItem -LiteralPath $Brain -Directory -Force } else { Get-ChildItem -LiteralPath $Brain -File -Force }
  foreach ($n in $Names) {
    $hit = $items | Where-Object { $_.Name -ieq $n } | Select-Object -First 1
    if ($hit) { return $hit.Name }
  }
  return ''
}

# Reads file names and language from .context-keeper/config.json, with the same fallbacks as lib.sh.
function CK-LoadNames([string]$Brain) {
  $n = @{ Root = ''; Now = ''; Journal = ''; Lang = '' }
  $cfgPath = Join-Path $Brain '.context-keeper\config.json'
  if (Test-Path -LiteralPath $cfgPath) {
    try {
      $cfg = Get-Content -LiteralPath $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
      if ($cfg.files) { $n.Root = [string]$cfg.files.root; $n.Now = [string]$cfg.files.now; $n.Journal = [string]$cfg.files.journal }
      if ($cfg.language) { $n.Lang = [string]$cfg.language }
    } catch { }
  }
  if (-not $n.Root)    { $n.Root    = CK-FirstExisting $Brain 'file' @('CLAUDE.md', 'BRAIN.md', 'CEREBRO.md', 'AGENTS.md') }
  if (-not $n.Now)     { $n.Now     = CK-FirstExisting $Brain 'file' @('NOW.md', 'AGORA.md') }
  if (-not $n.Journal) { $n.Journal = CK-FirstExisting $Brain 'dir'  @('Journal', 'Diario') }
  if (-not $n.Lang) {
    $n.Lang = 'en'
    if ("$($n.Now)$($n.Root)$($n.Journal)" -match 'AGORA|CEREBRO|Diario') { $n.Lang = 'pt-BR' }
    elseif ($n.Root) {
      $rootPath = Join-Path $Brain $n.Root
      if ((Test-Path -LiteralPath $rootPath) -and
          (Select-String -LiteralPath $rootPath -Pattern '(^|[^a-z])(você|não|pasta|projetos|sessão)([^a-z]|$)' -Encoding UTF8 -Quiet)) {
        $n.Lang = 'pt-BR'
      }
    }
  }
  return $n
}

# Hook messages in the brain's language: CK-Msg <lang> <key> [value for {0}]
function CK-Msg([string]$Lang, [string]$Key, [string]$Value = '') {
  $pt = @{
    title      = '# Segundo cérebro ({0})'
    compacted  = 'O contexto desta sessão acabou de ser compactado. Retome pelo {0} abaixo e, se precisar de detalhes, pelo índice do assunto. Se o trabalho feito antes da compactação ainda não estiver registrado, faça um checkpoint.'
    rules      = 'Regras e protocolo de alimentação: {0}'
    journal    = '## Última entrada do diário ({0})'
    map        = 'O mapa do cérebro (seção Atual do {0}) foi atualizado com as pastas reais. Use-o para localizar áreas e projetos:'
    nodesc     = 'Pastas sem descrição no mapa:{0}. Quando o assunto surgir, proponha ao usuário uma descrição de uma linha (campo descricao: no Indice.md da pasta).'
    checkpoint = 'Checkpoint do segundo cérebro: esta conversa cresceu bastante desde o último registro. Antes de encerrar, faça um checkpoint seguindo o protocolo de alimentação de {0} (decisões, Estado atual dos assuntos tocados, arquivo de estado atual, preferências e uma entrada no diário). Se nada relevante aconteceu desde o último checkpoint, diga isso em uma linha e encerre.'
  }
  $en = @{
    title      = '# Second brain ({0})'
    compacted  = "This session's context was just compacted. Resume from {0} below and, for details, from the subject's index note. If the work done before the compaction is not recorded yet, run a checkpoint."
    rules      = 'Rules and feeding protocol: {0}'
    journal    = '## Latest journal entry ({0})'
    map        = "The brain's map (the current map section of {0}) was updated from the real folders. Use it to find areas and projects:"
    nodesc     = 'Folders without a description in the map:{0}. When the subject comes up, propose a one-line description to the user (description: field in the folder index note).'
    checkpoint = 'Second brain checkpoint: this conversation has grown a lot since the last save. Before finishing, run a checkpoint following the feeding protocol in {0} (decisions, current state of the subjects touched, the current-state file, preferences and a journal entry). If nothing relevant happened since the last checkpoint, say so in one line and stop.'
  }
  $table = if ($Lang -like 'pt*') { $pt } else { $en }
  return ($table[$Key] -f $Value)
}

# Reads a text file as UTF-8 and returns it without carriage returns.
function CK-ReadText([string]$Path) {
  return ([System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)) -replace "`r", ''
}
