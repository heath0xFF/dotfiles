#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { echo "[*] $1"; }
warn() { echo "[!] $1"; }

command_exists() { command -v "$1" &>/dev/null; }

backup_and_copy() {
    local src="$1" dest="$2"
    if [ -f "$dest" ] || [ -d "$dest" ]; then
        mkdir -p "$HOME/.dotfiles_backup"
        mv "$dest" "$HOME/.dotfiles_backup/$(basename "$dest").$(date +%s).bak"
    fi
    cp "$src" "$dest"
}

install_packages() {
    if ! command_exists brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update
    brew bundle install --file="$DOTFILES_DIR/Brewfile"
}

install_uv() {
    if command_exists uv; then
        info "uv already installed: $(uv --version)"
        return
    fi

    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_omlx() {
    if [ -d "/Applications/oMLX.app" ]; then
        info "oMLX already installed"
        return
    fi

    info "Installing oMLX (local MLX model server)..."
    local urls url dmg="/tmp/oMLX.dmg" mount_point os_major
    urls=$(curl -fsSL https://api.github.com/repos/jundot/omlx/releases/latest \
        | grep -o 'https://[^"]*\.dmg')
    # releases ship one DMG per macOS version — prefer the one matching ours
    os_major=$(sw_vers -productVersion | cut -d. -f1)
    url=$(echo "$urls" | grep "macos${os_major}" | head -1)
    [ -z "$url" ] && url=$(echo "$urls" | head -1)
    if [ -z "$url" ]; then
        warn "Could not find oMLX DMG — install manually: https://github.com/jundot/omlx/releases"
        return
    fi

    curl -fsSL -o "$dmg" "$url"
    mount_point=$(hdiutil attach "$dmg" -nobrowse | grep -o '/Volumes/.*' | head -1)
    cp -R "$mount_point"/*.app /Applications/
    hdiutil detach "$mount_point" -quiet
    rm -f "$dmg"
    info "oMLX installed — launch it once to set up the model directory and CLI"
}

install_oh_my_pi() {
    if ! command_exists bun && [ ! -x "$HOME/.bun/bin/bun" ]; then
        info "Installing bun..."
        curl -fsSL https://bun.sh/install | bash
    fi
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    if command_exists omp; then
        info "oh-my-pi already installed: $(omp --version 2>/dev/null)"
    else
        info "Installing oh-my-pi..."
        bun install -g @oh-my-pi/pi-coding-agent
    fi
}

install_claude_code() {
    if command_exists claude; then
        info "Claude Code already installed: $(claude --version 2>/dev/null)"
        return
    fi

    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | sh
}

copy_configs() {
    mkdir -p "$HOME/.config/ghostty" "$HOME/.omp/agent"

    backup_and_copy "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    backup_and_copy "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
    backup_and_copy "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
    backup_and_copy "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

    if [ ! -f "$HOME/.gitconfig" ]; then
        cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
        warn "Copied .gitconfig — verify name and email!"
    fi

    backup_and_copy "$DOTFILES_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"

    # oh-my-pi (models/settings only — auth lives in omp's own storage, never in the repo)
    backup_and_copy "$DOTFILES_DIR/config/omp/config.yml" "$HOME/.omp/agent/config.yml"
    backup_and_copy "$DOTFILES_DIR/config/omp/models.yml" "$HOME/.omp/agent/models.yml"

    # nvim config (separate repo)
    if [ ! -d "$HOME/.config/nvim" ]; then
        info "Cloning nvim config..."
        git clone https://github.com/hhheath/nvim.git "$HOME/.config/nvim"
    else
        info "~/.config/nvim already exists, skipping"
    fi
}

set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
    fi
}

main() {
    case "$OSTYPE" in
        darwin*) ;;
        *) warn "This script is macOS-only."; exit 1 ;;
    esac

    info "Installing dotfiles from $DOTFILES_DIR"

    install_packages
    install_uv
    install_oh_my_pi
    install_omlx
    copy_configs
    set_default_shell
    install_claude_code

    echo ""
    echo "Done! Next steps:"
    echo "  1. Restart your terminal (or: source ~/.zshrc)"
    echo "  2. Verify ~/.gitconfig name/email"
    echo "  3. Open nvim to auto-install plugins"
    echo "  4. pyenv install 3.12 && pyenv global 3.12"
    echo "  5. Create ~/.zsh_secrets (chmod 600) with API keys — sourced by .zshenv"
}

main
