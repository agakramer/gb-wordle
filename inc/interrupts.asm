; Interrupt handler for the vertical blanking
int_vblank:
    push af
    ld  a, 1
    ld  [vblank_flag], a
    pop af
    reti



; Interrupt handler for the timer
;
; Getting random numbers is hard, here we read the vertical position of the scanline,
; save them periodically and use them to get something.
int_timer:
    push hl
    push af
    push de
    
    ; get the current random number
    ld  hl, random_number
    ld  a, [hl]
    ld  d, a
    
    ; get the current y position of the screen
    ld  hl, LCD_POSITION_REGISTER
    ld  a, [hl]
    
    ; save the new number
    ld  hl, random_number
    ld  [hl+], a
    ld  a, d
    ld  [hl], a
    
    pop de
    pop af
    pop hl
    reti

