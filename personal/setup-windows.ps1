#Requires -RunAsAdministrator
# Windows 11 setup script
# Run from an elevated PowerShell: .\setup-windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "Setting up Windows environment..." -ForegroundColor Cyan

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Using dotfiles from: $DotfilesDir"

###############################################################################
# PACKAGES (winget)
###############################################################################

Write-Host "`nInstalling packages via winget..." -ForegroundColor Cyan

$packages = @(
    "Starship.Starship"
    "sharkdp.bat"
    "lsd-rs.lsd"
    "BurntSushi.ripgrep.MSVC"
    "sharkdp.fd"
    "junegunn.fzf"
    "jesseduffield.lazygit"
    "dandavison.delta"
    "Neovim.Neovim"
    "Git.Git"
    "GitHub.cli"
    "GnuPG.GnuPG"
)

foreach ($pkg in $packages) {
    Write-Host "  Installing $pkg..."
    winget install --id $pkg --accept-source-agreements --accept-package-agreements --silent 2>$null
}

###############################################################################
# NERD FONTS (via scoop)
###############################################################################

Write-Host "`nInstalling Nerd Fonts..." -ForegroundColor Cyan

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop bucket add nerd-fonts 2>$null
scoop install JetBrainsMono-NF 2>$null
scoop install RobotoMono-NF 2>$null

###############################################################################
# DIRECTORIES
###############################################################################

$dirs = @(
    "$HOME\.config\delta"
    "$HOME\.vim\autoload"
    "$HOME\bin"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

###############################################################################
# SYMLINKS
###############################################################################

Write-Host "`nCreating symlinks..." -ForegroundColor Cyan

function New-Symlink {
    param([string]$Link, [string]$Target)
    if (Test-Path $Link) { Remove-Item $Link -Force -Recurse }
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
}

# Git
New-Symlink "$HOME\.gitconfig" "$DotfilesDir\git\gitconfig"
New-Symlink "$HOME\.gitconfig-os" "$DotfilesDir\git\gitconfig-windows"
New-Symlink "$HOME\.gitignore_global" "$DotfilesDir\git\gitignore_global"
Write-Host "  Linked git configs"

# Starship
New-Symlink "$HOME\.config\starship.toml" "$DotfilesDir\config\starship.toml"
Write-Host "  Linked starship.toml"

# Delta themes
New-Symlink "$HOME\.config\delta\themes.gitconfig" "$DotfilesDir\config\delta\themes.gitconfig"
Write-Host "  Linked delta themes"

# Vim
New-Symlink "$HOME\.vimrc" "$DotfilesDir\vim\vimrc"
New-Symlink "$HOME\.vim\autoload\plug.vim" "$DotfilesDir\vim\autoload\plug.vim"
Write-Host "  Linked vim config"

# PowerShell profile
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
New-Symlink $PROFILE "$DotfilesDir\shell\win11\Microsoft.PowerShell_profile.ps1"
Write-Host "  Linked PowerShell profile"

# Windows Terminal settings (instructions only — path varies by install)
Write-Host ""
Write-Host "  Windows Terminal settings are at:" -ForegroundColor Yellow
Write-Host "    $DotfilesDir\config\win-terminal\settings.json"
Write-Host "  Copy relevant sections into your Windows Terminal settings manually."
Write-Host "  Typical location: %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"

###############################################################################
# DONE
###############################################################################

Write-Host ""
Write-Host "Windows setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Close and reopen your terminal"
Write-Host "  2. Run 'gh auth login' to authenticate with GitHub"
Write-Host "  3. Run ':PlugInstall' in vim to install plugins"
Write-Host ""
