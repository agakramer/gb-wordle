include "inc/constants.asm"

;; Game specific constants
; Game states
STATE_MENU              EQU %00000001
STATE_MENU_START        EQU %01000001
STATE_MENU_HELP         EQU %10000001
STATE_GAME              EQU %00000010
STATE_LOST              EQU %00000100
STATE_WON               EQU %00001100

; Marker for invalid or undefined values
NULL                    EQU $00

;; Indices of special tiles
TILE_NULL               EQU NULL
TILE_BLACK              EQU $1b
TILE_WHITE              EQU $1c
TILE_PLACEHOLDER        EQU $1d
TILE_ENTER              EQU $1e
TILE_RIGHT              EQU $1f
TILE_MISPLACED          EQU $20
TILE_WRONG              EQU $21



; Vertical blanking interrupt starting address
SECTION "ENTRY_VBLANK", ROM0[$0040]
    jp int_vblank


; LCDC status interrupt starting address
SECTION "ENTRY_LCDCS", ROM0[$0048]
    reti


; Timer overflow interrupt starting address
SECTION "ENTRY_TIMER", ROM0[$0050]
    jp int_timer


; Serial transfer completion interrupt starting address
SECTION "ENTRY_SERIAL", ROM0[$0058]
    reti


; Program starting address
SECTION "ENTRY_START", ROM0[$0100]
    jp main



SECTION "MAIN", ROM0[$0150]
main:
    ; turn the screen off until everything is initialised
    ld  a, DISPLAY_OFF
    ld  [LCD_CONTROL_REGISTER], a
    ld  [LCD_STATUS_REGISTER], a

    ; set the stack pointer
    ld  sp, INITIAL_STACK_POINTER

    ; load the video data
    call init_palettes
    call load_tiles
    call load_window_map
    call load_background_map

    ; initialise the objects
    call init_oam_copy
    call update_oam

    ; initialise the game state
    call init_state_menu

    ; enable specific interrupts
    ld  a, INT_VBLANK_ON + INT_TIMER_ON
    ld  [INTERRUPT_SETTINGS], a
    
    ; configure the timer
    ld  a, TIMER_START + TIMER_16KHZ
    ld  [TIMER_SETTINGS], a



; Every frame consists of the phases:
; 1) The display will be updated.
;    Within this period we can't alter the graphics data.
;    We use this time to handle input and calculate stuff.
; 2) The display was updated.
;    Now we have a limited time frame where we can update
;    all graphic related memory locations.
main_loop:
    ld  a, [vblank_flag]
    cp  a, 0
    jp	z, main_loop

.within_vblank:
    call update_oam
    call read_input
    
    ld  a, [current_state]

.in_menu:
    cp  a, STATE_MENU
    jp  nz, .in_game
    call handle_input_menu
    jp  .cleanup

.in_game:
    cp  a, STATE_GAME
    jp  nz, .in_won
    call handle_input_game
    call update_hint_markings
    call update_guess_objects
    call update_cursor_objects
    jp  .cleanup

.in_won:
    cp  a, STATE_WON
    jp  nz, .in_lost
    call handle_input_after
    call update_hint_markings
    jp  .cleanup

.in_lost:
    cp  a, STATE_LOST
    jp  nz, .cleanup
    call handle_input_after
    call update_hint_markings
    jp  .cleanup

.cleanup:
    ; reset vblank flag
    ld  a, 0
    ld  [vblank_flag], a
    
    call check_message_timeout
    jp  main_loop



include "inc/init.asm"
include "inc/math.asm"
include "inc/oam.asm"
include "inc/dict.asm"
include "inc/input.asm"
include "inc/guess.asm"
include "inc/hints.asm"
include "inc/search.asm"
include "inc/messages.asm"
include "inc/wincondition.asm"
include "inc/interrupts.asm"



;; Game data
SECTION "DATA0", ROM0[$1000]
; Tiles
tiles_start:
tile_null:
    include "tiles/plain-null.asm"
tiles_alphabet:
    include "tiles/alphabet.asm"
tile_black:
    include "tiles/plain-black.asm"
tile_white:
    include "tiles/plain-white.asm"
tiles_placeholder:
    include "tiles/sign-placeholder.asm"
tiles_enter:
    include "tiles/sign-enter.asm"
tiles_right:
    include "tiles/sign-right.asm"
tile_misplaced:
    include "tiles/sign-misplaced.asm"
tiles_wrong:
    include "tiles/sign-wrong.asm"
tiles_logo:
    include "tiles/logo.asm"
tiles_end:



; Maps
maps_start:
background:
    include "maps/background.asm"
window:
    include "maps/window.asm"
maps_end:

dictionary:
    incbin "dict/en.dat"
dictionary_end:
    DB



; Messages
message_clear:
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00
  DB $00, $00, $00, $00

message_menu_start:
  DB $88, $30, 19, OBJ_ATTR_PALETTE1 ; S
  DB $88, $38, 20, OBJ_ATTR_PALETTE1 ; T
  DB $88, $40, 01, OBJ_ATTR_PALETTE1 ; A
  DB $88, $48, 18, OBJ_ATTR_PALETTE1 ; R
  DB $88, $50, 20, OBJ_ATTR_PALETTE1 ; T
  DB $88, $60, 07, OBJ_ATTR_PALETTE1 ; G
  DB $88, $68, 01, OBJ_ATTR_PALETTE1 ; A
  DB $88, $70, 13, OBJ_ATTR_PALETTE1 ; G
  DB $88, $78, 05, OBJ_ATTR_PALETTE1 ; A

message_menu_help:
  DB $90, $30, 08, OBJ_ATTR_PALETTE1 ; H
  DB $90, $38, 15, OBJ_ATTR_PALETTE1 ; O
  DB $90, $40, 23, OBJ_ATTR_PALETTE1 ; W
  DB $90, $50, 20, OBJ_ATTR_PALETTE1 ; T
  DB $90, $58, 15, OBJ_ATTR_PALETTE1 ; O
  DB $90, $68, 16, OBJ_ATTR_PALETTE1 ; P
  DB $90, $70, 12, OBJ_ATTR_PALETTE1 ; L
  DB $90, $78, 01, OBJ_ATTR_PALETTE1 ; A
  DB $90, $80, 25, OBJ_ATTR_PALETTE1 ; Y

message_unknown:
  DB $7a, $38, 21, OBJ_ATTR_PALETTE1 ; U
  DB $7a, $40, 14, OBJ_ATTR_PALETTE1 ; N
  DB $7a, $48, 11, OBJ_ATTR_PALETTE1 ; k
  DB $7a, $50, 14, OBJ_ATTR_PALETTE1 ; N
  DB $7a, $58, 15, OBJ_ATTR_PALETTE1 ; O
  DB $7a, $60, 23, OBJ_ATTR_PALETTE1 ; W
  DB $7a, $68, 14, OBJ_ATTR_PALETTE1 ; N
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0

message_won:
  DB $7a, $38, 25, OBJ_ATTR_PALETTE1 ; Y
  DB $7a, $40, 15, OBJ_ATTR_PALETTE1 ; O
  DB $7a, $48, 21, OBJ_ATTR_PALETTE1 ; U
  DB $7a, $58, 23, OBJ_ATTR_PALETTE1 ; W
  DB $7a, $60, 15, OBJ_ATTR_PALETTE1 ; O
  DB $7a, $68, 14, OBJ_ATTR_PALETTE1 ; N
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0
  
message_lost:
  DB $7a, $30,  9, OBJ_ATTR_PALETTE1 ; I
  DB $7a, $38, 20, OBJ_ATTR_PALETTE1 ; T
  DB $7a, $40, 19, OBJ_ATTR_PALETTE1 ; S
  DB $7a, $50,  0, OBJ_ATTR_PALETTE1 ; guess[0]
  DB $7a, $58,  0, OBJ_ATTR_PALETTE1 ; guess[1]
  DB $7a, $60,  0, OBJ_ATTR_PALETTE1 ; guess[2]
  DB $7a, $68,  0, OBJ_ATTR_PALETTE1 ; guess[3]
  DB $7a, $70,  0, OBJ_ATTR_PALETTE1 ; guess[4]
  DB $00, $00,  0, 0



; Address reservations within the working ram
SECTION "RAM", WRAM0
; The first 160 Bytes are reserved for a copy
; of the OAM data, which will be updated via DMA.
obj_start:
obj_selected_letter:
    DS 4
obj_guess_letters:
    DS 120
obj_message_letters:
    DS 32
obj_end:
obj_dma_padding:
    DS 160 - (obj_end - obj_start)


; Will be set to 1 after each vblank interrupt
vblank_flag:
    DB

; Saves the current 16bit random number
random_number:
    DS 2

; Saves the last keystate
input_state:
    DB

; Saves the current game state
current_state:
    DB

; Saves the state in the submenu
sub_state:
    DB

; Saves the current word
current_word:
    DS 5

; Number of the current guess
current_guess:
    DB

; Position within the current guess
current_char:
    DB

; The guess attempts
guesses:
    DS 30
; The corresponding hints
guesses_hints:
    DS 30

; Message timeout
message_timeout:
    DB

; Horizontal position of the letter selection
selected_letter_x:
    DB

; Vertical position of the letter selection
selected_letter_y:
    DB

