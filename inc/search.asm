; Compresses the current guess to the same format as the dictionary
; <- bc
; <- de
compress_guess:
    call get_guess_offset
    
    ; first byte
    ld  a, [hl+] ; letter 1
    and %00111111
    sla a
    sla a
    ld  b, a
    ld  a, [hl]  ; letter 2
    and %00110000
    sra a
    sra a
    sra a
    sra a
    add a, b
    ld  d, a
    
    ; second byte
    ld  a, [hl+] ; letter 2
    and %00001111
    sla a
    sla a
    sla a
    sla a
    ld  b, a
    ld  a, [hl]  ; letter 3
    and %00111100
    sra a
    sra a
    add a, b
    ld  e, a
    push de

    ; third byte
    ld  a, [hl+]  ; letter 3
    and %00000011
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    ld  b, a
    ld  a, [hl+]  ; letter 4
    and %00111111
    add a, b
    ld  d, a
    
    ; fourth byte
    ld  a, [hl]  ; letter 5
    and %00111111
    sla a
    sla a
    ld  e, a
    pop bc
    ret



; Try to find the guess within the dictionary
; -> bc 
; -> de
; <- a
find_guess:
    ld  hl, dictionary

.loop:
    ; check if the end of the dictionary is reached
    push bc
    ld  bc, dictionary_end
    ld  a, h
    cp  a, b
    jp  nz, .not_eof
    ld  a, l
    cp  a, c
    jp  nz, .not_eof
    pop bc
    jp .return

.not_eof:
    pop bc

    ld  a, [hl+]
    cp  a, b
    jp  nz, .add3
    ld  a, [hl+]
    cp  a, c
    jp  nz, .add2
    ld  a, [hl+]
    cp  a, d
    jp  nz, .add1
    ld  a, [hl+]
    cp  a, e
    jp  nz, .add0
    ld  a, 1
    ret

.add3:
    inc hl
.add2:
    inc hl
.add1:
    inc hl
.add0:
    jp  .loop
.return:
    ld  a, 0
    ret

