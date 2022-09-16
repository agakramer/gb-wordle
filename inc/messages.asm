; Highlights the menu entry "start game"
show_message_menu_start:
    ld  de, message_menu_start
    ld  b, 0
    call show_message
    ret



; Highlights the menu entry "how it works"
show_message_menu_help:
    ld  de, message_menu_help
    ld  b, 0
    call show_message
    ret



; Inform that the current guess is not in the dictionary
show_message_unknown:
    ld  de, message_unknown
    ld  b, 180
    call show_message
    ret



; Inform about the users victory
show_message_won:
    ld  de, message_won
    ld  b, 0
    call show_message
    ret



; Inform about the users loss
show_message_lost:
    ld  de, message_lost
    ld  b, 0
    call show_message
	
	; copy the correct word into the message
    ld  hl, obj_message_letters + 14
    ld  bc, current_word

REPT 5
    ld  a, [bc]
    ld  [hl], a
    inc bc
    inc hl
    inc hl
    inc hl
    inc hl
ENDR
    ret



; Displays a message to the user
; <- de
; <- b
show_message:
    push hl
    push bc
    push de

    ld hl, obj_message_letters
    ld c, 36
.loop:
    ld  a, [de]
    ld  [hl], a
    inc hl
    inc de
    dec c
    jp nz, .loop
    
    ld  a, b
    ld  [message_timeout], a
    
    pop de
    pop bc
    pop hl
    ret



; Checks if the current message has expired
check_message_timeout:
    ld  a, [message_timeout]
    cp  a, 0
    jp  z, .return
    
    dec a
    ld  [message_timeout], a
    cp  a, 0
    jp  nz, .return

.timeout:
    call clear_message
.return:
    ret



; Clears the current message by overwriting with nothing   
clear_message:
    ld  de, message_clear
    ld  b, 0
    call show_message
    ret

