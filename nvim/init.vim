"  Info: nvimrc
"  Author: Mikal Callahan
"  

" VIM Plugins
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}       " Coc
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " Fzf
Plug 'junegunn/fzf.vim'                               " Fzf vim
Plug 'junegunn/goyo.vim'                              " Goyo - Distraction free writing
Plug 'dylanaraps/fff.vim'                             " FFF File browser
Plug 'itchyny/lightline.vim'                          " Lightline statusbar
" Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }    " Markdown Preview
Plug 'scrooloose/nerdtree'                            " Nerdtree file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'                    " Nerdtree git plugin
Plug 'ryanoasis/vim-devicons'                         " Nerdtree icons
" Plug 'derekwyatt/vim-scala'                           " Scala syntax
Plug 'junegunn/seoul256.vim'                          " Seoul256 colorscheme
" Plug 'iloginow/vim-stylus'                            " Better Stylus support
" Plug 'sheerun/vim-polyglot'                           " General synxtax for multiple languages
Plug 'dylanaraps/wal.vim'                             " wal colors
call plug#end()

"" General
set number                    " display line numbers
set linebreak                 " Break lines at word
set showbreak=+++             " Wrap-broken line prefix
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
au CursorHold * checktime     " auto reload file when changes detected
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
colorscheme wal

"" COC options
set hidden
set cmdheight=2
set updatetime=100
set shortmess+=c
set signcolumn=yes
"inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>" " tab completion autocomplete
"inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>" " tab reverse completion for autocomplete
"inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>" " tab enter for results

" Use <C-k> to trigger completion.
" inoremap <silent><expr> <C-k> coc#refresh()
" Use <c-space> to trigger completion.
"if has('nvim')
"  inoremap <silent><expr> <c-space> coc#refresh()
"else
"  inoremap <silent><expr> <c-@> coc#refresh()
" endif

" inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.

" inoremap <silent><expr> <TAB>
"      \ coc#pum#visible() ? coc#pum#next(1):
"      \ CheckBackspace() ? "\<Tab>" :
"      \ coc#refresh()

" NOTE: Had trouble with default CheckBackspace implementation when tabbing in
" INSERT mode
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):"\<Tab>"
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

hi link CocFloating Normal
hi CocSearch ctermfg=12 guifg=#18A3FF
hi CocMenuSel ctermbg=11 guibg=#13354A

" GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gd :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Coc-explorer
nmap <space>e :CocCommand explorer<CR>

" Coc-git
" navigate chunks of current buffer
nmap [g <Plug>(coc-git-prevchunk)
nmap ]g <Plug>(coc-git-nextchunk)

" navigate conflicts of current buffer
nmap [c <Plug>(coc-git-prevconflict)
nmap ]c <Plug>(coc-git-nextconflict)

" show chunk diff at current position
nmap gp <Plug>(coc-git-chunkinfo)

" stage chunk
nmap <silent>gs :CocCommand git.chunkStage<CR>
" nmap gs <Plug>(coc-git-chunkstage) " - doesn't work for some reason

" show commit contains current position
nmap gc <Plug>(coc-git-commit)

" create text object for git chunks
omap ig <Plug>(coc-git-chunk-inner)
xmap ig <Plug>(coc-git-chunk-inner)
omap ag <Plug>(coc-git-chunk-outer)
xmap ag <Plug>(coc-git-chunk-outer)


" :Prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
"
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

function! s:show_documentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Coc markdown preview
command! -nargs=0 PreviewMarkdown :call CocActionAsync('runCommand', 'markdown-preview-enhanced.openPreview')

" Coc file explorer
" nnoremap <Tab> <Cmd>CocCommand explorer<CR>

"" Nerdtree options
" nnoremap <Tab> :NERDTree<CR>
let NERDTreeShowHidden = 1    " show hidden files in nerdtree

"" Lightline options
set laststatus=2              " Enable last status
set modeline                  " Enable vim modelines
set noshowmode                " Noshowmode to hide command line
let g:lightline = {
      \ 'colorscheme': 'wal',
      \	'active': {
      \	  'right': [ [ 'percent' ],
      \		     [ 'cocstatus', 'currentfunction', 'filetype' ] ]
      \	},
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ }

let s:palette = g:lightline#colorscheme#{g:lightline.colorscheme}#palette   " hide lightline middle bar
let s:palette.normal.middle = [ [ 'NONE', 'NONE', 'NONE', 'NONE' ] ]        " hide black bar

"" FZF Options
" Use fzf with ripgrep

command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>).'| tr -d "\017"', 1, <bang>0)

" Map esc to clear search highlight
:nnoremap <silent><esc> :noh<CR>

" Search Files with Ctrl-P
nnoremap <C-p> :Files<Cr>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

" Search inside files with Ctrl-F
nnoremap <C-f> :Rg<CR>
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Navigate panes with hjkl
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" FZF ignore node_modules
"let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" Open fff on press of 'f'
nnoremap fff :F<CR>

" Vertical split (NERDtree style).
let g:fff#split = "200vnew"

" Open split on the left side (NERDtree style).
let g:fff#split_direction = "nosplitbelow nosplitright"

"" Cursor Settings kitty
let &t_SI.="\e[5 q" "SI = INSERT mode
let &t_SR.="\e[4 q" "SR = REPLACE mode
let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

" Scala
au BufRead,BufNewFile *.sbt set filetype=scala

