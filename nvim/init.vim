"  Info: nvimrc
"  Author: Mikal Callahan
"  

" VIM Plugins
call plug#begin('~/.vim/plugged')
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion autocomplete
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for autocomplete
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

" Plug 'dense-analysis/ale'            " Ale linting
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'} " autocomplete
Plug '/usr/bin/fzf'                  " Fuzzy Finder searches
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'             " Goyo - Distraction free writing
Plug 'itchyny/lightline.vim'         " lightline statusbar
" Plug 'sbdchd/neoformat'              " neoformat code formatter
" Plug 'neomake/neomake'               " neomake linter
Plug 'scrooloose/nerdtree'           " nerdtree file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'   " nerdtree git plugin
Plug 'junegunn/seoul256.vim'         " seoul256 colorscheme
Plug 'sheerun/vim-polyglot'          " General synxtax for multiple languages
Plug 'dylanaraps/wal.vim'            " Wal colorscheme for vim
" Plug 'ap/vim-css-color'            " css colors inline
" End plugin system
call plug#end()

" When writing a buffer (no delay), and on normal mode changes (after 750ms).
" call neomake#configure#automake('nw', 750)

set autoindent                " auto indent
set autoread                  "
filetype on                   " enable filetype
filetype plugin on
set clipboard^=unnamedplus    " system clipboard
set expandtab                 " insert spaces when tab is pressed
set mouse=a                   " mouse mode
map <Tab> :NERDTree<CR>       " nerdtree shortcut with tab
set modeline                  " enable vim modelines
set noshowmode                " noshowmode to hide command line
set number                    " display line numbers
let NERDTreeShowHidden = 1    " show hidden files in nerdtree
set showmatch                 " show matching brackets
set shiftwidth=2              " amount of spaces per indentaton
set tabstop=2                 " (hard) tabs are set to 2 spaces
set softtabstop=2             " (soft) tabs are set to 2 spaces
set smartcase                 " smart cases
syntax on                     " syntax on
set wrap                      " wordwrap
set laststatus=2

let g:seoul256_background = 235
colo wal

"" COC settings
set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

"" Ale settings
" let g:ale_fixers = {
" \    'javascript': ['eslint'],
" \    'typescript': ['prettier'],
" \    'vue': ['eslint'],
" \    'scss': ['prettier'],
" \    'html': ['prettier']
" \}
" let g:ale_lint_on_text_changed = 'normal' 
" let g:ale_fix_on_save = 1

" highlight long lines
let w:longlines = matchadd('ColorColumn', '\%'.&tw.'v', &tw)
nnoremap <silent> <Leader>ll
    \ :if exists('w:longlines') <Bar>
    \   silent! call matchdelete(w:longlines) <Bar>
    \   unlet w:longlines <Bar>
    \ elseif &textwidth > 0 <Bar>
    \   let w:longlines = matchadd('ColorColumn', '\%'.&textwidth.'v', &textwidth) <Bar>
    \ else <Bar>
    \   let w:longlines = matchadd('ColorColumn', '\%80v', 80) <Bar>
    \ endif <CR>

 
" lightline options
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
" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks
" --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
" --color: Search color options
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)
