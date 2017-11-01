"  Info: neovimrc
"  Author: Mikal Callahan

"  Begin neovimrc

" Vim Plug (https://github.com/junegunn/vim-plug)
" Specify a directory for plugins
" - For Neovim ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align' " beautify
Plug 'junegunn/seoul256.vim' " seoul256 colorschme <3
Plug 'Shougo/deoplete.nvim' " nvim keyboard completion
Plug 'keith/swift.vim' " swift syntax highlight
Plug 'mitsuse/autocomplete-swift' " swift syntax autocomplete
Plug 'kchmck/vim-coffee-script' " coffee script highlight
Plug 'wakatime/vim-wakatime' " wakatime
Plug 'itchyny/lightline.vim' " lightline statusbar
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \ }

Plug 'Shutnik/jshint2.vim' " JS Linter
set runtimepath+=~/.vim/bundle/jshint2.vim/

Plug 'hail2u/vim-css3-syntax' " CSS syntax highlight
augroup VimCSS3Syntax
  autocmd!

  autocmd FileType css setlocal iskeyword+=-
augroup END
Plug 'tpope/vim-haml' " SCSS/SASS syntax highlight
" Plug 'scrooloose/nerdtree' " File explorer
" autocmd vimenter * NERDTree " NERDTree open on start

" Initialize plugin system
call plug#end()

" Auto-indent
set autoindent

" Auto reload files changed outside of vim
set autoread

" Display line numbers
set number

" Hide lightline middle bar
let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.inactive.middle = s:palette.normal.middle
let s:palette.tabline.middle = s:palette.normal.middle

" Hide mode (because of lightline)
set noshowmode

" Mouse mode
set mouse=a

" Open files in new tab
let g:netrw_browse_split = 3

" Read file type
filetype on
filetype indent on
filetype plugin on

" Set spell on for file types txt, latex, markdown
autocmd FileType markdown, md, latex, tex, txt, text setlocal spell

" Shift and Tab width
set shiftwidth=2
set softtabstop=2

" Smart cases
set smartcase

" Syntax highlighting
syntax on

" Word Wrap
set wrap

