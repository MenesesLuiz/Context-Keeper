# Rebuilds the map section of the brain's root file (CLAUDE.md) from the real folders.
# Windows version of update-map.sh, with the same behavior and output. See update-map.sh for details.
#
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File update-map.ps1 [brain-folder] [-Check]
#   (no flag)  rewrites only the part between the map markers and reports what changed
#   -Check     changes nothing; exits 1 if the map is outdated or the markers are missing
#
# Must stay saved as UTF-8 with BOM (Windows PowerShell 5.1).

$brainArg = ''; $check = $false
foreach ($a in $args) { if ($a -eq '-Check' -or $a -eq '--check') { $check = $true } else { $brainArg = [string]$a } }

. (Join-Path $PSScriptRoot 'lib.ps1')
$Brain = CK-ResolveBrain $brainArg
if (-not $Brain) { [Console]::Error.WriteLine('map: no brain found'); exit 2 }
$N = CK-LoadNames $Brain
if (-not $N.Root) { [Console]::Error.WriteLine("map: no root file (CLAUDE.md) in $Brain"); exit 2 }
$rootPath = Join-Path $Brain $N.Root
$START = '<!-- context-keeper:map:start -->'
$END = '<!-- context-keeper:map:end -->'
$pt = $N.Lang -like 'pt*'

function Builtin-Desc([string]$Name) {
  if ($Name -ieq $N.Root) { if ($pt) { return 'este arquivo: regras, navegação e mapa' } else { return 'this file: rules, navigation and map' } }
  switch -Regex ($Name) {
    '^(AGORA|NOW)\.md$'            { if ($pt) { return 'estado atual: foco e pendências (lido sob demanda)' } else { return 'current state: focus and open items (read on demand)' } }
    '^AGENTS\.md$'                 { if ($pt) { return "aponta outras IAs para o $($N.Root)" } else { return "points other AIs to $($N.Root)" } }
    '^(Perfil|Profile)$'           { if ($pt) { return 'quem é o usuário e como gosta que a IA trabalhe' } else { return 'who the user is and how they like the AI to work' } }
    '^(Diario|Journal)$'           { if ($pt) { return 'uma entrada por sessão relevante (AAAA-MM-DD.md)' } else { return 'one entry per relevant session (YYYY-MM-DD.md)' } }
    '^Inbox$'                      { if ($pt) { return 'capturas rápidas ainda não classificadas' } else { return 'quick captures not yet sorted' } }
    '^Templates$'                  { if ($pt) { return 'modelos de nota' } else { return 'note templates' } }
    '^(4-)?(Arquivo|Archive)$'     { if ($pt) { return 'o que foi concluído ou abandonado' } else { return 'finished or abandoned work' } }
    '^(1-)?(Projetos|Projects)$'   { if ($pt) { return 'uma pasta por projeto' } else { return 'one folder per project' } }
    '^(Pesquisa|Research)$'        { if ($pt) { return 'estudos úteis para mais de um projeto' } else { return 'research useful to more than one project' } }
  }
  return ''
}

function No-Desc { if ($pt) { '(sem descrição)' } else { '(no description)' } }

# Description of a folder: its index note's frontmatter, else built-in, else empty.
function Folder-Desc([string]$Rel, [string]$Name) {
  foreach ($idx in @('Indice.md', 'Index.md', 'README.md')) {
    $f = Join-Path (Join-Path $Brain $Rel) $idx
    if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { continue }
    $lines = (CK-ReadText $f) -split "`n"
    if ($lines.Count -lt 2 -or $lines[0] -ne '---') { continue }
    for ($i = 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -eq '---') { break }
      if ($lines[$i] -match '^(descricao|description):\s*(.*)$') {
        $d = $Matches[2].Trim().Trim('"').Trim("'")
        # A template copied into the folder (e.g. Templates/Indice.md) still has its placeholder.
        if ($d -and $d -notlike '*{{*') { return $d }
        break
      }
    }
  }
  return (Builtin-Desc $Name)
}

$skip = @('node_modules', 'venv', 'dist', 'build', 'vendor', 'target', '__pycache__')
function Sub-Dirs([string]$Rel) {
  $path = if ($Rel) { Join-Path $Brain $Rel } else { $Brain }
  Get-ChildItem -LiteralPath $path -Directory |
    Where-Object { -not $_.Name.StartsWith('.') -and ($skip -notcontains $_.Name) } |
    Sort-Object Name | ForEach-Object { $_.Name }
}

# Collect the rows: label (tree prefix + name) and description.
$labels = New-Object System.Collections.Generic.List[string]
$descs = New-Object System.Collections.Generic.List[string]
$missing = ''

$topFiles = @()
foreach ($f in @($N.Root, $N.Now, 'AGENTS.md')) {
  if ($f -and (Test-Path -LiteralPath (Join-Path $Brain $f) -PathType Leaf) -and -not ($topFiles | Where-Object { $_ -ieq $f })) {
    $topFiles += (CK-FirstExisting $Brain 'file' @($f))
  }
}
$items = @($topFiles) + @(Sub-Dirs '')
for ($i = 0; $i -lt $items.Count; $i++) {
  $item = $items[$i]
  $last = ($i -eq $items.Count - 1)
  $branch = if ($last) { '└── ' } else { '├── ' }
  $pad = if ($last) { '    ' } else { '│   ' }
  if (Test-Path -LiteralPath (Join-Path $Brain $item) -PathType Container) {
    $d = Folder-Desc $item $item
    if (-not $d) { $d = No-Desc; $missing += " $item/" }
    $labels.Add("$branch$item/"); $descs.Add($d)
    $children = @(Sub-Dirs $item)
    for ($j = 0; $j -lt $children.Count; $j++) {
      $child = $children[$j]
      $cb = if ($j -eq $children.Count - 1) { '└── ' } else { '├── ' }
      $d = Folder-Desc "$item\$child" $child
      if (-not $d) { $d = No-Desc; $missing += " $item/$child/" }
      $labels.Add("$pad$cb$child/"); $descs.Add($d)
    }
  } else {
    $labels.Add("$branch$item"); $descs.Add((Builtin-Desc $item))
  }
}

# Render with the descriptions aligned.
$width = ($labels | Measure-Object -Property Length -Maximum).Maximum
$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("$START`n" + '```' + "`n" + (Split-Path -Leaf $Brain) + '/')
for ($k = 0; $k -lt $labels.Count; $k++) {
  $spaces = ' ' * ($width - $labels[$k].Length + 2)
  [void]$sb.Append("`n$($labels[$k])$spaces← $($descs[$k])")
}
[void]$sb.Append("`n" + '```' + "`n$END")
$block = $sb.ToString()

$original = [System.IO.File]::ReadAllText($rootPath, [System.Text.Encoding]::UTF8)
$text = $original -replace "`r", ''
$s = $text.IndexOf($START); $e = $text.IndexOf($END)
$entries = $labels.Count

if ($s -lt 0 -or $e -lt $s) {
  Write-Output "map: no map markers in $($N.Root) (add $START and $END where the map should go)"
  exit 1
}
$current = $text.Substring($s, $e + $END.Length - $s)
if ($current -eq $block) {
  Write-Output "map: up to date ($entries entries)"
  if ($missing) { Write-Output "map: without description:$missing" }
  exit 0
}
if ($check) {
  Write-Output 'map: outdated (run update-map.ps1 or /context-keeper:map)'
  exit 1
}

# Rewrite only the marked section, keeping the file's line endings, as UTF-8 without BOM.
$new = $text.Substring(0, $s) + $block + $text.Substring($e + $END.Length)
if ($original.Contains("`r`n")) { $new = $new -replace "`n", "`r`n" }
[System.IO.File]::WriteAllText($rootPath, $new, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "map: updated ($entries entries)"
if ($missing) { Write-Output "map: without description:$missing" }
exit 0
