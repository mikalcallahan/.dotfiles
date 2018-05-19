"  Info: neovimrc
"  Author: Mikal Callahan
"
"  Begin neovimrc


" PLUGINS
" --------------------
" Specify a directory for plugins
call plug#begin('~/.local/share/nvim/plugged')

" A E S T H E T I C S ~~~~
Plug 'junegunn/seoul256.vim' " seoul256 colorschme <3
Plug 'ap/vim-css-color' " css colors inline
Plug 'itchyny/lightline.vim' " lightline statusbar

" Autocomplete :
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " nvim keyboard completion
let g:deoplete#enable_at_startup = 1 " run deoplete at startup
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion for deoplete
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for deoplete
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

" Language Syntax :
Plug 'kchmck/vim-coffee-script' " coffee script highlight
Plug 'hail2u/vim-css3-syntax' " css syntax highlight
augroup VimCSS3Syntax " vertical align, box shadow, etc syntax
  autocmd!
  autocmd FileType css setlocal iskeyword+=-
augroup END
Plug 'mxw/vim-jsx' " jsx highlighting
Plug 'keith/swift.vim' " swift syntax highlight
Plug 'tpope/vim-haml' " SCSS/SASS syntax highlight
Plug 'mitsuse/autocomplete-swift' " swift syntax autocomplete
Plug 'posva/vim-vue' " vue syntax

" Linting :
Plug 'neomake/neomake' " neomake real time linter
" Plug 'Shutnik/jshint2.vim' " JS Linter
" set runtimepath+=~/.vim/bundle/jshint2.vim/

" Extras :
Plug '/usr/local/opt/fzf' " fuzzy finder
Plug 'scrooloose/nerdtree' " NERDTree File explorer
Plug 'Xuyuanp/nerdtree-git-plugin' " NERDTree git support
Plug 'tpope/vim-vinegar' " Tim Pope's Vinegar
Plug 'wakatime/vim-wakatime' " wakatime

" End plugin system
call plug#end()

" CONFIG
" --------------------
"
set autoindent " auto indent 
set autoread " auto reload files changed outside of vim
" set noh " disable search highlights until next search
set number " display line numbers
set expandtab " insert spaces when tab is used
set mouse=a " (mickey) mouse mode on
let g:netrw_browse_split = 3 " open netrw files in new tab
filetype plugin on " plugins for file type
filetype on " read file type
autocmd FileType md, latex, tex, txt, text setlocal spell " spellcheck for file types txt, latex, markdown
set showmatch " show matching brackets
set shiftwidth=2 " shift width = 2 [ < and > commands ]
set tabstop=2 " hard tabs = 2 spaces
set softtabstop=2 " soft tabs = 2 spaces
set smartcase " smart cases
syntax on " syntax highlight
set wrap " word wrap

" Lightline Config
"
set noshowmode " hide bottom bar (because of lightline)
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \	'active': {
      \	  'right': [ [ 'percent' ],
      \		     [ 'filetype' ] ]
      \	},
      \ }
let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette  " hide lightline middle bar
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]
let s:palette.inactive.middle = s:palette.normal.middle
let s:palette.tabline.middle = s:palette.normal.middle

