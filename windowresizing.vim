
fun! s:changeSignDirection(sign, reverse) "toogle +/- if reverse == true
    if(a:reverse && a:sign == "+")
        return "-"  
    elseif(a:reverse && a:sign == "-")
        return "+"  
    endif
    return a:sign
endfun


function! WindowResizingLoop() abort
    let jumpsize = 5

    while (1)

        let ch = nr2char(getchar())
        
        "Leave Loop
        if(ch == "q" || char2nr(ch) == 27)
            break
        endif

        " Reverse if capital, then we resize the 'previous' window
        " To change which direction we resize
        let s:reverse = (ch ==# "H" || ch ==# "J" || ch ==# "K" || ch ==# "L")
            
        " Direction keyword for resizing
        let directionSign = "+"
        if (ch ==? "k" || ch ==? "h")
            let directionSign = "-"
        endif

        if(ch ==? "j" || ch ==? "k") " UP/DOWN
            " If there is no window under, the resize in inverse, so reverse
            " resize direction
            let s:dirSgn = s:changeSignDirection(directionSign, (winnr()==winnr('j')))
            "
            " Which window should be resized (see s:reverse)
            let s:chWinid = ""
            if(s:reverse)
                let s:chWinid = winnr("k")
            endif
            
            " Resize
            exe (s:chWinid . "resize " . s:dirSgn . jumpsize)
        endif

        if(ch ==? "h" || ch ==? "l") " RIGHT/LEFT
            let s:dirSgn = s:changeSignDirection(directionSign,  (winnr()==winnr('l')))
            let s:chWinid = ""
            if(s:reverse)
                let s:chWinid = winnr("h")
            endif
            exe ("vertical " . s:chWinid . "resize " . s:dirSgn . jumpsize)
        endif
        redraw " Draw the resizing  
    endwhile
endfunction

nnoremap <localleader>nn :call WindowResizingLoop()<cr>


