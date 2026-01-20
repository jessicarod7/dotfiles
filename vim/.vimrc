call plug#begin()

Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'fladson/vim-kitty'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'

call plug#end()

" Fish shell
set shell=/usr/bin/fish

" Theming
syntax on
set termguicolors
colorscheme catppuccin_macchiato
let g:airline_powerline_fonts = 1
let g:airline#extensions#default#section_truncate_width = {
    \ 'b': 65,
    \ 'x': 55,
    \ 'y': 80,
    \ 'z': 45,
    \ 'warning': 50,
    \ 'error': 50,
    \ }

" For vim-sandwich
nmap s <Nop>
xmap s <Nop>

" Fish shell
autocmd FileType fish setlocal shiftwidth=4 softtabstop=4 expandtab

