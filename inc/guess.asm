; Updates the objects of the entered characters
update_guess_objects:
    ld  hl, obj_guess_letters
    ld  de, guesses

    ld  a, $14
    call update_guess_row
    ld  a, $24
    call update_guess_row
    ld  a, $34
    call update_guess_row
    ld  a, $44
    call update_guess_row
    ld  a, $54
    call update_guess_row
    ld  a, $64
    call update_guess_row
    ret



; Updates one line of entered characters
; -> hl: position within obj data
; -> de: position within the guesses data
; -> a:  vertical screen position
update_guess_row:
    push hl
    push hl
    push hl

	; distance between objects
    ld  bc, 4

    ; vertical positions
    ld  [hl], a
REPT 4
    add hl, bc
    ld  [hl], a
ENDR
    
    ; horizontal positions
    pop hl
    inc hl
    ld  a, $30
    ld  [hl], a
REPT 4
    add hl, bc
    add a, $10
    ld  [hl], a
ENDR
    
    ; tile indices
    pop hl
    inc hl
    inc hl
    ld  a, [de]
    ld  [hl], a
REPT 4
    add hl, bc
    inc de
    ld  a, [de]
    ld  [hl], a
ENDR
    
    ; palette info
    pop hl
    inc hl
    inc hl
    inc hl
    ld  a, OBJ_ATTR_PALETTE1
    ld  [hl], a
REPT 4
    add hl, bc
    ld  [hl], a
ENDR
    
    inc hl
    inc de
    ret



; Calculates the position of the current guess
; <- hl
get_guess_offset:
    ld  a, [current_guess]
    ld  b, 5
    call multiply_ab
    ld  b, 0
    ld  c, a
    ld  hl, guesses
    add hl, bc
    ret

