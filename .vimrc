set noswapfile

set smartcase

syntax on

set showmatch

set noerrorbells
set novisualbell
set t_vb=
set tm=50

set hls
nnoremap <CR><CR> :noh<CR><CR>

filetype plugin indent on

call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

" Enable Golang syntax highlighting
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_operators = 1

let g:go_fmt_command = "goimports -w"
let g:go_addtags_transform = "camelcase"

set timeout timeoutlen=2000 ttimeoutlen=2000

" Set hidden
set hidden

set maxmempattern=4096

" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

au BufWritePre *.go :GoImports

" Delete trailing white spaces for any file we write.
au BufWritePre * :call DeleteTrailingWS()

" Show interfaces which are implemented by the type under cursor.
au FileType go nmap <Leader>s <Plug>(go-implements)

" Show potential implementations of the function under the cursor.
au FileType go nmap <Leader>f <Plug>(go-callees)

" Show potential callers of the function under the cursor.
au FileType go nmap <Leader>c <Plug>(go-callers)

" Show type info for the word under cursor.
au FileType go nmap <Leader>i <Plug>(go-info)
