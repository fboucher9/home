"   Module: feed.vim
"
"   Description:
"       Color scheme for feed
"

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "feed"

"   Function: do_highlight_list { {
"
"   Description:
"       Apply highlight settings from given list.
"
"   Parameters:
"       list = [ entry, entry, ... ]
"       entry = [ groups, colors ]
"       groups = [ group, group, ... ]
"       colors = [ ctermfg, ctermbg, guifg, guibg ]
"
"   Comments:
"
"       Available colors
"       ----------------
"           Black
"           DarkBlue
"           DarkGreen
"           DarkCyan
"           DarkRed
"           DarkMagenta
"           Brown, DarkYellow
"           LightGray, LightGrey, Gray, Grey
"           DarkGray, DarkGrey
"           Blue, LightBlue
"           Green, LightGreen
"           Cyan, LightCyan
"           Red, LightRed
"           Magenta, LightMagenta
"           Yellow, LightYellow
"           White
"
" }
fun! s:do_highlight_list(list) "{
    for item in a:list
        let group_list = item[0]
        let color = item[1]
        exec 'hi clear ' . group_list[0]
        if !has('gui_running')
            exec 'hi ' . group_list[0] . ' ctermfg=' . color[0] . ' ctermbg=' . color[1]
        else
            exec 'hi ' . group_list[0] . ' guifg=' . color[2] . ' guibg=' . color[3]
        endif
        let index = 1
        while index < len(group_list)
            exec 'hi clear ' . group_list[index]
            exec 'hi! link ' . group_list[index] . ' ' . group_list[0]
            let index += 1
        endwhile
    endfor
endfun "} }

" Apply my highlight settings
call s:do_highlight_list([
    \ [['Normal', 'NonText', 'Special', 'Identifier', 'ModeMsg', 'CursorLineNr', 'Ignore', 'MatchParen'],
    \  ['LightGray', 'Black', '#c8c8c8', '#000000']],
    \ [['StatusLine'],
    \  ['LightGray', 'Black', '#c8c8c8', '#000000']],
    \ [['Statement', 'Comment', 'Type', 'StatusLineNC', 'VertSplit', 'LineNr', 'Folded', 'FoldColumn', 'SignColumn'],
    \  ['DarkGray', 'Black', '#909090', '#000000']],
    \ [['Preproc', 'WildMenu', 'Directory', 'WarningMsg', 'ErrorMsg'],
    \  ['DarkCyan', 'Black', 'DarkCyan', '#000000']],
    \ [['diffAdded', 'SpellCap', 'SpellRare', 'SpellBad', 'SpellLocal', 'Todo', 'Title', 'MoreMsg', 'Question'],
    \  ['DarkGreen', 'Black', 'DarkGreen', '#000000']],
    \ [['Constant', 'diffRemoved'],
    \  ['Brown', 'Black', '#af5f00', '#000000']],
    \ [['Visual', 'VisualNOS', 'Search'],
    \  ['Black', 'LightGray', '#000000', '#c8c8c8']],
    \ [['IncSearch', 'Cursor'],
    \  ['Black', 'Yellow', '#000000', 'Yellow']],
    \ [['Error'],
    \  ['DarkMagenta', 'Black', 'DarkMagenta', '#000000']],
    \ [['CursorLine', 'CursorColumn', 'ColorColumn'],
    \  ['NONE', '235', 'NONE', '235']],
    \ [['DiffDelete'],
    \  ['NONE', '233', 'NONE', '233']],
    \ [['DiffAdd', 'DiffChange'],
    \  ['NONE', '233', 'NONE', '233']],
    \ [['DiffText'],
    \  ['NONE', '235', 'NONE', '235']],
    \ [['SpecialKey'],
    \  ['LightBlue', '235', 'LightBlue', '235']]
    \ ])

