# Tessa's Dotfiles — Claude Setup Guide

You are setting up a new development machine using these dotfiles. Work through each section
in order. **Ask all questions in Section 1 before doing anything else** — the answers drive
every decision that follows.

---

## Repository Structure

```
dotfiles/
├── dot_config/                  Chezmoi-managed configs (~/.config/)
│   └── starship.toml            Starship prompt
├── readonly_Documents/          Chezmoi-managed (~/ Documents/)
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── personal/
│   ├── setup-windows.ps1        Legacy setup script (reference only — this guide replaces it)
│   ├── config/
│   │   ├── win-terminal/        Windows Terminal color schemes
│   │   └── delta/               Delta diff themes
│   └── git/                     Git configs (shared + OS overlays)
└── assets/                      Wallpapers, profile pics, JetBrains themes
```

Configs are managed by **chezmoi**. Always apply configs via `chezmoi apply` — do not manually
symlink or copy chezmoi-managed files.

---

## Section 1 — Ask These Questions First

Ask all of these upfront. Do not start installing anything until you have answers.

### Machine identity
- **Work or personal machine?**
  Work → use work email for git, may have OneDrive Documents redirect.
  Personal → use personal email, standard Documents path.

- **What is your full name and email for git config?**
  (Needed to configure `~/.gitconfig`.)

### Development scope
- **What are you primarily developing?**
  Options (can choose multiple): C/C++, Python, Node/web, other. This determines which
  language toolchains to install.

- **Full setup or minimal?**
  Full → install everything in the catalog.
  Minimal → essentials only (git, starship, lsd, bat, neovim).

### Optional tools — ask about each
For each of the following, ask whether to install it and briefly explain what it does if the
user seems unsure:

| Tool | What it does |
|------|-------------|
| `lazygit` | Terminal UI for git — browse commits, stage hunks, resolve conflicts visually |
| `ripgrep` | Faster `grep` with better defaults, used by neovim plugins |
| `fd` | Faster `find` with simpler syntax |
| `fzf` | Fuzzy finder — powers interactive history search and file picking in the shell |
| `delta` | Syntax-highlighted git diffs in the terminal |
| `GnuPG` | GPG for signing git commits |
| `Docker Desktop` | Container runtime for local dev environments |
| `VS Code` | GUI text editor — used alongside neovim for quick edits and non-terminal work |

### Accounts
- **Do you want to authenticate with GitHub CLI (`gh auth login`)?**
- **Do you want GPG commit signing configured?** (Only ask if GnuPG is being installed.)
- **Do you want an SSH key generated and added to GitHub?**

---

## Section 2 — Detect the Environment

Before installing anything, run these checks and note the results:

```powershell
# PowerShell version — need 7+
$PSVersionTable.PSVersion

# Documents path — check for OneDrive redirect
$docsPath = [Environment]::GetFolderPath('MyDocuments')
Write-Host "Documents: $docsPath"
Write-Host "Profile: $PROFILE"

# Check what's already installed (avoid reinstalling)
winget list 2>$null | Select-String "starship|neovim|git|chezmoi|lazygit|ripgrep|delta|fzf|docker"

# Check for scoop
Get-Command scoop -ErrorAction SilentlyContinue
```

**Key decisions from detection:**
- If `$PROFILE` is under OneDrive, chezmoi cannot apply the PS profile to the standard path.
  After `chezmoi apply`, manually copy the profile to the OneDrive path (see Section 4).
- If PowerShell < 7, install it first: `winget install Microsoft.PowerShell`.
- Skip any packages already installed.

---

## Section 3 — Install Packages

Install in this order (dependencies first).

### Always install

```powershell
winget install Git.Git --accept-source-agreements --accept-package-agreements --silent
winget install Starship.Starship --accept-source-agreements --accept-package-agreements --silent
winget install twpayne.chezmoi --accept-source-agreements --accept-package-agreements --silent
winget install sharkdp.bat --accept-source-agreements --accept-package-agreements --silent
winget install lsd-rs.lsd --accept-source-agreements --accept-package-agreements --silent
winget install Neovim.Neovim --accept-source-agreements --accept-package-agreements --silent
winget install GitHub.cli --accept-source-agreements --accept-package-agreements --silent
winget install Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
```

### Install if chosen

```powershell
winget install jesseduffield.lazygit   # lazygit
winget install BurntSushi.ripgrep.MSVC # ripgrep
winget install sharkdp.fd              # fd
winget install junegunn.fzf            # fzf
winget install dandavison.delta        # delta
winget install GnuPG.GnuPG            # GPG
winget install Docker.DockerDesktop   # Docker (if chosen)
```

### Fonts

JetBrainsMono Nerd Font is included in `packages.json` and installed via winget above.
Recursive-NF-Mono (primary font) and RobotoMono-NF are only available via scoop:

```powershell
# Install scoop if not present
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop bucket add nerd-fonts 2>$null
scoop install Recursive-NF-Mono   # Primary font (Rec Mono Linear Nerd Font)
scoop install RobotoMono-NF       # Fallback
```

---

## Section 4 — Apply Configs with Chezmoi

```powershell
# Clone dotfiles and initialise chezmoi
chezmoi init https://github.com/tessapower/dotfiles

# Point chezmoi at the repo root (package family name is consistent across installs)
New-Item -ItemType Directory -Force ~/.config/chezmoi
@'
sourceDir = "~/.local/share/chezmoi"
'@ | Set-Content ~/.config/chezmoi/chezmoi.toml

chezmoi apply
```

### If $PROFILE is under OneDrive (work machines)

Chezmoi applies the PS profile to `~/Documents/PowerShell/` but `$PROFILE` resolves to the
OneDrive path. After `chezmoi apply`:

```powershell
$dest = Split-Path $PROFILE
New-Item -ItemType Directory -Force $dest
Copy-Item ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1 $PROFILE
```

### Windows Terminal color schemes

Apply the Rose Pine color schemes and font from the repo:

```powershell
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtSettings) {
    $current = Get-Content $wtSettings | ConvertFrom-Json
    $repo    = Get-Content "$PSScriptRoot\personal\config\win-terminal\settings.json" | ConvertFrom-Json

    # Merge schemes
    $existingNames = $current.schemes.name
    foreach ($scheme in $repo.schemes) {
        if ($scheme.name -notin $existingNames) {
            $current.schemes += $scheme
        }
    }

    # Apply defaults (font, cursor, color scheme)
    $current.defaults = $repo.defaults

    $current | ConvertTo-Json -Depth 10 | Set-Content $wtSettings
    Write-Host "Windows Terminal settings updated."
} else {
    Write-Host "Windows Terminal not found — install it first, then re-run this step."
}
```

### Git config

```powershell
# These are applied on top of personal/git/gitconfig which handles the rest
git config --global user.name  "<answer from Section 1>"
git config --global user.email "<answer from Section 1>"
```

If delta was installed, add diff configuration:

```powershell
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
```

---

## Section 5 — Accounts & Signing

### GitHub CLI

```powershell
gh auth login
```

Choose HTTPS or SSH. If SSH, continue to the next step.

### SSH key (if requested)

```powershell
$keyPath = "$HOME\.ssh\id_ed25519"
if (-not (Test-Path $keyPath)) {
    ssh-keygen -t ed25519 -C "<git email>" -f $keyPath
}
gh ssh-key add "$keyPath.pub" --title (hostname)
```

### GPG commit signing (if GnuPG installed and requested)

```powershell
gpg --full-generate-key   # Choose RSA 4096, no expiry
$keyId = (gpg --list-secret-keys --keyid-format LONG | Select-String "sec" | ForEach-Object { ($_ -split "/")[1] -split " "[0] })[0]
git config --global user.signingkey $keyId
git config --global commit.gpgsign true
gpg --armor --export $keyId | gh gpg-key add -
```

---

## Section 6 — Verify Everything Works

Work through this checklist and fix anything that fails before finishing:

```powershell
# 1. Prompt
# Close and reopen the terminal — starship prompt should appear with icons

# 2. Profile
. $PROFILE   # Should load without errors
vim --version | head -1   # Should show nvim version

# 3. Aliases
ls           # Should use lsd (icons + colours)
cat $PROFILE # Should use bat (syntax highlighted)

# 4. Git
git config user.name
git config user.email
git log --oneline -5   # Should show delta-highlighted diff if delta installed

# 5. GitHub
gh auth status

# 6. Font rendering
# Run the font test from your profile:
font-test    # Should show bold/italic/underline — if boxes appear, font isn't set in terminal
```

---

## Section 7 — Winget Package Bundle

A curated `packages.json` in the repo root installs the full known-good package set in one
shot. It includes all dev tools, shell utilities, and apps — Logitech software is included
but ask before installing (only useful if Logitech peripherals are present).

```powershell
# Ask about Logitech first
$installLogitech = (Read-Host "Do you have Logitech peripherals? (y/n)") -eq 'y'

if (-not $installLogitech) {
    # Remove Logitech entries before importing
    $bundle = Get-Content "$PSScriptRoot\packages.json" | ConvertFrom-Json
    $bundle.Sources[0].Packages = $bundle.Sources[0].Packages |
        Where-Object { $_.PackageIdentifier -notlike "Logitech.*" }
    $bundle | ConvertTo-Json -Depth 10 | Set-Content "$env:TEMP\packages-filtered.json"
    winget import -i "$env:TEMP\packages-filtered.json" --accept-package-agreements --accept-source-agreements
} else {
    winget import -i "$PSScriptRoot\packages.json" --accept-package-agreements --accept-source-agreements
}
```

To update the bundle after adding new tools:

```powershell
# Export, then manually remove any system/runtime noise before committing
winget export -o ~/Developer/dotfiles/packages.json
```

> The bundle intentionally excludes: Visual Studio, Windows SDK, RenderDoc, PIX (install
> these only when doing graphics work), and Chrome/Zoom/Adobe Acrobat (managed by IT or
> not wanted by default).

---

## Notes for Future Updates

- To add a new managed config file: `chezmoi add <path>` then `cd ~/.local/share/chezmoi && git add . && git commit && git push`
- To sync configs on an existing machine: `chezmoi update`
- The `personal/` directory is ignored by chezmoi — files there are managed manually or via symlinks from the legacy setup script
