; Initialise everything for the main game state
init_state_menu:
    ld a, STATE_MENU
    ld [current_state], a
    
    ; set the background position
    ld  a, 0
    ld  [BKG_POS_X_REGISTER], a
    ld  [BKG_POS_Y_REGISTER], a
    
    ; turn the screen on
    ld  a, DISPLAY_ON + TLS_USE_LOC_8000 \
         + BKG_DISPLAY_ON + BKG_USE_LOC_9800 \
         + WND_DISPLAY_OFF + WND_USE_LOC_9C00 \
         + OBJ_DISPLAY_OFF + OBJ_SIZE_8X8
    ld  [LCD_CONTROL_REGISTER], a
    ret
    


; Initialise everything for the main game state
init_state_game:
    ; set the current state
    ld a, STATE_GAME
    ld [current_state], a

    call select_word

    ; set the background position
    ld  a, 0
    ld  [BKG_POS_X_REGISTER], a
    ld  a, $9a
    ld  [BKG_POS_Y_REGISTER], a
    
    ; set the window position
    ld  a, 3
    ld  [WND_POS_X_REGISTER], a
    ld  a, $5e
    ld  [WND_POS_Y_REGISTER], a
    
    ; initialise some more variables
    ld  a, 0
    ld  [selected_letter_x], a
    ld  [selected_letter_y], a
    ld  [current_guess], a
    ld  [current_char], a
    
.reset_guesses
    ld  hl, guesses
    ld  a, NULL
    ld  d, 30
.loop1:
    ld  [hl+], a
    dec d
    jp  nz, .loop1

.reset_hints
    ld  hl, guesses_hints
    ld  a, TILE_WHITE
    ld  d, 30
.loop2:
    ld  [hl+], a
    dec d
    jp  nz, .loop2
    
    ; turn the screen on
    ld  a, DISPLAY_ON + TLS_USE_LOC_8000 \
         + BKG_DISPLAY_ON + BKG_USE_LOC_9800 \
         + WND_DISPLAY_ON + WND_USE_LOC_9C00 \
         + OBJ_DISPLAY_ON + OBJ_SIZE_8X8
    ld  [LCD_CONTROL_REGISTER], a
    ret



; Switches to the lost state
init_state_lost:
    ld  a, STATE_LOST
    ld  [current_state], a    
    call show_message_lost
    ret



; Switches to the won state
init_state_won:
    ld  a, STATE_WON
    ld  [current_state], a
    call show_message_won
    ret



; Initialise the DMG color palettes
init_palettes:
    ld  a, %10010011
    ld  [PALETTE_BKG_REGISTER], a
    ld  [PALETTE_OBJ0_REGISTER], a
    ld  [PALETTE_OBJ1_REGISTER], a
    ret



; Load the tile data into the vram
load_tiles:
    ld  bc, tiles_start
    ld  hl, TLS_LOC_8000
    ld  d, $10
    ld  e, (tiles_end - tiles_start) / $10

.loop:
    ld  a, [bc]
    ld [hl], a
    inc bc
    inc hl

    dec d
    jp  nz, .loop
    dec e
    jp  nz, .loop
    ret



; Load the background map into the vram
load_background_map:
    ld  bc, background
    ld  hl, BKG_LOC_9800
    ld  d, 32
    ld  e, 32

.loop:
    ld  a, [bc]
    ld [hl], a
    inc bc
    inc hl

    dec d
    jp  nz, .loop
    dec e
    jp  nz, .loop
    ret



; Load the window map into the vram
load_window_map:
    ld  bc, window
    ld  hl, WND_LOC_9C00
    ld  d, 32
    ld  e, 32

.loop:
    ld  a, [bc]
    ld [hl], a
    inc bc
    inc hl

    dec d
    jp  nz, .loop
    dec e
    jp  nz, .loop
    ret

