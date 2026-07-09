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

# Attach to the main workspace (full layout), else first existing session
# ── tm: attach to main, building its layout if it doesn't exist ──
tmux_session() {
  if ! tmux has-session -t main 2>/dev/null; then
    tmux new-session -d -s main -n dev -c "$HOME"

    # Window 1: dev — nvim | shell
    tmux send-keys    -t main:dev
    # tmux split-window -h -t main:dev -c "#{pane_current_path}"
    # tmux split-window -v -t main:dev.2 -c "#{pane_current_path}"   # right → top / bottom

    # Window 2: deepthought
    tmux new-window -t main -n deepthought
    tmux send-keys -t main:deepthought 'ssh -t deepthought' Enter

    # Window 3: trillian/kavula
    tmux new-window -t main -n kavula
    tmux send-keys -t main:kavula 'ssh -t kavula' Enter

    tmux select-window -t main:dev
    tmux select-pane   -t main:dev.1
  fi

  # Attach from a normal shell, or switch if already inside tmux
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t main
  else
    tmux attach -t main
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
alias tm="tmux_session"
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

# oh my pi — completions cached; regenerated when the omp binary changes
if (( $+commands[omp] )); then
  _ompc=~/.cache/omp-completions.zsh
  if [[ ! -s $_ompc || $_ompc -ot $commands[omp] ]]; then
    mkdir -p ~/.cache && omp completions zsh > $_ompc
  fi
  source $_ompc
  unset _ompc
fi

# Entire CLI shell completion
(( $+commands[entire] )) && source <(entire completion zsh)

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Start Tmux (kept last so the tmux server inherits the full environment)
# if [ "$TMUX" = "" ]; then tm; fi
