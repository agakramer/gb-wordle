; Update the character hint objects
update_hint_markings:
    ld  hl, BKG_LOC_9800 + 20*32 + 6
    ld  de, guesses_hints
    
    ld  b, 6
.loop_outer:
    ld  c, 5
.loop_inner:
    ld  a, [de]
    ld  [hl], a
    inc hl
    inc hl
    inc de
    dec c
    ld  a, c
    cp  a, 0
    jp  nz, .loop_inner

    push de
    ld  de, 32*2 - 10
    add hl, de
    pop  de
    
    dec b
    ld  a, b
    cp  a, 0
    jp  nz, .loop_outer
    ret



; Update the hint data
mark_hints:
    call get_guess_offset
    push hl
    pop de
    ld  bc, 30
    add hl, bc
    
    ld  b, 0
.loop:
    ld  a, [de]
    call hint_for_char
    ld  [hl], a
    inc de
    inc hl
    inc b
    ld  a, b
    cp  a, 5
    jp  nz, .loop
    ret



; Determines the hint for one character
; <- a: character value to check  
; <- b: index within the guess
hint_for_char:
    push hl
    push bc
    push de

    ld  hl, current_word
    ld  d, a           ; char value
    ld  e, b           ; position
    ld  c, 0           ; counter
    ld  b, TILE_WRONG  ; return value

.loop:
    ld  a, [hl]
    cp  a, d
    jp  nz, .not_equal
    ld  a, c
    cp  a, e
    jp  nz, .misplaced

.right:
    ld  b, TILE_RIGHT
    jp  .return

.misplaced:
    ld  b, TILE_MISPLACED

.not_equal:
    inc c
    inc hl
    ld  a, c
    cp  a, 5
    jp  nz, .loop

.return:
    ld  a, b
    pop de
    pop bc
    pop hl
    ret

