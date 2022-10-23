"Turn off search highlighting once done searching

if (!exists("g:auto_nohlsearch_enabled"))
    let g:auto_nohlsearch_enabled = v:true
endif

let s:enter_was_pressed = 0

function! s:handle_cursor_moved()
    if (g:auto_nohlsearch_enabled == v:false)
        return
    endif

    if &hlsearch == 0 "See :h expr-option
        return
    endif

    let last_search = @/
    if last_search != ""
        let cursor_pos = [line("."), col(".")]
        "Limit search to current line, starting with character under cursor
        let pos_of_next_match = searchpos(last_search, "cnz", cursor_pos[0])
        if cursor_pos != pos_of_next_match
            set nohlsearch
        endif
  endif
endfunction

function! s:handle_cmdline_leave()
    if (g:auto_nohlsearch_enabled == v:false)
        return
    endif

    if (!s:enter_was_pressed)
        set nohlsearch
    else
        let s:enter_was_pressed = 0
        set hlsearch
    endif
endfunction

function! s:handle_enter_pressed_in_cmdline()
    if (g:auto_nohlsearch_enabled == v:true)
        let s:enter_was_pressed = 1
    endif
    return "\<CR>"
endfunction

function! s:set_hlsearch(enable)
    if (g:auto_nohlsearch_enabled == v:true)
        if (a:enable)
            set hlsearch
        else
            set nohlsearch
        endif
    endif
endfunction

function! s:handle_cmdwin_enter()
    if (g:auto_nohlsearch_enabled == v:true)
        nnoremap <CR> <CMD>let s:enter_was_pressed = 1<CR><CR>
    endif
endfunction

function! s:handle_cmdwin_leave()
    if (g:auto_nohlsearch_enabled == v:true)
        nunmap <CR>
    endif
endfunction

augroup AUTO_NOHLSEARCH_CMDS | autocmd!
     "See :h cmdwin-char and :h file-pattern. Maps to ? and / searches.
     autocmd CmdlineChanged [\/\?] call <SID>set_hlsearch(v:true)
     autocmd CmdlineLeave [\/\?] call <SID>handle_cmdline_leave()
     autocmd CmdwinEnter [\/\?] call <SID>handle_cmdwin_enter()
     autocmd CmdwinLeave [\/\?] call <SID>handle_cmdwin_leave()
     autocmd CursorMoved * call <SID>handle_cursor_moved()
     autocmd InsertEnter * call <SID>set_hlsearch(v:false)
augroup end

cnoremap <silent><expr> <CR> <SID>handle_enter_pressed_in_cmdline()

noremap <silent> n n<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> N N<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> * *<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> # #<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> g* g*<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> g# g#<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> gd gd<CMD>call <SID>set_hlsearch(v:true)<CR>
noremap <silent> gD gD<CMD>call <SID>set_hlsearch(v:true)<CR>
