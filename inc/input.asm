; Update the object data for the alphabet cursor
update_cursor_objects:
    ld  hl, obj_selected_letter

    ; vertical position
    ld  a, [selected_letter_y]
    ld  b, $08
    call multiply_ab
    add a, $86
    ld  [hl+], a

    ; horizontal position
    ld  a, [selected_letter_x]
    ld  b, $10
    call multiply_ab
    add a, $14
    ld  [hl+], a

    ; tile index
    ld  a, [selected_letter_x]
    ld  c, a
    ld  a, [selected_letter_y]
    ld  b, $09
    call multiply_ab
    add a, c
    inc a
    
    ; char 27 doesn't exist, it's the enter sign
    cp  a, 27
    jp  nz, .not_enter
    ld  a, TILE_ENTER
.not_enter:
    ld  [hl+], a

    ; attributes
    ld  a, OBJ_ATTR_PALETTE1
    ld  [hl+], a
    ret



; Read the current input state
; -> b: current keystates
; -> c: changed keys since last read
read_input:
    di

    ; read right, left, up and down
    ld  a, %00100000
    ld  [INPUT_REGISTER], a
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    and a, $0f
    swap a
    ld  b, a

    ; read a, b, select and start
    ld  a, %00010000
    ld  [INPUT_REGISTER], a
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    ld  a, [INPUT_REGISTER]
    and a, $0f
    or  a, b
    cpl
    ld  b, a

    ; check for changed keystates
    ld  a, [input_state]
    xor a, b
    and a, b
    ld  c, a
    ld  a, b
    ld  [input_state], a
    reti



; React on input within the menu
handle_input_menu:
    ld  a, c
    and a, INPUT_START
    jp  z, .nothing
    call init_state_game

.nothing
    ret



; React on input within the main game
; <- c: changed keys since last read
handle_input_game:
    ld  a, [selected_letter_x]
    ld  d, a
    ld  a, [selected_letter_y]
    ld  e, a

.check_start:
    ld  a, c
    and a, INPUT_START
    jp  z, .check_select
    call init_state_game
    
.check_select:
    ld  a, c
    and a, INPUT_SELECT
    jp  z, .check_right
    call check_guess

.check_right:
    ld  a, c
    and a, INPUT_RIGHT
    jp  z, .check_left
    ld  a, d
    cp  a, $08
    jp  z, .check_left
    inc d

.check_left:
    ld  a, c
    and a, INPUT_LEFT
    jp  z, .check_up
    ld  a, d
    cp  a, 0
    jp  z, .check_up
    dec d

.check_up:
    ld  a, c
    and a, INPUT_UP
    jp  z, .check_down
    ld  a, e
    cp  a, 0
    jp  z, .check_down
    dec e

.check_down:
    ld  a, c
    and a, INPUT_DOWN
    jp  z, .check_a
    ld  a, e
    cp  a, $02
    jp  z, .check_a
    inc e

.check_a:
    ld  a, c
    and a, INPUT_A
    jp  z, .check_b
    call select_letter

.check_b:
    ld  a, c
    and a, INPUT_B
    jp  z, .update_pos
    call delete_letter

.update_pos
    ld  a, d
    ld  [selected_letter_x], a
    ld  a, e
    ld  [selected_letter_y], a
    ret



; React on input after a game round
handle_input_after:
    ld  a, c
    and a, INPUT_START
    jp  z, .nothing
    call init_state_game
    call clear_message

.nothing
    ret



; Add a character to the guess
; -> d: x position of the cursor
; -> e: y position of the cursor
select_letter:
    push hl
    push af
    push bc
    push de

    ; get the selected letter index
    ld  a, e
    ld  b, 9
    call multiply_ab
    add a, d
    inc a
    ld  c, a
    
    ; check if it's enter
    ld  a, c
    cp  a, 27
    jp  nz, .normal_letter
    call check_guess
    jp  .return

.normal_letter:
    ld  hl, guesses
    ld  a, [current_guess]
    ld  b, 5
    call multiply_ab
    ld  b, a
    ld  a, [current_char]
    cp  a, 5
    jp  z, .return
    add a, b
    ld  d, 0
    ld  e, a
    add hl, de
    ld  [hl], c
    
    ld  a, [current_char]
    inc a
    ld  [current_char], a

.return:
    pop de
    pop bc
    pop af
    pop hl
    ret



; Delete the last letter
delete_letter:
    push hl
    push af
    push bc
    push de

    ld  hl, guesses
    ld  a, [current_guess]
    ld  b, 5
    call multiply_ab
    ld  b, a
    ld  a, [current_char]
    ld  c, a
    cp  a, 0
    jp  z, .return
    add a, b
    dec a
    ld  d, 0
    ld  e, a
    add hl, de
    ld [hl], NULL
    
    ld  a, c
    dec a
    ld  [current_char], a
    
.return:
    pop de
    pop bc
    pop af
    pop hl
    ret

