# ~/.zshenv — sourced by EVERY zsh: interactive, scripts, `zsh -c`, GUI subshells.
# The manual says keep this SMALL and SILENT. It holds environment any process may
# need. PATH now lives in ~/.zprofile (so it lands after macOS path_helper and keeps
# our ordering); interactive setup lives in ~/.zshrc.

# Rust / cargo (rustup-managed; also adds ~/.cargo/bin, re-prioritized in ~/.zprofile)
. "$HOME/.cargo/env"

# JS tool roots — read by the tools directly, and referenced by PATH in ~/.zprofile
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

# API keys — kept in a git-ignorable, chmod-600 file out of version-controlled dotfiles
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"
