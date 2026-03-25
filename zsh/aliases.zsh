# File system
alias resource="source ~/.zshrc"

if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi

      printf "\U000F17A9 "
      pwd
    fi
  }
fi

if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git
alias gst='git status'

# Tmux
alias ta="tmux attach"
alias tas="tmux attach -d -t"
alias tls="tmux list-sessions"

# Tools
alias flac-to-alac='for name in *.flac; do ffmpeg -nostdin -i "$name" -c:a alac -c:v copy "${name%.*}.m4a"; done'
alias tdlo="tdl opencode"
