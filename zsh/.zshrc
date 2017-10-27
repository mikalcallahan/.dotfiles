#
#   Executes commands at the start of an interactive session.
#
#   Authors:
#   Mikal Callahan <mikal.callahan@icloud.com>
#


# iTerm integration 😏
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# alias
alias zshrc='nvim ~/.zshrc' # zshrc gets opened in neovim
alias csusm='cd ~/Documents/school/csusm' # cd to csusm
alias web='cd ~/Documents/programming/web' # cd to web
alias ios='cd ~/Documents/programming/iOS' # cd to iOS
alias scripts='cd ~/Documents/programming/scripts' # cd to scripts
alias mc='cd ~/Documents/school/mira\ costa' # cd to mira costa
alias nvimrc='nvim ~/.config/nvim/init.vim' # nvimrc to edit init.vim
alias lh='ls -d .*' # show hidden files/directories only
alias brew-backup='brew leaves >> ~/.dotfiles/homebrew/homebrew-packages.txt' #	backup homebrew packages
#alias brewfont='brew cask install caskroom/fonts/' # shortcut to install fonts a lil easier
# alias vim=nvim	# vim = nvim
# alias wal-random='wal -i /Users/mikal/Pictures/wallpapers' # wal command for random wal
# alias python-server='python -m SimpleHTTPServer 8000' # simple python server

# user scripts
print 'Welcome Daddy,' # Print Daddy
~/Documents/programming/scripts/QuoteScript/QuoteScript # launch QuoteScript [swift scripting]

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" # prezto config
