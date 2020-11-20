# Enable colors and change prompt:
(cat ~/.cache/wal/sequences &) # wal colorscheme
autoload -U colors && colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v

# localbin
export PATH="${PATH}:${HOME}/.local/bin/"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
    compinit
fi

# case insensitive path-completion 
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 

# fzf x ripgrep
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

###-tns-completion-start-###
#if [ -f /home/mikal/.tnsrc ]; then 
#    source /home/mikal/.tnsrc 
#fi
###-tns-completion-end-###

export NVM_DIR=~/.nvm
PATH="~/.nvm/versions/node/v12.18.4/bin:$PATH"
alias alias nvminit='. "$(brew --prefix nvm)/nvm.sh"'
#source $(brew --prefix nvm)/nvm.sh
export PATH="/usr/local/sbin:$PATH"

alias mongodb-restart="brew services restart mongodb-community"
alias mongodb-stop="brew services stop mongodb-community"

