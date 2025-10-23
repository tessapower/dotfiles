#!/usr/bin/env bash
# Cross-platform aliases
# Sourced by shell/OS/.zshrc

# Detect OS (should already be set by .zshrc, but defensive)
if [[ -z "$OS" ]]; then
    case "$(uname -s 2>/dev/null)" in
        Darwin*) OS="macos" ;;
        Linux*)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                OS="wsl"
            else
                OS="linux"
            fi
            ;;
        *) OS="unknown" ;;
    esac
fi

################################################################################
# EDITOR
################################################################################

alias vim="nvim"
alias vi="nvim"

################################################################################
# LS REPLACEMENT - Unified 'l' command
################################################################################

if [[ "$OS" == "windows" ]]; then
    # Use lsd on Windows (via scoop)
    alias ls="lsd"
else
    # Use eza on *nix systems
    alias ls="eza --icons"
    alias tree="eza --tree --icons"
fi

################################################################################
# QUICK CONFIG EDITS
################################################################################

alias zshconfig="nvim ~/.zshrc"
alias nvimconfig="nvim ~/.config/nvim"
alias aliasedit="nvim ${DOTFILES}/aliases/cross-platform.sh"

################################################################################
# NAVIGATION
################################################################################

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

################################################################################
# DOTFILES
################################################################################

alias dots="cd ${DOTFILES}"

################################################################################
# PROJECT DIRECTORIES
################################################################################

alias cddev="cd ${SCM}"

################################################################################
# BAT (nice cat)
################################################################################

if command -v batcat &> /dev/null; then
    alias bat="batcat"  # Ubuntu's bat is named batcat
    alias cat="batcat"
elif command -v bat &> /dev/null; then
    alias cat="bat"
fi

################################################################################
# CLIPBOARD (OS-aware)
################################################################################

if [[ "$OS" == "wsl" ]]; then
    alias clip="clip.exe"
    alias paste="powershell.exe Get-Clipboard"
elif [[ "$OS" == "macos" ]]; then
    alias clip="pbcopy"
    alias paste="pbpaste"
fi

################################################################################
# UTILITIES
################################################################################

alias font-test="echo -e '\e[1mbold\e[0m\n\e[3mitalic\e[0m\n\e[4munderline\e[0m\n\e[9mstrikethrough\e[0m'"

################################################################################
# FUNCTIONS
################################################################################

# Open files in default application (OS-aware)
o() {
    if [[ "$OS" == "wsl" ]]; then
        # Convert WSL path to Windows path and open
        local linux_path=$(realpath "$1" 2>/dev/null)
        local win_path=$(echo "$linux_path" | sed 's;^/mnt/\([a-z]\);\U\1:;')
        powershell.exe -c "Invoke-Item '$win_path'"
    elif [[ "$OS" == "macos" ]]; then
        open "$1"
    else
        xdg-open "$1" 2>/dev/null
    fi
}

export OS
