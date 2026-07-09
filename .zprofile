# ~/.zprofile — login shells only, sourced AFTER /etc/zprofile (which runs macOS
# `path_helper`). PATH lives here so our dirs land in front of the system dirs that
# path_helper prepends — otherwise a /usr/bin or /opt/homebrew/bin binary could
# shadow ours. Login shells cover interactive terminals AND Modelo's `zsh -lc`.
#
# (Tool roots like $BUN_INSTALL/$PNPM_HOME are exported in ~/.zshenv, which runs
# first, so they're already set when referenced below.)

typeset -U path   # keep PATH entries unique
path=(
  $HOME/.local/bin                                  # node/npm/npx + user CLIs (firecrawl, …)
  $HOME/.cargo/bin
  $BUN_INSTALL/bin
  $PNPM_HOME
  $HOME/.omlx/bin
  $HOME/.yarn/bin
  $HOME/.config/yarn/global/node_modules/.bin
  $path
)
