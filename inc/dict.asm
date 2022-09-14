; Selects a random word from the dictionary.
; Sets the to be guessed and the revealed letter indices.
;
; Note: The dict saves the 5 chars of the words in 4 bytes.
;       n+0: 11111122
;       n+1: 22223333
;       n+2: 33444444
;       n+3: 55555500
;
select_word:
    ld  de, current_word
    
    ld a, %0001010
    ld [random_number], a
    ld a, %00000000
    ld [random_number+1], a
    
    
    ld  a, [random_number+0]
    and %00011111
    ld  h, a
    ld  l, a
    srl h
    srl h
    sla l
    sla l
    sla l
    sla l
    sla l
    sla l
    ld  a, [random_number+1]
    and %00111111
    add a, l
    ld  l, a
    ld  b, h
    ld  c, l
    add hl, bc
    add hl, bc
    add hl, bc
    ld  bc, dictionary
    add hl, bc

    ; first char
    ld  a, [hl] ; byte 0
    and %11111100
    srl a
    srl a
    ld  [de], a

    ; second char
    ld  a, [hl] ; byte 0
    and %00000011
    sla a
    sla a
    sla a
    sla a
    ld  b, a
    inc hl
    ld  a, [hl] ; byte 1
    and %11110000
    srl a
    srl a
    srl a
    srl a
    add a, b
    inc de
    ld  [de], a
    
    ; third char
    ld  a, [hl] ; byte 1
    and %00001111
    sla a
    sla a
    ld  b, a
    inc hl
    ld  a, [hl] ; byte 2
    and %11000000
    srl a
    srl a
    srl a
    srl a
    srl a
    srl a
    add a, b
    inc de
    ld  [de], a
    
    ; fourth char
    ld  a, [hl] ; byte 2
    and %00111111
    inc de
    ld  [de], a
    
    ; fifth char
    inc hl
    ld  a, [hl] ; byte 3
    and %11111100
    srl a
    srl a
    inc de
    ld  [de], a
    ret

