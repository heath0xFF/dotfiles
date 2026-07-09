# dotfiles

Personal dotfiles for macOS.

## What's in here

- **zsh** — `.zshenv` (environment), `.zprofile` (PATH), and `.zshrc` (prompt, aliases, functions); API keys stay out of the repo in `~/.zsh_secrets`
- **terminal** — cmux (primary, Ghostty-based) and Ghostty; config in `config/ghostty/` (Inconsolata Mono Nerd Font, Catppuccin Mocha)
- **tmux** — `Ctrl+Space` prefix, vim-style pane navigation
- **neovim** — full LSP/Treesitter setup, maintained in a [separate repo](https://github.com/hhheath/nvim)
- **oh-my-pi** — coding agent config: model roles, themes, and local model servers (`config/omp/`); auth stays in omp's own storage
- **uv** — Python package/project manager (standalone installer)
- **oMLX** — local MLX model server ([omlx.ai](https://omlx.ai)), installed from the latest GitHub release DMG; its settings stay local (they contain server keys)
- **Brewfile** — macOS packages via Homebrew
- **Claude Code** — AI coding assistant

## Install

```bash
git clone https://github.com/hhheath/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

The install script is macOS-only. It installs Homebrew, runs `brew bundle` from the Brewfile (node included), installs uv, bun + oh-my-pi, and oMLX, copies configs, clones the nvim config, sets zsh as the default shell, and installs Claude Code.

### After install

1. Restart your terminal (or `source ~/.zshrc`)
2. Verify `~/.gitconfig` name/email
3. Open `nvim` to auto-install plugins
4. `pyenv install 3.12 && pyenv global 3.12`
5. Create `~/.zsh_secrets` (chmod 600) with API keys — sourced by `.zshenv`

## Structure

```
dotfiles/
├── config/
│   ├── ghostty/config     # Ghostty terminal (cmux is Ghostty-based)
│   └── omp/               # oh-my-pi config + model definitions
├── .zshenv                # Zsh environment (all shells)
├── .zprofile              # PATH setup (login shells)
├── .zshrc                 # Zsh interactive config
├── .tmux.conf             # Tmux config
├── .gitconfig             # Git config
├── Brewfile               # Homebrew packages
└── install.sh             # Setup script
```

## Key bindings

### Tmux
- **Prefix**: `Ctrl+Space`
- **Panes**: `Alt+hjkl` to navigate, `\` horizontal split, `-` vertical split
- **Mouse**: enabled

## Updating

### Brewfile

```bash
brew bundle dump --force --file=~/code/dotfiles/Brewfile
```
