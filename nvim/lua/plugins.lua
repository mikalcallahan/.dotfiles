local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.vim/plugged')

-- coc
Plug('neoclide/coc.nvim', { branch = 'release' })

-- fzf
Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install'] })
Plug 'junegunn/fzf.vim'                               -- Fzf vim

-- goyo
Plug 'junegunn/goyo.vim'                              -- Goyo - Distraction free writing

-- fff
Plug 'dylanaraps/fff.vim'                             -- FFF File browser

-- lightline
Plug 'itchyny/lightline.vim'                          -- Lightline statusbar

-- nerdtree
Plug 'scrooloose/nerdtree'                            -- Nerdtree file explorer
Plug 'Xuyuanp/nerdtree-git-plugin'                    -- Nerdtree git plugin

-- devicons
Plug 'ryanoasis/vim-devicons'                         -- Nerdtree icons

-- colorschemes
Plug 'junegunn/seoul256.vim'                          -- Seoul256 colorscheme
Plug 'dylanaraps/wal.vim'                             -- wal colors

-- Dashboard
Plug 'goolord/alpha-nvim'

vim.call('plug#end')
