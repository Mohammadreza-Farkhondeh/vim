set nocompatible

filetype plugin indent on

set number " Turn on line numbering
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set clipboard=unnamedplus
set mouse=a
set noswapfile " Disable swap files
set encoding=utf-8 " Use UTF-8 encoding
set textwidth=100 " Wrap text at 100 characters

syntax on

highlight BadWhitespace ctermbg=red guibg=red
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/


set backspace=indent,eol,start

au BufNewFile *.py,*.pyw,*.c,*.h set fileformat=unix

if (has("termguicolors"))
    set termguicolors
endif

set background=dark

