" See LICENSE for license details

"
" Module: autoload/feed.vim
"
" Description:
"       Collection of utility functions for feed plugins.
"

"
" Function: feed#Once
"
" Description:
"       Guard script from multiple sourcing.
"
" Parameters:
"       a:varname
"           Name of a global variable to use as guard
"
" Returns:
"       String to execute by calling script.
"
" Examples:
"       execute feed#Once("g:loaded_myscript")
"
function! feed#Once(varname)
    if exists(a:varname)
        return "finish"
    endif
    execute "let " . a:varname . "=1"
    return ""
endfunction

" end-of-file: autoload/feed.vim
