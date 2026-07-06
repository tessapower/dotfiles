#Requires -RunAsAdministrator
# Windows 11 setup script — elevated portion
# Run from an elevated PowerShell: .\setup-windows.ps1
# After this completes, run .\setup-windows-user.ps1 in a non-elevated PowerShell.

$ErrorActionPreference = "Stop"

Write-Host "Setting up Windows environment (elevated)..." -ForegroundColor Cyan

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Using dotfiles from: $DotfilesDir"

###############################################################################
# PACKAGES (winget)
###############################################################################

Write-Host "`nInstalling packages via winget..." -ForegroundColor Cyan

$bundlePath = Join-Path (Split-Path $DotfilesDir) "packages.json"
if (Test-Path $bundlePath) {
    Write-Host "  Using curated bundle: $bundlePath"
    $installLogitech = (Read-Host "  Do you have Logitech peripherals? (y/n)") -eq 'y'
    if (-not $installLogitech) {
        $bundle = Get-Content $bundlePath | ConvertFrom-Json
        $bundle.Sources[0].Packages = $bundle.Sources[0].Packages |
            Where-Object { $_.PackageIdentifier -notlike "Logitech.*" }
        $filtered = "$env:TEMP\packages-filtered.json"
        $bundle | ConvertTo-Json -Depth 10 | Set-Content $filtered
        winget import -i $filtered --accept-package-agreements --accept-source-agreements
    } else {
        winget import -i $bundlePath --accept-package-agreements --accept-source-agreements
    }
} else {
    Write-Host "  packages.json not found, installing essential packages individually..."
    $packages = @(
        "Git.Git"
        "GitHub.cli"
        "Starship.Starship"
        "twpayne.chezmoi"
        "sharkdp.bat"
        "lsd-rs.lsd"
        "BurntSushi.ripgrep.MSVC"
        "sharkdp.fd"
        "junegunn.fzf"
        "jesseduffield.lazygit"
        "dandavison.delta"
        "Neovim.Neovim"
        "Microsoft.VisualStudioCode"
        "GnuPG.GnuPG"
    )
    foreach ($pkg in $packages) {
        Write-Host "  Installing $pkg..."
        winget install --id $pkg --accept-source-agreements --accept-package-agreements --silent 2>$null
    }
}

###############################################################################
# NOTE: Config files are managed by chezmoi — see setup-windows-user.ps1
###############################################################################

Write-Host "`nNote: dotfile configs will be applied by chezmoi in the next step." -ForegroundColor Cyan

###############################################################################
# DONE — launch user-level setup
###############################################################################

Write-Host ""
Write-Host "Elevated setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Launching non-elevated setup for fonts and chezmoi..." -ForegroundColor Cyan

$userScript = Join-Path $DotfilesDir "setup-windows-user.ps1"
if (Test-Path $userScript) {
    Start-Process pwsh -ArgumentList "-NoExit", "-File", "`"$userScript`"" -Verb Open
} else {
    Write-Host "  setup-windows-user.ps1 not found — run it manually in a non-elevated shell." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps (in the new window):"
Write-Host "  1. Run 'gh auth login' to authenticate with GitHub"
Write-Host "  2. Run ':PlugInstall' in vim to install plugins"
Write-Host ""
