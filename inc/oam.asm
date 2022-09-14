; Fill the whole oam copy with zero to prevent artifacts
init_oam_copy:
    ld  b, 160
    ld  a, 0
    ld  hl, obj_start

.zero_loop
    ld  [hl+], a
    dec b
    jp  nz, .zero_loop
    ret



; Write into OAM via DMA
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

