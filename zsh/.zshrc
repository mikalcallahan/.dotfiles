#
#   Executes commands at the start of an interactive session.
#
#   Authors:
#   Mikal Callahan <mikal.callahan@icloud.com>
#

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" # prezto config

# iTerm integration 😏
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# tmux integration
export TERM=screen-256color

# set nvim to default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# android studio
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# etcher
export PATH="$PATH:/opt/etcher-cli"


# #alias
alias zshrc='nvim ~/.zshrc' # zshrc gets opened in neovim
alias nvimrc='nvim ~/.dotfiles/nvim/init.vim' # nvimrc to edit init.vim
alias dev='cd ~/Documents/development/' # cd to development folder
alias lsa='ls -a ' # list all files [ * ]
alias brew-backup='brew leaves >> ~/.dotfiles/homebrew/homebrew-packages.txt' #	backup homebrew packages
alias shutdown='automator ~/.dotfiles/automator/shutdown.workflow' # end all applications and shutdown
alias yarn build='npm run-script build' # make things a little more yarn-like
alias vtop='vtop -t monokai' # vtop theme
alias backup='tmutil startbackup' # initiate time machine backup
alias icloud-drive='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs' # cd to icloud Drive
# alias vim=nvim	# vim = nvim
# alias wal-random='wal -i /Users/mikal/Pictures/wallpapers' # wal command for random wal
unsetopt CASE_GLOB
setopt MENU_COMPLETE
# (wal -r &) # load wal colorscheme
## user scripts
print 'Welcome Daddy,' # Print Daddy
# function () {
  # local isMacOS=/Applications/
  # if(cd isMacOs)
#   ~/Documents/developpment/scripts/QuoteScript/QuoteScript # launch QuoteScript [swift scripting]
#}

 
# load pywal colorscheme
# (wal -r) # import colorscheme from wal [run in background '&', hide shell job message '()']

