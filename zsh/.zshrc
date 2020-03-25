export PATH="${PATH}:${HOME}/.local/bin/"
(cat ~/.cache/wal/sequences &) # wal colorscheme

#export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
#export PATH=${PATH}:${JAVA_HOME}bin
#export ANDROID_HOME="/home/mikal/.androidstudio/sdk/"
#export PATH="${PATH}:${ANDROID_HOME}tools/:${ANDROID_HOME}platform-tools/"

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mikal/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
#

# fzf x ripgrep
# --files: List files that would be searched but do not search
# --no-ignore: Do not respect .gitignore, etc...
# --hidden: Search hidden files and folders
# --follow: Follow symlinks
# --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

# Source NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

alias gotop="gotop-cjbassi"

conscient

###-tns-completion-start-###
if [ -f /home/mikal/.tnsrc ]; then 
    source /home/mikal/.tnsrc 
fi
###-tns-completion-end-###

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
