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
Plug 'fatih/vim-go'
call plug#end()

set termguicolors
colorscheme narwal

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

let vim_projcalico = "$GOPATH/src/github.com/projectcalico"
let github_projcalico = "github.com/projectcalico"

function SetupGoGuruScopePath(path)
  execute "au BufRead " . g:vim_projcalico . a:path . "/*.go exe 'silent :GoGuruScope " . g:github_projcalico . a:path . "/..."
endfunc

" Golang autocommands.
augroup vimrc_go_aus
        au BufWritePre *.go :GoImports
        :call SetupGoGuruScopePath("/node/cmd")
        :call SetupGoGuruScopePath("/felix/cmd")
        :call SetupGoGuruScopePath("/cni-plugin/cmd")
        :call SetupGoGuruScopePath("/typha/cmd")
        :call SetupGoGuruScopePath("/kube-controllers/cmd")
        :call SetupGoGuruScopePath("/libcalico-go/lib")
augroup END

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
