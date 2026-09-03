#Requires -Version 5.1
# Links or copies the files in this repo into the places each AI tool reads. Safe to run again.
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$home_ = [Environment]::GetFolderPath('UserProfile')

function Link-Or-Copy([string]$target, [string]$source) {
    $dir = Split-Path $target
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $source) { Write-Host "ok      $target"; return }
        if (-not $item.LinkType -and -not (Test-Path "$target.bak")) { Copy-Item $target "$target.bak" }
        Remove-Item $target -Force
    }
    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "linked  $target"
    } catch {
        Copy-Item $source $target
        Write-Host "copied  $target (no symlink rights; re-run after git pull, or enable Developer Mode)"
    }
}

function Add-UserEnvDir([string]$name, [string]$dir) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($current -and ($current -split ',' | ForEach-Object { $_.Trim() }) -contains $dir) { Write-Host "ok      $name"; return }
    $value = if ($current) { "$current,$dir" } else { $dir }
    [Environment]::SetEnvironmentVariable($name, $value, 'User')
    Write-Host "set     $name=$value (open a new terminal)"
}

# Claude Code: user CLAUDE.md imports AGENTS.md; Caveman output style; select it in settings.json.
$claudeMd = Join-Path $home_ '.claude\CLAUDE.md'
$import = '@~/ai-instructions/AGENTS.md'
if (-not (Test-Path $claudeMd)) { New-Item -ItemType Directory -Force -Path (Split-Path $claudeMd) | Out-Null; Set-Content $claudeMd $import; Write-Host "wrote   $claudeMd" }
elseif (-not (Select-String -Path $claudeMd -SimpleMatch $import -Quiet)) { Add-Content $claudeMd "`n$import"; Write-Host "appended $claudeMd" }
else { Write-Host "ok      $claudeMd" }
Link-Or-Copy (Join-Path $home_ '.claude\output-styles\caveman.md') (Join-Path $repo 'claude\output-styles\caveman.md')
$settingsPath = Join-Path $home_ '.claude\settings.json'
$settings = if (Test-Path $settingsPath) { Get-Content $settingsPath -Raw | ConvertFrom-Json } else { [pscustomobject]@{} }
if ($settings.outputStyle -ne 'Caveman') {
    $settings | Add-Member -NotePropertyName outputStyle -NotePropertyValue 'Caveman' -Force
    $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath
    Write-Host "set     outputStyle=Caveman in $settingsPath"
} else { Write-Host "ok      outputStyle=Caveman" }

# Codex: only reads ~/.codex/AGENTS.md, no imports.
Link-Or-Copy (Join-Path $home_ '.codex\AGENTS.md') (Join-Path $repo 'AGENTS.md')

# Copilot CLI and app: user instructions file, plus this folder as an instructions dir.
Link-Or-Copy (Join-Path $home_ '.copilot\copilot-instructions.md') (Join-Path $repo 'AGENTS.md')
Add-UserEnvDir 'COPILOT_CUSTOM_INSTRUCTIONS_DIRS' $repo

# Re-run this script after every git pull.
git -C $repo config core.hooksPath .githooks
Write-Host 'done'
