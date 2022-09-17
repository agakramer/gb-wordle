;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; ██░▄▄▄░█░▄▄▀███▄█░▄▄█▀▄▀█▄░▄███░▄▄▀█▄░▄█▄░▄█░▄▄▀██▄██░▄▄▀█░██░█▄░▄█░▄▄████░▄▀▄░█░▄▄█░▄▀▄░█▀▄▄▀█░▄▄▀█░██░██
;; ██░███░█░▄▄▀███░█░▄▄█░█▀██░████░▀▀░██░███░██░▀▀▄██░▄█░▄▄▀█░██░██░██░▄▄████░█░█░█░▄▄█░█▄█░█░██░█░▀▀▄█░▀▀░██
;; ██░▀▀▀░█▄▄▄▄█░▀░█▄▄▄██▄███▄████░██░██▄███▄██▄█▄▄█▄▄▄█▄▄▄▄██▄▄▄██▄██▄▄▄████░███░█▄▄▄█▄███▄██▄▄██▄█▄▄█▀▀▀▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; Contains functions to manage the object attribute memory (OAM).
;; We do not write to this area directly, but use a copy in the working memory.
;; During a v-blank, the OAM is updated using direct memory access (DMA).
;; Note: the Game Boy can only handle a total of 40 objects, and only 10 can be displayed on a line.


; Fill the whole OAM copy with zero to prevent artifacts
; <- [objects]
init_oam_copy:
    ld  b, 160
    ld  a, 0
    ld  hl, obj_start

.copy_loop
    ld  [hl+], a
    dec b
    jp  nz, .copy_loop
    ret



; Update the OAM via DMA
; -> [objects]
; <- [OAM]
update_oam:
    ; start DMA
    ld  a, $c0
    ld  [DMA_REGISTER], a

    ; wait 160 cycles
    ld  a, 40

.loop:
    dec a
    jp  nz, .loop
    ret

