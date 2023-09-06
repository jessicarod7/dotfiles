call plug#begin()

Plug 'nordtheme/vim'
Plug 'fladson/vim-kitty'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'

call plug#end()

" Theming
syntax on
colorscheme nord
" For Windows
" set termguicolors
let g:airline_powerline_fonts = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1
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

" Python
autocmd FileType python setlocal shiftwidth=4 expandtab

