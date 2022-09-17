;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; ██░▄▄▀██▄██▀▄▀█▄░▄██▄██▀▄▄▀█░▄▄▀█░▄▄▀█░▄▄▀█░██░██
;; ██░██░██░▄█░█▀██░███░▄█░██░█░██░█░▀▀░█░▀▀▄█░▀▀░██
;; ██░▀▀░█▄▄▄██▄███▄██▄▄▄██▄▄██▄██▄█▄██▄█▄█▄▄█▀▀▀▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; This file contains all the functions to interact with the dictionary.
;; Therefore, a random word can be selected and it is possible to check if an entered word exists.


; Selects a random entry from the dictionary and saves it.
;
; Note:
; In the dictionary, entries with a word length of five are stored with only four bytes.
;     n+0: 11111122
;     n+1: 22223333
;     n+2: 33444444
;     n+3: 55555500
;  ~> 00111111 00222222 00333333 00444444 00555555
;
; -> [random_number]: depends on the current random number
; <- [currend_word]:  five characters, index starts at one
select_word:
    ld  de, current_word
    
    ; determine the starting address of the dictionary entry
    ; (start address + random * word length)
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



; In order to check whether an entered word exists in the dictionary,
; it must first be compressed according to the dictionary.
; -> [current guess]: current rate attempt, stored in five bytes
; <- bc: first two bytes of the compression
; <- de: second two bytes of the compression
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



; Try to find the current guess within the dictionary
; -> bc: first two bytes of the compression
; -> de: second two bytes of the compression
; <- a: whether the entry exists
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

