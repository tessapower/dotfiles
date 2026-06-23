# Windows 11 setup script — non-elevated portion
# Handles scoop, fonts, chezmoi, and Windows Terminal config.
# Launched automatically by setup-windows.ps1, or run manually in a non-elevated PowerShell.

$ErrorActionPreference = "Stop"

Write-Host "Setting up Windows environment (user)..." -ForegroundColor Cyan

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

###############################################################################
# NERD FONTS (via scoop — must be non-elevated)
###############################################################################

Write-Host "`nInstalling Nerd Fonts..." -ForegroundColor Cyan

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop bucket add nerd-fonts 2>$null
Write-Host "  Installing Recursive-NF-Mono..."
scoop install Recursive-NF-Mono 2>$null
Write-Host "  Installing RobotoMono-NF..."
scoop install RobotoMono-NF 2>$null

###############################################################################
# CHEZMOI
###############################################################################

Write-Host "`nApplying dotfiles with chezmoi..." -ForegroundColor Cyan

if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "  chezmoi not found — was the elevated setup completed first?" -ForegroundColor Yellow
} else {
    $chezmoiConfig = "$HOME\.config\chezmoi\chezmoi.toml"
    if (-not (Test-Path $chezmoiConfig)) {
        New-Item -ItemType Directory -Force "$HOME\.config\chezmoi" | Out-Null
        Set-Content $chezmoiConfig 'sourceDir = "~/.local/share/chezmoi"'
    }

    if (Test-Path "$HOME\.local\share\chezmoi\.git") {
        Write-Host "  Updating existing chezmoi source..."
        chezmoi update
    } else {
        Write-Host "  Initialising chezmoi from repo..."
        chezmoi init https://github.com/tessapower/dotfiles
        chezmoi apply
    }

    # Handle OneDrive Documents redirect (common on work machines)
    $standardProfile = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    if ($PROFILE -ne $standardProfile -and (Test-Path $standardProfile)) {
        Write-Host "  OneDrive redirect detected — copying profile to $PROFILE"
        $dest = Split-Path $PROFILE
        New-Item -ItemType Directory -Force $dest | Out-Null
        Copy-Item $standardProfile $PROFILE -Force
    }
}

###############################################################################
# WINDOWS TERMINAL COLOR SCHEMES
###############################################################################

Write-Host "`nApplying Windows Terminal settings..." -ForegroundColor Cyan

$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$repoSettings = "$DotfilesDir\config\win-terminal\settings.json"

if ((Test-Path $wtSettings) -and (Test-Path $repoSettings)) {
    $current = Get-Content $wtSettings | ConvertFrom-Json
    $repo    = Get-Content $repoSettings | ConvertFrom-Json

    $existingNames = $current.schemes.name
    foreach ($scheme in $repo.schemes) {
        if ($scheme.name -notin $existingNames) {
            $current.schemes += $scheme
        }
    }
    $current.defaults = $repo.defaults
    $current | ConvertTo-Json -Depth 10 | Set-Content $wtSettings
    Write-Host "  Windows Terminal settings updated."
} elseif (-not (Test-Path $wtSettings)) {
    Write-Host "  Windows Terminal not found — install it and re-run this step." -ForegroundColor Yellow
}

###############################################################################
# DONE
###############################################################################

Write-Host ""
Write-Host "User setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Close and reopen your terminal"
Write-Host "  2. Run 'gh auth login' to authenticate with GitHub"
Write-Host "  3. Run ':PlugInstall' in vim to install plugins"
Write-Host ""
