; Check if the guess is valid
check_guess:
    push hl
    push af
    push bc
    push de

	; five characters are needed
    ld  a, [current_char]
    cp  a, 5
    jp  nz, .return

	; Compress the guess to the dictionary format,
	; and then search after it.
    call compress_guess
    call find_guess
    
    cp  a, 1
    jp  nz, .is_invalid

.is_valid:
    call mark_hints

.test_win:    
    call check_win
    cp  a, 1
    jp  nz, .test_lose
    call init_state_won
    jp  .return

.test_lose:
    ld  a, [current_guess]
    cp  a, 5
    jp  nz, .reset
    call init_state_lost
    jp  .return

.reset:
    ld  a, [current_guess]
    inc a
    ld  [current_guess], a
    ld  a, 0
    ld  [current_char], a
    jp  .return

.is_invalid:
    call show_message_unknown
    jp  .return

.return:
    pop de
    pop bc
    pop af
    pop hl
    ret



; Check the win conditions
; <- a
check_win:
	call get_guess_offset
    ld  bc, current_word
    ld  a, [bc]
    ld  d, a
    ld  a, [hl]
    cp  a, d
    jp  nz, .not_equal

REPT 4
    inc bc
    inc hl
    ld  a, [bc]
    ld  d, a
    ld  a, [hl]
    cp  a, d
    jp  nz, .not_equal
ENDR

.equal:
    ld  a, 1
    ret

.not_equal:
    ld  a, 0
    ret

