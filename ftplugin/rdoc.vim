" Vim filetype plugin file
" Language: R Documentation (generated by the Vim-R-plugin)
" Maintainer: Jakson Alves de Aquino <jalvesaq@gmail.com>
" Last Change:	Sat Mar 08, 2014  11:57PM


" Only do this when not yet done for this buffer
if exists("b:did_rdoc_ftplugin")
    finish
endif

" Don't load another plugin for this buffer
let b:did_rdoc_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" Source scripts common to R, Rnoweb, Rhelp and rdoc files:
runtime r-plugin/common_global.vim

" Some buffer variables common to R, Rnoweb, Rhelp and rdoc file need be
" defined after the global ones:
runtime r-plugin/common_buffer.vim

setlocal iskeyword=@,48-57,_,.

" Prepare R documentation output to be displayed by Vim
function! FixRdoc()
    let lnr = line("$")
    for i in range(1, lnr)
        call setline(i, substitute(getline(i), "_\010", "", "g"))
        " A space after 'Arguments:' is necessary for correct syntax highlight
        " of the first argument
        call setline(i, substitute(getline(i), "^Arguments:", "Arguments: ", ""))
    endfor

    let has_ex = search("^Examples:$")
    if has_ex
        if getline("$") !~ "^###$"
            let lnr = line("$") + 1
            call setline(lnr, '###')
        endif
    endif

    " Add a tab character at the end of the Usage section to mark its end.
    call cursor(1, 1)
    let ii = search("^Usage:$")
    if ii
        let doclength = line("$")
        let ii += 2
        let lin = getline(ii)
        while lin !~ "^[A-Z].*:" && ii < doclength
            let ii += 1
            let lin = getline(ii)
        endwhile
        if ii < doclength
            let ii -= 1
            if getline(ii) =~ "^ *$"
                call setline(ii, "\t")
            endif
        endif
    endif

    normal! gg

    " Clear undo history
    let old_undolevels = &undolevels
    set undolevels=-1
    exe "normal a \<BS>\<Esc>"
    let &undolevels = old_undolevels
    unlet old_undolevels
endfunction

function! RdocIsInRCode(vrb)
    let exline = search("^Examples:$", "bncW")
    if exline > 0 && line(".") > exline
        return 1
    else
        if a:vrb
            call RWarningMsg('Not in the "Examples" section.')
        endif
        return 0
    endif
endfunction

let b:IsInRCode = function("RdocIsInRCode")
let b:SourceLines = function("RSourceLines")

"==========================================================================
" Key bindings and menu items

call RCreateSendMaps()
call RControlMaps()

" Menu R
if has("gui_running")
    call MakeRMenu()
endif

call RSourceOtherScripts()

setlocal bufhidden=wipe
setlocal noswapfile
set buftype=nofile
autocmd VimResized <buffer> let g:vimrplugin_newsize = 1
call FixRdoc()
autocmd FileType rdoc call FixRdoc()

let &cpo = s:cpo_save
unlet s:cpo_save

