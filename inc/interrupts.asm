;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; █▄░▄█░▄▄▀█▄░▄█░▄▄█░▄▄▀█░▄▄▀█░██░█▀▄▄▀█▄░▄█░▄▄██
;; ██░██░██░██░██░▄▄█░▀▀▄█░▀▀▄█░██░█░▀▀░██░██▄▄▀██
;; █▀░▀█▄██▄██▄██▄▄▄█▄█▄▄█▄█▄▄██▄▄▄█░█████▄██▄▄▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; Handle hardware interrupts


; Interrupt handler for the vertical blanking period
int_vblank:
    push af
    ld  a, 1
    ld  [vblank_flag], a
    pop af
    reti



; Interrupt handler for the timer
;
; Getting random numbers is hard, here we read the vertical position of the scanline,
; save them periodically and use them to get something. This approach works,
; but is not unbalanced because the y position only goes from 0 to 153.
; To get around this, two values are stored as in a shift register
; and not all bits of this are used when determining the random number.
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
    
    ; save the old and new number
    ld  hl, random_number
    ld  [hl+], a
    ld  a, d
    ld  [hl], a
    
    pop de
    pop af
    pop hl
    reti

