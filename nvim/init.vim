"  Info: nvimrc
"  Author: Mikal Callahan
"  

" VIM Plugins
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}       " Coq
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " Fzf
Plug 'junegunn/fzf.vim'                               " Fzf vim
Plug 'junegunn/goyo.vim'                              " Goyo - Distraction free writing
Plug 'dylanaraps/fff.vim'                             " FFF File browser
Plug 'itchyny/lightline.vim'                          " Lightline statusbar
Plug 'scrooloose/nerdtree'                            " Nerdtree file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'                    " Nerdtree git plugin
Plug 'ryanoasis/vim-devicons'                         " Nerdtree icons
Plug 'junegunn/seoul256.vim'                          " Seoul256 colorscheme
Plug 'sheerun/vim-polyglot'                           " General synxtax for multiple languages
Plug 'dylanaraps/wal.vim'                             " Wal colorscheme for vim
call plug#end()

"" General
set number                    " display line numbers
set linebreak                 " Break lines at word
set showbreak=+++             " Wrap-broken line prefix
set textwidth=100             " Line wrap at 100 columns
set showmatch                 " Highlight matching brackets
set visualbell                " Because we don't need audio
set mouse=a                   " Mouse mode
set clipboard^=unnamedplus    " System clipboard

set hlsearch                  " Highlights all search results
set smartcase                 " Smart-case search
set ignorecase                " Ignore case-sensitivity
set incsearch                 " Searches for strings incrementally

set autoindent                " Set auto indent
set autoread                  " Detect file changes outside of vim
set expandtab                 " Use spaces instead of tabs
set shiftwidth=2              " Number of auto-indent spaces
set smartindent               " Enable smart indent
set smarttab                  " Enable smart tabs
set softtabstop=2             " Number of spaces per tab
set wrap                      " Wordwrap

syntax on                     " Syntax on
filetype on                   " Enable filetype
filetype plugin on            " Enable filetype

" Set colors
let g:seoul256_background = 235
colo wal

"" COC options
set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion autocomplete
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for autocomplete
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

"" Nerdtree options
nnoremap <Tab> :NERDTree<CR>
let NERDTreeShowHidden = 1    " show hidden files in nerdtree

"" Lightline options
set laststatus=2              " Enable last status
set modeline                  " Enable vim modelines
set noshowmode                " Noshowmode to hide command line
let g:lightline = {
      \ 'colorscheme': 'wal',
      \	'active': {
      \	  'right': [ [ 'percent' ],
      \		     [ 'filetype' ] ]
      \	},
      \ }
let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette   " hide lightline middle bar
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]        " hide black bar


" FZF x Ripgrep
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)

" Search Files with Ctrl-P
nnoremap <C-p> :Files<Cr>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

" FZF ignore node_modules
"let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" Open fff on press of 'f'
nnoremap f :F<CR>

" Vertical split (NERDtree style).
let g:fff#split = "200vnew"

" Open split on the left side (NERDtree style).
let g:fff#split_direction = "nosplitbelow nosplitright"
