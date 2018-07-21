"  Info: (neo)vimrc
"  Author: Mikal Callahan
"  

" 
" config
"

"   VIM Plugins
"
call plug#begin('~/.vim/plugged')
" deoplete - autocompletion
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  " Plug 'Shougo/deoplete.nvim'
  " Plug 'roxma/nvim-yarp'
  " Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion for deoplete
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for deoplete
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

Plug 'mxw/vim-jsx'                  " jsx highlighting
Plug 'pangloss/vim-javascript'      " JS syntax highlight
Plug 'keith/swift.vim'              " swift syntax highlight
Plug 'mitsuse/autocomplete-swift'   " swift syntax autocomplete
Plug 'posva/vim-vue'                " vue.js syntax
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'itchyny/lightline.vim'        " lightline statusbar
Plug 'scrooloose/nerdtree'          " NERDTree File explorer
Plug 'Xuyuanp/nerdtree-git-plugin'  " NERDTree git support
Plug 'neomake/neomake'              " neomake linter
Plug 'tpope/vim-haml'               " SCSS/SASS syntax highlight
" Plug 'ap/vim-css-color'           " css colors inline
" Plug 'Shutnik/jshint2.vim'        " JS Linter
" set runtimepath+=~/.vim/bundle/jshint2.vim/

" End plugin system
call plug#end()


call neomake#configure#automake('rw', 1000) " call neomake on read and write
set autoindent                " auto indent
" set autoread                "
set number                    " display line numbers
filetype on                   " enable filetype
filetype plugin on
set expandtab                 " insert spaces when tab is pressed
set mouse=a                   " mouse mode
map <Tab> :NERDTreeToggle<CR> " nerdtree shortcut with tab
let g:netrw_browse_split = 3  " netrw files open in new tab
set noshowmode                " noshowmode to hide command line
let NERDTreeShowHidden = 1    " show hidden files in nerdtree
set showmatch                 " show matching brackets
set shiftwidth=2              " shift is to two spaces
set tabstop=2                 " (hard) tabs are set to 2 spaces
set softtabstop=2             " (soft) tabs are set to 2 spaces
set smartcase                 " smart cases
syntax on                     " syntax on
set wrap                      " wordwrap

"
" lightline options
"
let g:lightline = {
      \ 'colorscheme': 'seoul256',
      \	'active': {
      \	  'right': [ [ 'percent' ],
      \		     [ 'filetype' ] ]
      \	},
      \ }
let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette   " hide lightline middle bar
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]        " hide black bar
