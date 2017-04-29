" See LICENSE for license details

"   Module: feedlist.vim
"
"   Description:
"       Generic explorer for buffers, files, etc.
"
"   Comments:
"
"       .   Use of dictionary objects with object methods
"       .   Move logic from callbacks to main entry points (build buffer name and refresh)
"       .   Support for project root folder
"       .   Display file names with short name and path seperate
"       .   Move code to autoload for this plugin
"       .   Use BufEnter event for edit of folder
"       .   Use keepalt while changing folders or buffers
"

" load only once
execute feed#Once("g:loaded_feedlist_autoload")

"   Function: feedlist#LayoutCmd() {
"
fun! feedlist#LayoutCmd(buf_array, cmd)
    if a:cmd ==# 'o'
        silent wincmd o
    elseif a:cmd ==# 'h'
        silent wincmd h
    elseif a:cmd ==# 'l'
        silent wincmd l
    elseif a:cmd ==# 'k'
        silent wincmd k
    elseif a:cmd ==# 'j'
        silent wincmd j
    elseif a:cmd ==# '='
        silent wincmd =
    elseif a:cmd ==# '0'
        silent exec 'keepalt buffer ' . a:buf_array[0]
    elseif a:cmd ==# '1'
        silent exec 'keepalt buffer ' . a:buf_array[1]
    elseif a:cmd ==# '2'
        silent exec 'keepalt buffer ' . a:buf_array[2]
    elseif a:cmd ==# '3'
        silent exec 'keepalt buffer ' . a:buf_array[3]
    elseif a:cmd ==# '4'
        silent exec 'keepalt buffer ' . a:buf_array[4]
    elseif a:cmd ==# '5'
        silent exec 'keepalt buffer ' . a:buf_array[5]
    elseif a:cmd ==# '6'
        silent exec 'keepalt buffer ' . a:buf_array[6]
    elseif a:cmd ==# 'd'
        diffthis
        silent! nnoremap <buffer> <silent> q :<c-u>tabc<cr>
    elseif a:cmd ==# '^'
        silent aboveleft split
    elseif a:cmd ==# 'v'
        silent belowright split
    elseif a:cmd ==# '<'
        silent vertical aboveleft split
    elseif a:cmd ==# '>'
        silent vertical belowright split
    elseif a:cmd ==# 't'
        silent tab split
    endif
endfun "}

"   Function: feedlist#Layout() {
"
"   Comments:
"       'o' fullscreen window
"       'h' goto window to the left
"       'j' goto window below
"       'k' goto window above
"       'l' goto window to the right
"       '=' adjust size of all windows
"       '0' select buffer 0 (cur)
"       '1' select buffer 1 (left)
"       '2' select buffer 2 (right)
"       'd' diffthis
"       '^' split horizontal above
"       'v' split horizontal below
"       '<' split vertical left
"       '>' split vertical right
"       't' new tab
"
fun! feedlist#Layout(buf_array, layout)
    let n = len(a:layout)
    let i = 0
    while i < n
        let cmd = a:layout[i]
        call feedlist#LayoutCmd(a:buf_array, cmd)
        let i += 1
    endwhile
endfun "}

"   Function: feedlist#BuildLineString {
"
"
fun! feedlist#BuildLineString(item)
    let item_index = a:item.index
    let item_file = a:item.file
    if b:object.type == 'diff'
        let a:item.display = printf("%5d", item_index) . ' | ' . a:item.diff_flags . ' | ' . item_file
    elseif b:object.type == 'file'
        if item_file[-1:-1] == '/'
            let item_file = substitute(item_file[:-2], '[^/]\+\/', '| ', 'g') . '/'
        else
            let item_file = substitute(item_file[:-1], '[^/]\+\/', '| ', 'g')
        endif
        if has_key(a:item, 'select') && a:item.select
            let a:item.display = printf("%5d", item_index) . " | " . item_file . '*'
        else
            let a:item.display = printf("%5d", item_index) . " | " . item_file
        endif
    else
        let a:item.display = printf("%5d", item_index) . " | " . item_file
    endif
endfun "}

"   Function: feedlist#DisplayLine {
"
"   Description:
"       Refresh line of explorer window
"
"   Parameters:
"       line_index
"           Index of line in output buffer
"       file_index
"           Index of line in input list
"       single_file
"           Content to display at current line
"
fun! feedlist#DisplayLine(line_index, item)

    " Apply to actual buffer
    call setline(a:line_index, a:item.display)

endfun "}

"   Function: feedlist#Display {
"
"   Description:
"       Refresh contents of explorer window
"
"   Parameters:
"       pattern
"           Optional regular expression to filter lines
"
fun! feedlist#Display()

    setlocal modifiable

    " Remember cursor position
    let l:old_pos = getpos('.')

    " First clear all existing lines
    silent! %delete _

    " Start at line 1 of output
    let l:line_index = 1

    " Loop for all lines in input list
    for l:item in b:object.lines

        " Filter lines by undo level
        if l:item.level >= b:object.level

            " When a pattern is applied, reset level
            if "" != b:object.filter
                let l:item.level = b:object.level
            endif

            " Filter using pattern, empty pattern will match all lines
            if l:item.file =~ b:object.filter

                " Increment the undo level when pattern matches
                if "" != b:object.filter
                    let l:item.level = b:object.level + 1
                endif

                " Print a line to output buffer
                call feedlist#DisplayLine(l:line_index, l:item)

                " Increment index of output line
                let l:line_index += 1
            endif
        endif

    endfor

    " Restore cursor position
    call setpos('.', l:old_pos)

    setlocal nomodifiable

    redraw!
endfun "}

" Function: feedlist#AddListingItem() {
fun! feedlist#AddListingItem(index, name)
    let item = {}
    let item.index = a:index
    let item.level = 0
    let item.file = a:name
    call add(b:object.lines, item)
    let b:object.line_count += 1
    return item
endfun "}

" Function: feedlist#RefreshFileListing {
"
fun! feedlist#RefreshFileListing()
    let l:working_directory = expand('%:p:h')
    if l:working_directory ==# '/'
    else
        let l:working_directory .= '/'
    endif
    if has_key(b:object, 'flat') && b:object.flat
        " let l:directory_listing = system(" cd " . l:working_directory . " && ag -g . | head -n10000 ")
        " use of find
        let l:directory_listing = system("find " . l:working_directory . " -not \\( \\( -path '*.git' -o -path '*.git' \\) -prune \\) | head -n1000")
        let l:directory_files = split(l:directory_listing, '\n')
        let l:file_count = len(l:directory_files)
        if l:file_count
            " first entry is current directory
            let l:first_line_len = len(l:directory_files[0])
            let l:index = 1
            while l:index < l:file_count
                let l:item = l:directory_files[l:index]
                " detect if current entry is a folder
                if l:index + 1 < l:file_count
                    if l:item ==# fnamemodify(l:directory_files[l:index + 1], ':h')
                        let l:item .= '/'
                    endif
                endif
                call feedlist#AddListingItem(l:index, l:item[(l:first_line_len) : ])
                let l:index += 1
            endwhile
        endif
    else
        let l:directory_listing = system("ls -Ap --group-directories-first " . fnameescape(l:working_directory))
        let l:directory_files = split(l:directory_listing, '\n')
        let l:index = 1
        for l:item in l:directory_files
            call feedlist#AddListingItem(l:index, l:item)
            let l:index += 1
        endfor
    endif
endfun "}

" Function: feedlist#RefreshBufferListing() {
"
fun! feedlist#RefreshBufferListing()
    let l:index = 1
    let l:buf_count = bufnr("$")
    let l:buf_current = bufnr("%")
    while l:index <= l:buf_count
        if bufexists(l:index) && (l:index != l:buf_current)
            call feedlist#AddListingItem(l:index, bufname(l:index))
        endif
        let l:index += 1
    endwhile
endfun "}

"   Function: feedlist#ProcessDiffLine() {
function! feedlist#ProcessDiffLine(item, folder1, folder2)
    let l:diff_entry = ['-', 'dummy']
    let l:pos = matchend(a:item, '^Only in ')
    if -1 != l:pos
        let l:pos_colon = stridx(a:item, ':')
        let l:only_path = a:item[l:pos : (l:pos_colon-1)]
        let l:only_file = a:item[(l:pos_colon+2) : ]
        let l:only_full = fnamemodify(l:only_path, ':p') . l:only_file
        if l:only_full =~ '^' . a:folder1
            let l:diff_entry = ['l', l:only_full[len(a:folder1) : ] ]
        elseif l:only_full =~ '^' . a:folder2
            let l:diff_entry = ['r', l:only_full[len(a:folder2) : ] ]
        endif
    else
        let l:pos = matchend(a:item, '^Files ')
        if -1 != l:pos
            let l:pos_colon = match(a:item, ' and ')
            let l:files_left = a:item[l:pos : (l:pos_colon-1)]
            let l:pos_end1 = match(a:item, '\s* differ\s*$')
            if -1 != l:pos_end1
                let l:diff_entry = ['d', l:files_left[len(a:folder1) : ] ]
            else
                let l:pos_end2 = match(a:item, '\s* are identical\s*$')
                if -1 != l:pos_end2
                    let l:diff_entry = ['e', l:files_left[len(a:folder1) : ] ]
                endif
            endif
        endif
    endif
    return l:diff_entry
endfunction "}

"   Function: feedlist#RefreshDiffReport() {
function! feedlist#RefreshDiffReport(folder1, folder2)

    " Execute external shell command to get text report of all diffs
    let l:diff_text = system('diff -q -r -x .git ' . a:folder1 . ' ' . a:folder2)
    " let l:diff_text = system('diff -q -r -w -x ''obj*'' -x ''build*'' -x ''*.obj'' -x ''*.o'' -x ''*.exe'' ' . a:folder1 . ' ' . a:folder2)

    " Split the report into lines
    let l:diff_lines = split(l:diff_text, '\n')

    " Start with empty array
    let l:data = []

    " Process each line
    for l:item in l:diff_lines

        " Transform single line of report into entry
        let l:diff_entry = feedlist#ProcessDiffLine(l:item, a:folder1, a:folder2)

        " Store entry into array
        call add(l:data, l:diff_entry)

    endfor

    " Return array of entries
    return l:data

endfunction "}

"   Function: feedlist#RefreshDiffListing() {
fun! feedlist#RefreshDiffListing()

    let l:folder1 = b:object.args[0]

    let l:folder2 = b:object.args[1]

    " Create an array of entries
    let l:data = feedlist#RefreshDiffReport(l:folder1, l:folder2)

    let l:index = 1
    for l:item in l:data
        let item_added = feedlist#AddListingItem(l:index, l:item[1])
        let item_added.diff_flags = l:item[0]
        let l:index += 1
    endfor

endfun "}

" Function: feedlist#RefreshListing() {
"
fun! feedlist#RefreshListing()

    " Create database of lines
    let b:object.lines = []
    let b:object.line_count = 0
    if has_key(b:object, 'method_refresh')
        call b:object.method_refresh()
    endif

    " Refresh displayed string
    for l:item in b:object.lines
        call feedlist#BuildLineString(l:item)
    endfor

endfun "}

"   Function: feedlist#GetSelectedLine() {
fun! feedlist#GetSelectedLine(count)
    if a:count == 0
        let l:current_line = line('.') - 1
        for l:item in b:object.lines
            if l:item.level >= b:object.level
                if 0 == l:current_line
                    return l:item
                endif
                let l:current_line -= 1
            endif
        endfor
    else
        let l:selected_index = a:count
        for l:item in b:object.lines
            if l:item.index == l:selected_index
                return l:item
            endif
        endfor
    endif
    return {}
endfun "}

"   Function: feedlist#BuildPattern {
"
"   Description:
"       Build a fuzzy search pattern.
"
fun! feedlist#BuildPattern(key, pattern)
    let l:fuzzy = ""
    let l:pattern_len = strlen(a:pattern)
    if 0 != l:pattern_len
        if a:key ==# '/'
            let l:fuzzy = a:pattern
        elseif a:key ==# 'f'
            let i = 0
            while i < l:pattern_len
                let l:fuzzy .= escape(a:pattern[i], '\.') . "[^" . escape(a:pattern[i], '\.') . "]\\{-}"
                let i += 1
            endwhile
        elseif a:key ==# 'F'
            let i = 0
            while i < l:pattern_len
                if '\' != a:pattern[i]
                    let l:fuzzy .= escape(a:pattern[i], '.') . "[^" . escape(a:pattern[i], '.') . "\\\\]\\{-}"
                endif
                let i += 1
            endwhile
        endif
    endif
    return l:fuzzy
endfun "}

"   Function: feedlist#KeyUndo() {
fun! feedlist#KeyUndo()
    if b:object.level > 0
        let b:object.level -= 1
        let b:object.filter = ''
        call feedlist#Display()
    endif
endfun "}

"   Function: feedlist#KeyRedo() {
fun! feedlist#KeyRedo()
    if b:object.level < b:object.level_max
        let b:object.level += 1
        let b:object.filter = ''
        call feedlist#Display()
    endif
endfun "}

"   Function: feedlist#KeyOpen() {
fun! feedlist#KeyOpen(item, key)
    let buf_right = -1
    let l:item = a:item
    let l:selected_file = l:item.file
    let cur = bufnr('%')
    if b:object.type == "file"
        let l:working_folder = b:object.args
        if l:working_folder[-1:-1] != '/'
            let l:working_folder .= '/'
        endif
        exec 'edit ' . fnameescape(l:working_folder . l:selected_file)
    elseif b:object.type == "buffer"
        if bufexists(l:item.index)
            exec 'keepalt buffer ' . l:item.index
        endif
    elseif b:object.type == 'diff'
        let l:selected_left = b:object.args[0] . l:selected_file
        let l:selected_right = b:object.args[1] . l:selected_file
        " Diff two files
        silent! exec 'silent! edit! ' . l:selected_right
        let buf_right = bufnr('%')
        silent! exec 'silent! edit! ' . l:selected_left
        let buf_left = bufnr('%')
        exec 'silent! buffer ' . cur
        if a:key ==# 'o'
            let l:layout = 't0^1d>02dh'
        elseif a:key ==# 'O'
            let l:layout = 't0<1d>02dh'
        elseif a:key ==# 'p'
            let l:layout = 't0^1d>02dhj'
        elseif a:key ==# 'P'
            let l:layout = 't0<1d>02dl'
        else
            let l:layout = 't01d>02dh'
        endif
        call feedlist#Layout([cur, buf_left, buf_right], l:layout)
        return
    endif
    let new = bufnr('%')
    if (cur != new)
        exec 'silent! keepalt buffer ' . cur
        if a:key ==# 'o'
            let l:layout = '^1'
        elseif a:key ==# 'O'
            let l:layout = '<1'
        elseif a:key ==# 'p'
            let l:layout = '^1j'
        elseif a:key ==# 'P'
            let l:layout = '<1l'
        else
            let l:layout = '1'
        endif
        call feedlist#Layout([cur, new], l:layout)
    else
        echo "invalid index"
    endif
endfun "}

"   Function: feedlist#KeyDelete() {
fun! feedlist#KeyDelete(item, key)
    let l:item = a:item
    if bufexists(l:item.index)
        exec "bwipeout " . l:item.index
        " Remove the line from the lists...
        let l:item_iterator = 0
        while l:item_iterator < b:object.line_count
            if l:item.index == b:object.lines[l:item_iterator].index
                call remove(b:object.lines, l:item_iterator)
                break
            endif
            let l:item_iterator += 1
        endwhile
        let b:object.line_count -= 1
        " Do a final refresh
        call feedlist#Display()
    else
        echo "invalid buffer index"
    endif
endfun "}

"   Function: feedlist#KeyRefresh() {
"
"
"
fun! feedlist#KeyRefresh()
    call feedlist#RefreshListing()
    let b:object.level = 0
    let b:object.level_max = 0
    call feedlist#Display()
endfun "}

"   Function: feedlist#KeyUp() {
fun! feedlist#KeyUp()
    if b:object.type == 'file'
        let l:parent_folder = expand('%:p:h:h')
        if l:parent_folder != ''
            silent! exec 'edit ' . l:parent_folder
        endif
    else
        echo "no parent folder"
    endif
endfun "}

"   Function: feedlist#KeyFilter() {
"
"
"
"
"
fun! feedlist#KeyFilter(key)
    let l:continue_main_loop = 1
    let l:current_filter = ""
    let l:current_filter_len = 0
    let l:match_added = 0
    while l:continue_main_loop
        " Display a user prompt
        let l:current_fuzzy = feedlist#BuildPattern(a:key, l:current_filter)
        let b:object.filter = l:current_fuzzy
        if "" != l:current_fuzzy
            let l:match_added = matchadd("IncSearch", '\c'.l:current_fuzzy, 1)
        endif
        call feedlist#Display()
        echo "/" . l:current_filter
        " Get input from user
        let l:user_key_number = getchar()
        let l:user_key_string = nr2char(l:user_key_number)
        if "\<esc>" == l:user_key_string
            let l:continue_main_loop = 0
        elseif "\<bs>" == l:user_key_number
            if l:current_filter_len > 1
                let l:current_filter = l:current_filter[ 0 : (l:current_filter_len - 2) ]
                let l:current_filter_len -= 1
            elseif l:current_filter_len == 1
                let l:current_filter = ''
                let l:current_filter_len = 0
            else
                let l:continue_main_loop = 0
            endif
        elseif "\<cr>" == l:user_key_string
            if "" != l:current_filter
                let b:object.level = b:object.level + 1
                let b:object.level_max = b:object.level
            endif
            let l:continue_main_loop = 0
        elseif l:user_key_string =~ '\p'
            let l:current_filter = l:current_filter . l:user_key_string
            let l:current_filter_len += 1
        else
        endif
        if l:match_added
            call matchdelete(l:match_added)
            let l:match_added = 0
        endif
    endwhile
    " Do a final refresh
    let b:object.filter = ''
    call feedlist#Display()
endfun "}

"   Function: feedlist#KeyDiff() {
"
fun! feedlist#KeyDiff(item, key)
    let l:item = a:item
    if b:object.type == 'diff'
        let l:selected_left = b:object.args[0] . l:item.file
        let l:selected_right = b:object.args[1] . l:item.file
        " Diff two files
        let buf_cur = bufnr('%')
        silent! exec 'silent! edit! ' . l:selected_right
        let buf_right = bufnr('%')
        silent! exec 'silent! edit! ' . l:selected_left
        let buf_left = bufnr('%')
        exec 'silent! buffer ' . buf_cur
        if a:key ==# 'sdiff'
            let l:layout = 't0^01d>02dh'
        else
            let l:layout = 't01d>02dh'
        endif
        call feedlist#Layout([buf_cur, buf_left, buf_right], l:layout)
    endif

endfun "}

"   Function: feedlist#KeyInsert() {
fun! feedlist#KeyInsert(item)
    let l:item = a:item
    " toggle the insert state of item
    if !has_key(l:item, 'select')
        let l:item.select = 0
    endif
    let l:item.select = !l:item.select
    " refresh the database
    call feedlist#BuildLineString(l:item)
    " refresh the buffer
    call feedlist#Display()
    " move the cursor to next line
    silent! normal j
endfun "}

"   Function: feedlist#IsFileWindow() {
fun! feedlist#IsFileWindow(win_index)
    if a:win_index
        let l:buf_index = winbufnr(a:win_index)
        let l:object = getbufvar(l:buf_index, 'object')
        if !empty(l:object)
            if 'file' == l:object.type
                unlet l:object
                return 1
            endif
        endif
        unlet l:object
    endif
    return 0
endfun "}

"   Function: feedlist#GetNextFileWindow() {
fun! feedlist#GetNextFileWindow()
    " detect if last active window is a file window
    let l:win_alt = winnr('#')
    if feedlist#IsFileWindow(l:win_alt)
        return l:win_alt
    else
        let l:win_count = winnr('$')
        let l:win_current = winnr()
        let l:win_index = l:win_current + 1
        if l:win_index > l:win_count
            let l:win_index = 1
        endif
        while l:win_index != l:win_current
            if feedlist#IsFileWindow(l:win_index)
                return l:win_index
            endif
            let l:win_index = l:win_index + 1
            if l:win_index > l:win_count
                let l:win_index = 1
            endif
        endwhile
        return 0
    endif
endfun "}

"   Function: feedlist#KeyTab() {
fun! feedlist#KeyTab()
    " get next file window
    let l:win_other = feedlist#GetNextFileWindow()
    if l:win_other
        silent! exec l:win_other . 'wincmd w'
    endif
endfun "}

"   Function: feedlist#KeyCopy() {
fun! feedlist#KeyCopy(item)
    " count number of selected items
    let l:sel_count = 0
    let l:sel_list = []
    for l:line in b:object.lines
        if has_key(l:line, 'select') && l:line.select
            let l:sel_count = l:sel_count + 1
            call add(l:sel_list, l:line)
        endif
    endfor
    " if no selection default to cursor
    if !l:sel_count
        call add(l:sel_list, a:item)
    endif
    let l:file_list = ''
    for l:line in l:sel_list
        let l:file_list .= l:line['file']
        let l:file_list .= ' '
    endfor
    " Destination of copy?
    let l:win_other = feedlist#GetNextFileWindow()
    let l:buf_other = 0
    if l:win_other
        let l:buf_other = winbufnr(l:win_other)
    else
        let l:buf_other = bufnr('#')
        if l:buf_other < 0
            let l:buf_other = bufnr('%')
        endif
    endif
    let l:dest_path = fnamemodify(bufname(l:buf_other), ':p:h')
    " confirm operation
    echo 'Copy ' . l:file_list . ' to ' . l:dest_path
    " perform operation
    " show status
endfun "}

"   Function: feedlist#KeyFlat() {
fun! feedlist#KeyFlat()
    if has_key(b:object, 'flat') && b:object.flat
        let b:object.flat = 0
    else
        let b:object.flat = 1
    endif
    call feedlist#KeyRefresh()
endfun "}

"   Function: feedlist#KeyItem {
"
"
fun! feedlist#KeyItem(item, key)
    if a:key ==# '/' || a:key ==? 'f'
        call feedlist#KeyFilter(a:key)
    elseif a:key ==# 'u'
        call feedlist#KeyUndo()
    elseif a:key ==# 'r'
        call feedlist#KeyRedo()
    elseif a:key ==# 's' || a:key ==? 'o' || a:key ==? 'p'
        call feedlist#KeyOpen(a:item, a:key)
    elseif a:key ==# 'd'
        call feedlist#KeyDelete(a:item, a:key)
    elseif a:key ==# 'l'
        call feedlist#KeyRefresh()
    elseif a:key ==# 'a'
        call feedlist#KeyUp()
    elseif a:key ==# 'diff' || a:key ==# 'sdiff' || a:key ==? 'i'
        call feedlist#KeyDiff(a:item, a:key)
    elseif a:key ==# 'file-ins'
        call feedlist#KeyInsert(a:item)
    elseif a:key ==# 'file-tab'
        call feedlist#KeyTab()
    elseif a:key ==# 'file-copy'
        call feedlist#KeyCopy(a:item)
    elseif a:key ==# 'home'
        silent! edit $HOME
    elseif a:key ==# 'flat'
        call feedlist#KeyFlat()
    endif
endfun "}

"   Function: feedlist#Key() {
fun! feedlist#Key(count, key)
    let l:item = feedlist#GetSelectedLine(a:count)
    call feedlist#KeyItem(l:item, a:key)
endfun "}

"   Function: feedlist#CreateNewBuffer() {
fun! feedlist#CreateNewBuffer(buf_name)

    " Create a new buffer
    silent! enew

    " Make buffer a scratch buffer
    silent! setlocal buftype=nofile

    " Disable the swap file
    silent! setlocal noswapfile

    " Name the buffer to current directory
    silent! exec "silent! file " . fnameescape(a:buf_name)

endfun "}

"   Function: feedlist#CreateScratchBuffer() {
"
fun! feedlist#CreateScratchBuffer(buf_name)

    " Detect if buffer already exists
    if bufexists(a:buf_name)

        " Select previous buffer
        silent! exec "silent! buffer " . a:buf_name

        let l:new_buf = 0

    else

        call feedlist#CreateNewBuffer(a:buf_name)

        let l:new_buf = 1

    endif

    return l:new_buf

endfun "}

"   Function: feedlist#InstallMapping() {
fun! feedlist#InstallMapping(map_lhs, map_rhs)
    exec 'nnoremap <silent> <buffer> ' . a:map_lhs . ' :<c-u>call feedlist#Key(v:count, "' . a:map_rhs . '")<cr>'
endfun "}

"   Function: feedlist#InstallMappingItem() {
fun! feedlist#InstallMappingItem(map_item)
    call feedlist#InstallMapping(a:map_item.key, a:map_item.action)
endfun "}

"   Function: feedlist#InstallMappingList() {
fun! feedlist#InstallMappingList()
    for l:map_item in b:object.keys
        call feedlist#InstallMappingItem(l:map_item)
    endfor
endfun "}

"   Function: feedlist#BuildBufferName() {
fun! feedlist#BuildBufferName(object)
    let a:object.name = ''
    if a:object.type == "file"
        if '' == a:object.args
            if exists('b:feed_project_root_dir')
                let l:working_directory = b:feed_project_root_dir
            else
                let l:working_directory = getcwd()
            endif
        else
            let l:working_directory = expand(a:object.args)
        endif
        let l:working_directory = fnamemodify(l:working_directory, ':p:h')
        if !(l:working_directory =~ '/$')
            let l:working_directory .= '/'
        endif
        let a:object.name = l:working_directory . ".feedexplorer"
    elseif a:object.type == "buffer"
        let a:object.name = $HOME . "/.feedbuffer"
    elseif a:object.type == 'diff'
        " folder diff
        let a:object.name = $HOME . '/.feedlist-folderdiff'
    endif
    return !empty(a:object.name)
endfun "}

"   Function: feedlist#Generic() {
fun! feedlist#Generic(object, bufenter)

    if a:bufenter
        silent! setlocal buftype=nofile
        silent! setlocal noswapfile
        silent! setlocal nomodifiable
        silent! setlocal nomodified
    else
        " Detect if buffer already exists
        call feedlist#CreateScratchBuffer(a:object.name)
    endif

    " Remember type of listing
    let b:object = a:object

    " Reset filter for all levels
    let b:object.level = 0
    let b:object.level_max = 0
    let b:object.filter = ''

    " Setup contents first time
    call feedlist#RefreshListing()

    " Setup syntax
    call feedlist#InstallSyntax()

    " Display first time
    call feedlist#Display()

    " Setup mappings
    " Concept of filter level
    " Mark each line with a filter level
    " 0 means original buffer content
    " 1 means result of first filtering search
    " 2 means result of second filtering search
    " Keep history of search for redo
    "
    " Refresh redoes initial command

    " Setup some key mappings for browsing
    " File explorer:
    " / f F filter
    " o O open
    " p P preview
    " 
    call feedlist#InstallMappingList()
endfun "}

"   Function: feedlist#AddMapping() {
fun! feedlist#AddMapping(object, map_key, map_action)
    call add(a:object.keys, {'key': a:map_key, 'action': a:map_action })
endfun "}

"   Function: feedlist#InstallSyntax() {
fun! feedlist#InstallSyntax()
    silent! syntax clear
    silent! syntax match Constant "^\s*\d\+"
    silent! syntax match Directory "\S*[\\\/]"
    silent! syntax match DiffAdded "\S\+\*$"
endfun "}

"   Function: feedlist#MainEntry() {
"
"   Description:
"       Test using an array to store filtered lines
"
fun! feedlist#MainEntry(...)
    if a:0 < 1
        return
    endif
    if a:0 >= 1
        let l:listing_type = a:1
    else
        let l:listing_type = ''
    endif
    if a:0 >= 2
        let l:folder_name = a:2
    else
        let l:folder_name = ''
    endif
    if a:0 >= 3
        let l:bufenter = a:3
    else
        let l:bufenter = 0
    endif

    if l:bufenter
        if exists("b:object")
            " refresh...

            " Setup syntax
            call feedlist#InstallSyntax()
 
            " Display first time
            call feedlist#Display()

            return
        endif
    endif

    let l:object = {}
    let l:object.type = l:listing_type
    let l:object.args = l:folder_name

    if l:object.type == "file"
        " Get listing of current directory
        let l:object.method_refresh = function('feedlist#RefreshFileListing')
    elseif l:object.type == "buffer"
        " Get listing of buffers
        let l:object.method_refresh = function('feedlist#RefreshBufferListing')
    elseif l:object.type == 'diff'
        let l:object.method_refresh = function('feedlist#RefreshDiffListing')
    endif

    let l:object.keys = []
    call feedlist#AddMapping(l:object, '/', '/')
    call feedlist#AddMapping(l:object, 'f', 'f')
    call feedlist#AddMapping(l:object, 'F', 'F')
    call feedlist#AddMapping(l:object, '<c-l>', 'l')
    call feedlist#AddMapping(l:object, 'u', 'u')
    call feedlist#AddMapping(l:object, '<c-r>', 'r')
    call feedlist#AddMapping(l:object, '<CR>', 's')
    call feedlist#AddMapping(l:object, 'gf', 's')
    call feedlist#AddMapping(l:object, 'o', 'o')
    call feedlist#AddMapping(l:object, 'O', 'O')
    call feedlist#AddMapping(l:object, 'p', 'p')
    call feedlist#AddMapping(l:object, 'P', 'P')
    if l:object.type == 'diff'
        call feedlist#AddMapping(l:object, 'd', 'diff')
        call feedlist#AddMapping(l:object, 'D', 'sdiff')
    else
        if l:object.type == "buffer"
            call feedlist#AddMapping(l:object, 'd', 'd')
        elseif l:object.type == 'file'
            call feedlist#AddMapping(l:object, 'a', 'a')
            call feedlist#AddMapping(l:object, '<bs>', 'a')
            call feedlist#AddMapping(l:object, '<ins>', 'file-ins')
            call feedlist#AddMapping(l:object, '<tab>', 'file-tab')
            call feedlist#AddMapping(l:object, '<f5>', 'file-copy')
            call feedlist#AddMapping(l:object, '~', 'home')
            call feedlist#AddMapping(l:object, '<c-b>', 'flat')
        else
            call feedlist#AddMapping(l:object, 'a', 'a')
        endif
    endif

    if feedlist#BuildBufferName(l:object)
        call feedlist#Generic(l:object, l:bufenter)
    else
        echo 'feedlist#MainEntry() invalid parameter'
    endif

endfun "}

"   Function: feedlist#File() {
fun! feedlist#File(...)
    if a:0 >= 1
        let l:name = a:1
    else
        let l:name = expand('%:p:h')
    endif
    silent! exec 'edit ' . l:name
endfun "}

"   Function: feedlist#FileBufEnter() {
fun! feedlist#FileBufEnter(name)
    if isdirectory(a:name)
       call feedlist#MainEntry('file', a:name, 1)
    endif
endfun "}

"   Function: feedlist#Buffer() {
fun! feedlist#Buffer()
    call feedlist#MainEntry("buffer", ".")
endfun "}

"   Function: feedlist#FileDiff() {
fun! feedlist#FileDiff(...)

    " Process command-line options
    if a:0 != 0
        if a:0 == 1
            if isdirectory(a:1)
                " Compare current directory with other folder
                call feedlist#FileDiff('.', a:1)
            else
                " Diff current file with file1
                call feedlist#FileDiff(bufname('%'), a:1)
            endif
        elseif a:0 == 2
            let l:folder1 = fnamemodify(expand(a:1), ':p')
            let l:folder2 = fnamemodify(expand(a:2), ':p')
            if isdirectory(l:folder1) && isdirectory(l:folder2)
                echo 'diff folders ' . l:folder1  . ' and ' . l:folder2
                call feedlist#MainEntry('diff', [ l:folder1 , l:folder2 ])
            elseif !isdirectory(l:folder1) && !isdirectory(l:folder2)
                " Diff two files
                let buf_cur = bufnr('%')
                silent! exec 'silent! edit! ' . l:folder1
                let buf_left = bufnr('%')
                silent! exec 'silent! edit! ' . l:folder2
                let buf_right = bufnr('%')
                silent! exec 'silent! buffer ' . buf_cur
                let l:layout = 't10d>1dh'
                call feedlist#Layout([buf_left, buf_right], l:layout)
            else
                echo 'file and folder mixup'
            endif

        else
            echo 'too many arguments'
        endif
    else
        let l:win_index = winnr()
        if feedlist#IsFileWindow(l:win_index)
            let l:win_other = feedlist#GetNextFileWindow()
            if l:win_other
                " Locate two files or folders automatically
                call feedlist#FileDiff(bufname(winbufnr(l:win_index)), bufname(winbufnr(l:win_other)))
            endif
        else
            " Locate two files or folders automatically
            call feedlist#FileDiff(bufname('%'), bufname('#'))
        endif
        " echo ':D file1 [file2]'
    endif

endfun "}

