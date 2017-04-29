" See LICENSE for license details

"   Module: plugin/feedlist.vim
"
"   Description:
"       Generic explorer for buffers, files, etc.
"
"   Comments:
"
"       .   Use of dictionary objects with object methods
"       .   Move logic from callbacks to main entry points (build buffer name and refresh)
"       .   Implement open for tags
"       .   Custom parsing of tags files
"       .   Support for project root folder for svnstatus and svnlist and svnlog
"       .   Display file names with short name and path seperate
"       .   Move code to autoload for this plugin
"       .   Add support for \d inplace svn diff of current file

" load only once
execute feed#Once("g:loaded_feedlist_plugin")

"   Function: FeedListFileBufEnter() {
"
"   Description:
"       BufEnter event handler to detect directories.
"
"   Parameters:
"       name            Buffer name to detect
"
"   Comments:
"       .   If buffer name is detected as a directory then overwrite the buffer
"           with our file explorer.
"       .   If buffer name is not a directory, then exit this event as quickly
"           as possible.
"       .   This event handler must be fast because it is executed for every
"           buffer

fun! FeedListFileBufEnter(name)
    if isdirectory(a:name)
        call feedlist#FileBufEnter(a:name)
    endif
endfun "}

"   Section: auto commands {

augroup FeedList

    " Clear existing auto commands from group
    autocmd!

    " Setup BufEnter event handler to detect directories
    autocmd BufEnter * call FeedListFileBufEnter(expand('<amatch>'))

augroup NONE "}

"   Section: Buffer explorer {

" Install :L user command to launch buffer explorer
command! -nargs=0 L call feedlist#Buffer()

" Install <leader>l command to launch buffer explorer
nnoremap <silent> <leader>l :call feedlist#Buffer()<cr>

" }

"   Section: File Explorer {

" Install :F user command to launch file explorer
command! -nargs=* -complete=file F call feedlist#File(<f-args>)

" Install <leader>f mapping to launch file explorer
nnoremap <silent> <leader>f :call feedlist#File()<cr>

" Launch a diff between two files or two buffers
command! -nargs=* -complete=file D call feedlist#FileDiff(<f-args>)

" }

" end-of-file: plugin/feedlist.vim
