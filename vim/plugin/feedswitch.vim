" See LICENSE for license details

"
" Module: plugin/feedswitch.vim
"
" Description:
"       Switch between source file and header file
"

" Load this file only once
execute feed#Once("g:loaded_feedswitch_plugin")

" Install a custom command
com! -nargs=0 A call feedswitch#Run()

" Install a normal mode shortcut
nnoremap <silent> <Leader>a :call feedswitch#Run()<cr>

" end-of-file: plugin/feedswitch.vim
