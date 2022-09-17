;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; ██░▄▄░█░██░█░▄▄█░▄▄█░▄▄█░███░█▀▄▄▀█░▄▄▀█░█▀██
;; ██░█▀▀█░██░█░▄▄█▄▄▀█▄▄▀█▄▀░▀▄█░██░█░▀▀▄█░▄▀██
;; ██░▀▀▄██▄▄▄█▄▄▄█▄▄▄█▄▄▄██▄█▄███▄▄██▄█▄▄█▄█▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; Manages and displays the guessing attempts


; Updates the objects of the entered characters
; -> [guesses]
; <- [obj_guess_letters]
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
; -> hl: address of where to write obj data
; -> de: address of the current guess
; -> a:  vertical screen position
; <- [obj_guess_letters]
update_guess_row:
    push hl
    push hl
    push hl

	; distance between objects
    ld  bc, 4

    ; write all five vertical positions
    ld  [hl], a
REPT 4
    add hl, bc
    ld  [hl], a
ENDR
    
    ; write all five horizontal positions
    pop hl
    inc hl
    ld  a, $30
    ld  [hl], a
REPT 4
    add hl, bc
    add a, $10
    ld  [hl], a
ENDR
    
    ; write all five tile indices
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
    
    ; write all five palette info
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



; Calculates the address of the current guess attempt, using the number of the attempt
; -> [current_guess]: number of the current attempt
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

