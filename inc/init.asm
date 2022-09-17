;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; █▄░▄█░▄▄▀██▄██▄░▄██▄██░▄▄▀█░███▄██▄▄░█░▄▄▀█▄░▄██▄██▀▄▄▀█░▄▄▀██
;; ██░██░██░██░▄██░███░▄█░▀▀░█░███░▄█▀▄██░▀▀░██░███░▄█░██░█░██░██
;; █▀░▀█▄██▄█▄▄▄██▄██▄▄▄█▄██▄█▄▄█▄▄▄█▄▄▄█▄██▄██▄██▄▄▄██▄▄██▄██▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; Establish a defined initial state


; Initialize everything for the main game state
; <- [current_state]
; <- [sub_state]
; <- [BKG_POS_X_REGISTER]
; <- [BKG_POS_Y_REGISTER]
; <- [LCD_CONTROL_REGISTER]
; <- [message_objs]
init_state_menu:
    ld a, STATE_MENU
    ld [current_state], a
    ld a, STATE_MENU_START
    ld [sub_state], a
    
    ; set the background position
    ld  a, 0
    ld  [BKG_POS_X_REGISTER], a
    ld  [BKG_POS_Y_REGISTER], a
    
    call show_message_menu_start
    
    ; turn the screen on
    ld  a, DISPLAY_ON + TLS_USE_LOC_8000 \
         + BKG_DISPLAY_ON  + BKG_USE_LOC_9800 \
         + WND_DISPLAY_OFF + WND_USE_LOC_9C00 \
         + OBJ_DISPLAY_ON  + OBJ_SIZE_8X8
    ld  [LCD_CONTROL_REGISTER], a
    ret



; Initialize everything for the help screen
; <- [current_state]
; <- [BKG_POS_X_REGISTER]
; <- [BKG_POS_Y_REGISTER]
; <- [WND_POS_X_REGISTER]
; <- [WND_POS_Y_REGISTER]
; <- [LCD_CONTROL_REGISTER]
; <- [current_word]
; <- [guess]
; <- [guess_hints]
; <- [message_objs]
init_state_help:
    ld a, STATE_HELP
    ld [current_state], a
    
    ; turn the screen off
    ld  a, DISPLAY_OFF
    ld  [LCD_CONTROL_REGISTER], a
    
    call clear_message
    
    ; set the background position
    ld  a, 0
    ld  [BKG_POS_X_REGISTER], a
    ld  a, $9a
    ld  [BKG_POS_Y_REGISTER], a
    
    ; set the window position
    ld  a, 3
    ld  [WND_POS_X_REGISTER], a
    ld  a, $70
    ld  [WND_POS_Y_REGISTER], a

    ; load the window data
    ld  hl, window_help
    call load_window_map
    
    ; Set a fixed and actually impossible game state.
    ; containing: [current_word], [guess] and [guess_hints]
    ;
    ; This is only possible because the memory space of these
    ; three variables is located directly after each other.
    ld  hl, current_word
    ld  de, help_word
    ld  c, 65
.copy_gamestate:
    ld  a, [de]
    ld  [hl], a
    inc de
    inc hl
    dec c
    jp  nz, .copy_gamestate

    ; for the rest we can use the default functions
    call update_hint_markings
    call update_guess_objects
    
    ; turn the screen on
    ld  a, DISPLAY_ON + TLS_USE_LOC_8000 \
         + BKG_DISPLAY_ON + BKG_USE_LOC_9800 \
         + WND_DISPLAY_ON + WND_USE_LOC_9C00 \
         + OBJ_DISPLAY_ON + OBJ_SIZE_8X8
    ld  [LCD_CONTROL_REGISTER], a
    ret



; Initialize everything for the main game state
; <- [current_state]
; <- [BKG_POS_X_REGISTER]
; <- [BKG_POS_Y_REGISTER]
; <- [WND_POS_X_REGISTER]
; <- [WND_POS_Y_REGISTER]
; <- [LCD_CONTROL_REGISTER]
; <- [current_word]
; <- [current_guess]
; <- [current_char]
; <- [guess]
; <- [guess_hints]
; <- [selected_letter_x]
; <- [selected_letter_y]
; <- [message_objs]
init_state_game:
    ; set the current state
    ld a, STATE_GAME
    ld [current_state], a

    ; turn the screen off
    ld  a, DISPLAY_OFF
    ld  [LCD_CONTROL_REGISTER], a

    call select_word
    call clear_message

    ; set the background position
    ld  a, 0
    ld  [BKG_POS_X_REGISTER], a
    ld  a, $9a
    ld  [BKG_POS_Y_REGISTER], a
    
    ; set the window position
    ld  a, 3
    ld  [WND_POS_X_REGISTER], a
    ld  a, $70
    ld  [WND_POS_Y_REGISTER], a
    
    ; load the window data
    ld  hl, window_game
    call load_window_map
    
    ; initialize some more variables
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
    ld  a, DISPLAY_ON     + TLS_USE_LOC_8000 \
         + BKG_DISPLAY_ON + BKG_USE_LOC_9800 \
         + WND_DISPLAY_ON + WND_USE_LOC_9C00 \
         + OBJ_DISPLAY_ON + OBJ_SIZE_8X8
    ld  [LCD_CONTROL_REGISTER], a
    ret



; Switches to the state when the player has lost
; <- [current_state]
; <- [message_objs]
init_state_lost:
    ld  a, STATE_LOST
    ld  [current_state], a    
    call show_message_lost
    ret



; Switches to the state when the player has won
; <- [current_state]
; <- [message_objs]
init_state_won:
    ld  a, STATE_WON
    ld  [current_state], a
    call show_message_won
    ret



; Initialize the DMG color palettes
; <- [PALETTE_BKG_REGISTER]
; <- [PALETTE_OBJ0_REGISTER]
; <- [PALETTE_OBJ1_REGISTER]
init_palettes:
    ld  a, %10010011
    ld  [PALETTE_BKG_REGISTER], a
    ld  [PALETTE_OBJ0_REGISTER], a
    ld  [PALETTE_OBJ1_REGISTER], a
    ret



; Copy the tile data into the vram
; -> [tiles]
; <- [TLS_LOC_8000]
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



; Copy the background map into the vram
; -> [background]
; <- [BKG_LOC_9800]
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



; Copy a window map into the vram
; -> hl: address of the desired window map
; <- [WND_LOC_9C00]
load_window_map:
    ld  bc, WND_LOC_9C00
    ld  d, 32
    ld  e, 4

.loop:
    ld  a, [hl]
    ld [bc], a
    inc hl
    inc bc

    dec d
    jp  nz, .loop
    dec e
    jp  nz, .loop
    ret

