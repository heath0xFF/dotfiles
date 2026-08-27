# ~/.zshrc — INTERACTIVE shells only. Prompt, completions, aliases, functions,
# and interactive tool init live here. Environment/PATH/API keys live in ~/.zshenv
# so non-interactive and GUI-launched shells (which never read .zshrc) get them too.

# color ls output
export CLICOLOR=1

setopt autocd

# Completions: cached compinit — skip the security audit + re-dump when <24h old.
autoload -Uz compinit
() {
  setopt local_options extended_glob
  if [[ -n ~/.zcompdump(#qN.mh-24) ]]; then compinit -C; else compinit; fi
}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive matching

#====================== Prompt ====================================================================
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

# single line; git info + exit status on the right
setopt PROMPT_SUBST
PROMPT='%F{004}%~%f %(?.%F{002}.%F{001})❯%f '
RPROMPT='${vcs_info_msg_0_}%(?.. %F{001}✘ %?%f)'
# prepend user@host when connected over ssh
[[ -n $SSH_CONNECTION ]] && PROMPT="%F{002}%n@%m%f $PROMPT"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' ✗'
zstyle ':vcs_info:*' stagedstr ' ✓'
zstyle ':vcs_info:git:*' formats       '(%F{005}%b%u%c%f)'
zstyle ':vcs_info:git:*' actionformats '(%F{005}%b|%a%u%c%f)'
#===================== Prompt =====================================================================

#===================== Functions ==================================================================

# ggpush because i like that command from omz
ggpush() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

# gcam because i like that command from omz
gcam() {
  if [ $# -eq 0 ]; then
    # If no commit message is provided, prompt the user for one
    echo "Please enter a commit message:"
    read -r "msg?> "
    git commit -a -m "$msg"
  else
    # If a commit message is provided, use it
    local msg=$1
    shift
    git commit -a -m "$msg"
  fi
}

# gst because i like that command from omz
gst() {
  git status
}

# gco because i like that command from omz
gco() {
  if [ $# -eq 0 ]; then
    # No args: jump back to the previous branch (like `cd -`)
    git checkout -
  else
    git checkout "$@"
  fi
}

# download audio from a url as opus
dlaudio() { yt-dlp -x --audio-format opus "$1" }
#===================== Functions ==================================================================

# aliases
alias python="python3"
alias virtual="python -m venv .venv"
alias activate="source .venv/bin/activate"
alias ll='ls -al'
alias ol='ollama run llama3.2'
alias v='nvim'
alias btop="bpytop"

# pyenv (interactive python version management)
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# node/npm/npx come from ~/.local/bin (on PATH via ~/.zprofile) for ALL shells —
# interactive and GUI apps alike, so `npm i -g` lands in one place everyone sees.
# (Removed nvm: it managed a single version, ran interactive-only, and hid node
# from non-interactive shells like Modelo's `zsh -lc`. Restore from ~/.nvm if ever
# you actually need per-project node versions — or use mise for that + python.)

# Entire CLI shell completion
(( $+commands[entire] )) && source <(entire completion zsh)

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Start Herdr (kept last so the Herdr server inherits the full environment)
if [ "$HERDR_ENV" = "" ]; then herdr; fi
