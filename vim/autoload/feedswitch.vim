" See LICENSE for license details

"
" Module: autoload/feedswitch.vim
"
" Description:
"       Implementation of feedswitch plugin.
"

" Load this script only once
execute feed#Once("g:loaded_feedswitch_autoload")

"
" Function: feedswitch#Run()
"
" Description:
"       Toggle between source file and header file.
"
" Comments:
"       List of supported extensions
"           h
"           inl
"           cpp
"           c
"           hh
"
"       List of supported search paths
"           .
"           include
"           ..
"
function! feedswitch#Run()

    " Detect file name components
    let [fullpath, justfile, ext] =
        \ [
        \  expand('%:p:h'),
        \  expand('%:t:r'),
        \  expand('%:e')
        \ ]

    " Detect if extension is supported
    if (ext == "h")
        \ || (ext == "inl")
        \ || (ext == "cpp")
        \ || (ext == "c")
        \ || (ext == "hh")

        " Build a list of alternate extensions
        let extensions =
            \ {
            \ 'h':['hh', 'inl', 'cpp', 'c'],
            \ 'inl':['cpp', 'c', 'h', 'hh'],
            \ 'cpp':['h', 'hh', 'inl'],
            \ 'c':['h', 'hh', 'inl'],
            \ 'hh':['inl', 'c', 'cpp', 'h']
            \ }[ext]

        " Scan list of alternate extensions
        for currentExt in extensions

            " Scan list of alternate paths
            for currentSub in ['/./', '/include/', '/../']

                " Build alternate file name
                let newpath = glob(
                    \ simplify(
                    \  fullpath
                    \  . currentSub
                    \  . justfile
                    \  . '.'
                    \  . currentExt))

                " Detect if alternate file exists
                if filereadable(newpath)

                    " Edit the alternate file and exit the script
                    execute 'edit ' . fnameescape(newpath)
                    return

                endif
            endfor
        endfor
    endif
endfun " feedswitch#Run()

" end-of-file: autoload/feedswitch.vim
