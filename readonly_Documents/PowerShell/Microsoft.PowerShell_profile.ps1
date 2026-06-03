# PowerShell Profile

################################################################################
# CONSTANTS
################################################################################

$env:EDITOR = "nvim"
$env:STARSHIP_OS_ICON = ""
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"


################################################################################
# STARSHIP PROMPT
################################################################################

if (Get-Command starship -ErrorAction SilentlyContinue) {
    $starshipExe = (Get-Command starship).Source
    $starshipCache = "$env:TEMP\starship_init_cache.ps1"
    $starshipMtime = (Get-Item $starshipExe).LastWriteTime
    $cacheMtime = if (Test-Path $starshipCache) { (Get-Item $starshipCache).LastWriteTime } else { [DateTime]::MinValue }
    if ($cacheMtime -lt $starshipMtime) {
        starship init powershell --print-full-init | Out-File $starshipCache -Encoding utf8
    }
    . $starshipCache
}


################################################################################
# ALIASES
################################################################################

# Editor
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vim -Value nvim
    Set-Alias -Name vi -Value nvim
}

# ls replacement (lsd)
if (Get-Command lsd -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -ErrorAction SilentlyContinue
    function ls { lsd @args }
    function tree { lsd --tree @args }
}

# bat (nice cat)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -ErrorAction SilentlyContinue
    function cat { bat @args }
}

# Git diff with bat
function batdiff {
    git diff --name-only --relative --diff-filter=d | ForEach-Object { bat --diff $_ }
}

# Add VS CMake to path
$env:PATH += ";C:\Program Files\Microsoft Visual Studio\18\Professional\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
