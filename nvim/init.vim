"
"  Info: (neo)vimrc
"  Author: Mikal Callahan
"  

" 
" config
"
set autoindent                " auto indent
" set autoread                " 
set number                    " display line numbers
filetype on                   " enable filetype
filetype plugin on
set expandtab                 " insert spaces when tab is pressed
set mouse=a                   " mouse mode
map <Tab> :NERDTreeToggle<CR> " nerdtree shortcut with tab
let g:netrw_browse_split = 3  " netrw files open in new tab
let NERDTreeShowHidden = 1    " show hidden files in nerdtree
set showmatch                 " show matching brackets
set shiftwidth=2              " shift is to two spaces
set tabstop=2                 " (hard) tabs are set to 2 spaces
set softtabstop=2             " (soft) tabs are set to 2 spaces
set smartcase                 " smart cases
syntax on                     " syntax on
set wrap                      " wordwrap

"   VIM Plugins
"
call plug#begin('~/.vim/plugged')
" deoplete - autocompletion
if has('nvim')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  else
      Plug 'Shougo/deoplete.nvim'
        Plug 'roxma/nvim-yarp'
          Plug 'roxma/vim-hug-neovim-rpc'
        endif
        let g:deoplete#enable_at_startup = 1
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion for deoplete
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for deoplete
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

Plug 'tpope/vim-haml'               " deoplete - SCSS/SASS syntax highlight
Plug 'mxw/vim-jsx'                  " deoplete - jsx highlighting
Plug 'keith/swift.vim'              " deoplete - swift syntax highlight
Plug 'mitsuse/autocomplete-swift'   " deoplete swift syntax autocomplete
Plug 'posva/vim-vue'                " deoplete - vue.js syntax
Plug 'itchyny/lightline.vim'        " lightline statusbar
Plug 'scrooloose/nerdtree'          " NERDTree File explorer
Plug 'Xuyuanp/nerdtree-git-plugin'  " NERDTree git support
Plug 'wakatime/vim-wakatime'        " wakatime
" Plug 'ap/vim-css-color'           " css colors inline
" Plug 'neomake/neomake'            " neomake real time linter
" Plug 'Shutnik/jshint2.vim'        " JS Linter
" set runtimepath+=~/.vim/bundle/jshint2.vim/
" Plug 'tpope/vim-vinegar'          " Tim Pope's Vinegar
" Plug 'kchmck/vim-coffee-script'   " coffee script highlight
" Plug 'hail2u/vim-css3-syntax'     " css syntax highlight
" augroup VimCSS3Syntax             " vertical align, box shadow, etc syntax
"  autocmd!
"  autocmd FileType css setlocal iskeyword+=-
" augroup END
call plug#end()

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
