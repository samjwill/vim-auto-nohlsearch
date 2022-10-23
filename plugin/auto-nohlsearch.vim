"Turn off search highlighting once done searching
let s:enter_was_pressed = 0

function! s:handle_cursor_moved()
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
   if (!s:enter_was_pressed)
      set nohlsearch
   else
      let s:enter_was_pressed = 0
      set hlsearch
   endif
endfunction

function! s:handle_enter_pressed_in_cmdline()
   let s:enter_was_pressed = 1
   return "\<CR>"
endfunction

augroup AUTO_NOHLSEARCH_CMDS | autocmd!
    "See :h cmdwin-char and :h file-pattern. Maps to ? and / searches.
    autocmd! CmdlineChanged [\/\?] set hlsearch
    autocmd! CmdlineLeave [\/\?] call <SID>handle_cmdline_leave()
    autocmd! CmdwinEnter [\/\?] nnoremap <CR> <CMD>let s:enter_was_pressed = 1<CR><CR>
    autocmd! CmdwinLeave [\/\?] nunmap <CR>
    autocmd! CursorMoved * call <SID>handle_cursor_moved()
    autocmd! InsertEnter * set nohlsearch
augroup end

cnoremap <silent><expr> <CR> <SID>handle_enter_pressed_in_cmdline()

noremap <silent> n n<CMD>set hlsearch<CR>
noremap <silent> N N<CMD>set hlsearch<CR>
noremap <silent> * *<CMD>set hlsearch<CR>
noremap <silent> # #<CMD>set hlsearch<CR>
noremap <silent> g* g*<CMD>set hlsearch<CR>
noremap <silent> g# g#<CMD>set hlsearch<CR>
noremap <silent> gd gd<CMD>set hlsearch<CR>
noremap <silent> gD gD<CMD>set hlsearch<CR>
