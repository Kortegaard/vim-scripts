
if exists("+showtabline")

let g:TabNames = {} " Stores Tabnames

function! TSTabName(tabnr) abort
    let buflist = tabpagebuflist(a:tabnr)
    let winnr = tabpagewinnr(a:tabnr)
    let bufnr = buflist[winnr - 1]
    let file = bufname(bufnr)
    let buftype = getbufvar(bufnr, '&buftype')

    if buftype == 'help'
        let name = 'help:' . fnamemodify(file, ':t:r')

    elseif buftype == 'quickfix'
        let name = 'quickfix'

    elseif buftype == 'nofile'
        if file =~ '\/.'
            let name = substitute(file, '.*\/\ze.', '', '')
        endif
    elseif has_key(g:TabNames, gettabvar(a:tabnr,"TabScriptTabId"))
        let name = g:TabNames[gettabvar(a:tabnr,"TabScriptTabId")]
    else
        let name = pathshorten(fnamemodify(file, ':p:~:.'))
        if getbufvar(bufnr, '&modified')
            let name = '+' . file
        endif
    endif

    if name == ''
        let name = '[No Name]'
    endif
    return name
endfunction

function! MyTabLine() abort
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let s .= '%' . i . 'T'
        let s .= (i == t ? '%1*' : '%2*')

        " let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
        " let s .= ' '
        let s .= (i == t ? '%#TabNumSel#' : '%#TabNum#')
        let s .= ' ' . i . ' '
        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')

        let bufnr = buflist[winnr - 1]

        let s .= ' ' . TSTabName(i)

        let nwins = tabpagewinnr(i, '$')
        if nwins > 1
            let modified = ''
            for b in buflist
                if getbufvar(b, '&modified') && b != bufnr
                    let modified = '*'
                    break
                endif
            endfor
            let hl = (i == t ? '%#WinNumSel#' : '%#WinNum#')
            let nohl = (i == t ? '%#TabLineSel#' : '%#TabLine#')
            let s .= ' ' . modified . '(' . hl . winnr . nohl . '/' . nwins . ')'
        endif

        if i < tabpagenr('$')
            let s .= ' %#TabLine#|'
        else
            let s .= ' '
        endif

        let i = i + 1

    endwhile

    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s

endfunction

function! TSSetTabName() abort
    let s:name = input("Tabname: ")
    if(s:name != '')
        "let g:TabNames[tabpagenr()] = s:name
        let g:TabNames[get(t:, "TabScriptTabId")] = s:name
    else
        call TSDeleteTabName()
    endif
    redrawt
endfunction

function! TSDeleteTabName() abort
    " Removing Tabname
    if has_key(g:TabNames, gettabvar(tabpagenr(),"TabScriptTabId"))
        unlet g:TabNames[gettabvar(tabpagenr(),"TabScriptTabId")]
    endif
    redrawt
endfunction

function! TSSetTabId() abort 
    " Setting Tab variable to identify the tab for naming
    if(!get(t:, "TabScriptTabId"))
        let t:TabScriptTabId = reltimestr(reltime())
    endif
endfunction

function! TSFZFCallback(st) abort
    let tabnr = split(a:st," - ")[0]
    execute 'tabn ' . tabnr
endfunction

function! TSTabFZF() abort
    let tList = []
    for i in range(1,tabpagenr('$'))
        let tList += [string(i) . ' - ' . TSTabName(i)] 
    endfor
    call fzf#run({'source':tList, 'window': { 'width': 0.9, 'height': 0.6 }, 'sink':function('TSFZFCallback')})
endfunction


autocmd! VimEnter,WinEnter,TabEnter * call TSSetTabId()

set showtabline=1
"highlight! TabNum term=bold,underline cterm=bold,underline ctermfg=1 ctermbg=7 gui=bold,underline guibg=LightGrey
highlight! TabNum term=bold,underline cterm=bold,underline ctermfg=1 ctermbg=White gui=bold,underline guibg=White
highlight! TabNumSel term=bold,reverse cterm=bold,reverse ctermfg=1 ctermbg=7 gui=bold
highlight! WinNum term=bold,underline cterm=bold,underline ctermfg=11 ctermbg=7 guifg=DarkBlue guibg=LightGrey
highlight! WinNumSel term=bold cterm=bold ctermfg=7 ctermbg=14 guifg=DarkBlue guibg=LightGrey
highlight! TabLineFill cterm=bold ctermbg=White

highlight! TabLine term=bold cterm=bold ctermfg=Black ctermbg=White guifg=DarkBlue guibg=LightGrey

set tabline=%!MyTabLine()

endif " exists("+showtabline")


nnoremap <localleader>tr :call TSSetTabName()<cr>
nnoremap <localleader>tt :call TSTabFZF()<cr>

