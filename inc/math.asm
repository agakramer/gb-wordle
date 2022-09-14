; Multiply a and b
; -> a, b
; <- a
multiply_ab:
    push de
    ld  d, a
    ld  e, b
    ld  b, 0
    or  a
    jp  z, .result

.loop:
    ld  d, a
    ld  a, b
    add a, e
    ld  b, a
    ld  a, d
    dec a
    jp  nz, .loop

.result:
    ld  a, b
    pop de
    ret

