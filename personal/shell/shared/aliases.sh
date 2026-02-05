#!/usr/bin/env bash
# Cross-platform aliases and functions
# Sourced by shell/shared/zshrc (which sets $OS, $DOTFILES, $SCM)

################################################################################
# EDITOR
################################################################################

alias vim="nvim"
alias vi="nvim"

################################################################################
# LS REPLACEMENT
################################################################################

if [[ "$OS" == "windows" ]]; then
    alias ls="lsd"
    alias tree="lsd --tree"
else
    alias ls="eza --icons"
    alias tree="eza --tree --icons"
fi

################################################################################
# QUICK CONFIG EDITS
################################################################################

alias zshconfig="nvim ~/.zshrc"
alias nvimconfig="nvim ~/.config/nvim"
alias aliasedit="nvim ${DOTFILES}/shell/shared/aliases.sh"

################################################################################
# NAVIGATION
################################################################################

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

################################################################################
# QUICK ACCESS
################################################################################

alias dots="cd ${DOTFILES}"
alias cddev="cd ${SCM}"

################################################################################
# BAT (nice cat)
################################################################################

if command -v batcat &> /dev/null; then
    alias bat="batcat"
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
# GIT
################################################################################

batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

################################################################################
# UTILITIES
################################################################################

alias font-test="echo -e '\e[1mbold\e[0m\n\e[3mitalic\e[0m\n\e[4munderline\e[0m\n\e[9mstrikethrough\e[0m'"

# Run clang-format Google style
alias notugly="clang-format -i -style=Google"

################################################################################
# FUNCTIONS
################################################################################

# Open files in default application (OS-aware)
o() {
    if [[ $# -ne 1 ]]; then
        echo "usage: o file" >&2
        return 1
    fi

    case "$OS" in
        wsl)
            local linux_path=$(realpath "$1" 2>/dev/null)
            local win_path=$(echo "$linux_path" | sed 's;^/mnt/\([a-z]\);\U\1:;')
            powershell.exe -c "Invoke-Item '$win_path'"
            ;;
        macos)
            open "$1"
            ;;
        linux)
            xdg-open "$1" 2>/dev/null
            ;;
    esac
}
