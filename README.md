# Tessa's Dotfiles

These are my dotfiles. I use them across macOS, Ubuntu/WSL, and Windows 11.

## Organization

```
dotfiles/
├── assets/                    Wallpapers, profile pics, JetBrains themes
├── personal/
│   ├── setup-macos.sh         macOS setup (Homebrew, symlinks, zsh)
│   ├── setup-ubuntu.sh        Ubuntu/WSL setup (apt, symlinks, zsh)
│   ├── setup-windows.ps1      Windows setup (winget, symlinks, PowerShell)
│   ├── bootstrap.sh           Quick relink utility (no package installs)
│   ├── bin/shared/            Cross-platform shell scripts
│   ├── config/
│   │   ├── starship.toml      Starship prompt config
│   │   ├── delta/             Delta diff themes
│   │   └── win-terminal/      Windows Terminal color schemes
│   ├── git/
│   │   ├── gitconfig          Shared git config (includes OS overlay)
│   │   ├── gitconfig-linux    Linux/WSL overrides
│   │   ├── gitconfig-macos    macOS overrides
│   │   ├── gitconfig-windows  Windows overrides
│   │   └── gitignore_global   Global gitignore
│   ├── shell/
│   │   ├── shared/
│   │   │   ├── zshrc          Shared ZSH core (sourced by all *nix)
│   │   │   └── aliases.sh     Cross-platform aliases and functions
│   │   ├── macos/zshrc        macOS-specific (Homebrew, plugins)
│   │   ├── ubuntu/zshrc       Ubuntu/WSL-specific (apt plugins, WSL)
│   │   └── win11/*.ps1        PowerShell profile
│   └── vim/                   Vim config and plugins
```

## Quick Start

Clone into `~/Developer/personal/` and run the setup script for your OS:

```sh
# Clone
mkdir -p ~/Developer/personal
cd ~/Developer/personal
git clone <repo-url> dotfiles

# macOS
cd dotfiles/personal && ./setup-macos.sh

# Ubuntu / WSL
cd dotfiles/personal && ./setup-ubuntu.sh
```

```powershell
# Windows (elevated PowerShell)
cd ~\Developer\personal\dotfiles\personal
.\setup-windows.ps1
```

Each setup script will:
1. Install required packages (Homebrew/apt/winget)
2. Create symlinks from the repo to their expected locations
3. Generate a `~/.zshrc` (or link a PowerShell profile) that sources the
   shared config followed by OS-specific additions

## How the Shell Config Works

On macOS and Linux, `~/.zshrc` is a small generated loader:

```zsh
DOTFILES="$HOME/Developer/personal/dotfiles/personal"
[[ -f "$DOTFILES/shell/shared/zshrc" ]] && source "$DOTFILES/shell/shared/zshrc"
[[ -f "$DOTFILES/shell/macos/zshrc" ]]  && source "$DOTFILES/shell/macos/zshrc"
```

- **shared/zshrc** sets up: locale, `$EDITOR`, `$DOTFILES`, `$SCM`, PATH,
  OS detection (`$OS`), ZSH options, completions, starship, GPG, vim mode,
  NVM, and sources `shared/aliases.sh`.
- **OS-specific zshrc** adds: `$STARSHIP_OS_ICON`, plugin paths, and
  OS-specific functions (TTS timers, etc).

On Windows, the PowerShell profile is symlinked directly and provides
equivalent aliases and starship integration.

## How Git Config Works

`git/gitconfig` is the shared base. It includes `~/.gitconfig-os` which each
setup script symlinks to `gitconfig-linux`, `gitconfig-macos`, or
`gitconfig-windows`.
This keeps OS-specific paths (editor, GPG, credential helper) separate from
shared settings.

## Relinking Only

If you've already run the setup script and just need to refresh symlinks:

```sh
./bootstrap.sh        # dry run: ./bootstrap.sh -d
```
