#!/usr/bin/env bash
set -e

echo "Setting up Ubuntu/WSL environment..."

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Using dotfiles from: $DOTFILES_DIR"

###############################################################################
# PACKAGES
###############################################################################

echo "Updating apt..."
sudo apt update && sudo apt upgrade -y

echo "Installing packages..."
sudo apt install -y \
    zsh \
    neovim \
    git \
    curl \
    bat \
    ripgrep \
    fd-find \
    fzf \
    tig \
    xclip \
    zsh-autosuggestions \
    zsh-syntax-highlighting

###############################################################################
# STARSHIP
###############################################################################

if ! command -v starship &> /dev/null; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
fi

###############################################################################
# EZA
###############################################################################

if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
        sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
        sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt update
    sudo apt install -y eza
fi

###############################################################################
# DELTA
###############################################################################

if ! command -v delta &> /dev/null; then
    echo "Installing delta..."
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo /tmp/delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
    sudo dpkg -i /tmp/delta.deb
    rm /tmp/delta.deb
fi

###############################################################################
# LAZYGIT
###############################################################################

if ! command -v lazygit &> /dev/null; then
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit /tmp/lazygit.tar.gz
fi

###############################################################################
# GITHUB CLI
###############################################################################

if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

###############################################################################
# DEFAULT SHELL
###############################################################################

if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

###############################################################################
# DIRECTORIES
###############################################################################

mkdir -p ~/.config/delta
mkdir -p ~/.vim/autoload
mkdir -p ~/bin

###############################################################################
# SYMLINKS
###############################################################################

echo "Creating symlinks..."

# Git
ln -sf "$DOTFILES_DIR/git/gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/git/gitconfig-linux" ~/.gitconfig-os
ln -sf "$DOTFILES_DIR/git/gitignore_global" ~/.gitignore_global
ln -sf "$DOTFILES_DIR/git/tigrc" ~/.tigrc
echo "  Linked git configs"

# Starship
ln -sf "$DOTFILES_DIR/config/starship.toml" ~/.config/starship.toml
echo "  Linked starship.toml"

# Delta themes
ln -sf "$DOTFILES_DIR/config/delta/themes.gitconfig" ~/.config/delta/themes.gitconfig
echo "  Linked delta themes"

# Vim
ln -sf "$DOTFILES_DIR/vim/vimrc" ~/.vimrc
ln -sf "$DOTFILES_DIR/vim/autoload/plug.vim" ~/.vim/autoload/plug.vim
echo "  Linked vim config"

# Shared bin scripts
if [ -d "$DOTFILES_DIR/bin/shared" ]; then
    for script in "$DOTFILES_DIR/bin/shared/"*; do
        if [ -f "$script" ]; then
            ln -sf "$script" ~/bin/"$(basename "$script")"
        fi
    done
    chmod +x ~/bin/* 2>/dev/null || true
    echo "  Linked shared bin scripts"
fi

# ZSH config loader
cat > ~/.zshrc << 'ZSHRC'
# Generated by setup-ubuntu.sh — sources dotfiles configs
DOTFILES="$HOME/Developer/personal/dotfiles/personal"
[[ -f "$DOTFILES/shell/shared/zshrc" ]] && source "$DOTFILES/shell/shared/zshrc"
[[ -f "$DOTFILES/shell/ubuntu/zshrc" ]] && source "$DOTFILES/shell/ubuntu/zshrc"
ZSHRC
echo "  Created ~/.zshrc loader"

###############################################################################
# DONE
###############################################################################

echo ""
echo "Ubuntu/WSL setup complete!"
echo ""
echo "Next steps:"
echo "  1. Close and reopen your terminal (or run 'exec zsh')"
echo "  2. Run 'gh auth login' to authenticate with GitHub"
echo "  3. Run ':PlugInstall' in vim to install plugins"
echo ""
