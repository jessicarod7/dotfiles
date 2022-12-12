call plug#begin()

Plug 'arcticicestudio/nord-vim'
Plug 'fladson/vim-kitty'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-sleuth'
Plug 'vim-airline/vim-airline'

call plug#end()

" Theming
syntax on
colorscheme nord
let g:airline_powerline_fonts = 1

" For vim-sandwich
nmap s <Nop>
xmap s <Nop>

" Python
autocmd FileType python setlocal shiftwidth=4 expandtab
