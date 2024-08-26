# History Configuration
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
setopt share_history

# Zsh Options and Keybindings
unsetopt beep
bindkey -v

# Path and Environment Variables
function add_to_path() {
  [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}

add_to_path "$HOME/.local/bin"
export ANDROID_HOME="$HOME/Library/Android/sdk"
add_to_path "$ANDROID_HOME/emulator"
add_to_path "$ANDROID_HOME/tools"
add_to_path "/usr/local/opt/openjdk@17/bin"

# Case Insensitive Path-Completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  if [[ ! -f ~/.zcompdump || ~/.zcompdump -ot $(brew --prefix)/share/zsh-completions ]]; then
    compinit
  fi
fi

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# brew function for sketchybar
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_update
  fi
}

# fzf with ripgrep or fd
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
else
  export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR=~/.nvm

# fnm
eval "$(fnm env --use-on-cd)"

alias effectquote="node ~/Developer/desktop/effectquote/dist/index.js"
alias mongodb-restart='brew services restart mongodb-community'
alias mongodb-stop='brew services stop mongodb-community'
alias flac-to-alac='for name in *.flac; do ffmpeg -nostdin -i "$name" -c:a alac -c:v copy "${name%.*}.m4a"; done'
alias gst='git status'
alias cat='bat'
alias ls='eza'

# Source iTerm2 Shell Integration if it exists
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Pyenv Initialization
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
alias python=/usr/local/bin/python3

# Initiate startship
eval "$(starship init zsh)"

# Load Angular CLI autocompletion.
source <(ng completion script)

effectquote
