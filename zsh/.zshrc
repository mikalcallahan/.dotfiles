HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v

# autoload -U colors && colors
# PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# localbin, android, path, etc
export PATH="${PATH}:${HOME}/.local/bin/"
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH
export ANDROID_HOME="/Users/mikal/Library/Android/sdk"

# case insensitive path-completion 
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
    compinit
fi

# zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# brew function for sketchybar
function brew() {
  command brew "$@" 

  if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
    sketchybar --trigger brew_update
  fi
}

# fzf x ripgrep
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###-tns-completion-start-###
#if [ -f /home/mikal/.tnsrc ]; then 
#    source /home/mikal/.tnsrc 
#fi
###-tns-completion-end-###

export NVM_DIR=~/.nvm
# #PATH="~/.nvm/versions/node/v12.18.4/bin:$PATH"
# alias alias nvminit='. "$(brew --prefix nvm)/nvm.sh"'
# # source $(brew --prefix nvm)/nvm.sh
# export PATH="/usr/local/sbin:$PATH"

# fnm
eval "$(fnm env --use-on-cd)"

# Run 'fff' with 'f' or whatever you decide to name the function.
# CD on exit
f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

alias effectquote="node ~/Developer/desktop/effectquote/dist/index.js"
alias mongodb-restart='brew services restart mongodb-community'
alias mongodb-stop='brew services stop mongodb-community'
alias flac-to-alac='for name in *.flac; do ffmpeg -nostdin -i "$name" -c:a alac -c:v copy "${name%.*}.m4a"; done'
alias gst='git status'
alias cat='bat'
alias ls='eza'

effectquote

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export NNN_COLORS="2136"                           # use a different color for each context

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
alias python=/usr/local/bin/python3

# Initiate startship
eval "$(starship init zsh)"
export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
