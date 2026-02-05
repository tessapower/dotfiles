# Tessa's PowerShell Profile
# Loaded automatically by PowerShell on startup

################################################################################
# CONSTANTS
################################################################################

$env:EDITOR = "nvim"
$env:SCM = "$HOME\Developer"
$env:DOTFILES = "$env:SCM\personal\dotfiles\personal"
$env:STARSHIP_OS_ICON = ""
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"


################################################################################
# STARSHIP PROMPT
################################################################################

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
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

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Quick access
function dots { Set-Location "$env:DOTFILES" }
function cddev { Set-Location "$env:SCM" }

# Git diff with bat
function batdiff {
    git diff --name-only --relative --diff-filter=d | ForEach-Object { bat --diff $_ }
}

# Font test
function font-test {
    Write-Host "`e[1mbold`e[0m"
    Write-Host "`e[3mitalic`e[0m"
    Write-Host "`e[4munderline`e[0m"
    Write-Host "`e[9mstrikethrough`e[0m"
}
