;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; ██░███░█▀▄▄▀█░▄▄▀█░▄▀█░██░▄▄██
;; ██░█░█░█░██░█░▀▀▄█░█░█░██░▄▄██
;; ██▄▀▄▀▄██▄▄██▄█▄▄█▄▄██▄▄█▄▄▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; The famous word puzzle

; Include hardware-specific constants
; used all over the code.
include "inc/constants.asm"


;; Game specific constants
; Game states
STATE_MENU              EQU %00000001
STATE_MENU_START        EQU %01000000
STATE_MENU_HELP         EQU %10000000
STATE_HELP              EQU %00000010
STATE_GAME              EQU %00000100
STATE_LOST              EQU %00001000
STATE_WON               EQU %00011000

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
TILE_ARROW              EQU $22



; Vertical blanking interrupt starting address
SECTION "ENTRY_VBLANK", ROM0[$0040]
    jp int_vblank ; used for game logic updates


; LCDC status interrupt starting address
SECTION "ENTRY_LCDCS", ROM0[$0048]
    reti ; we don't use this interrupt


; Timer overflow interrupt starting address
SECTION "ENTRY_TIMER", ROM0[$0050]
    jp int_timer ; used for generating randomness


; Serial transfer completion interrupt starting address
SECTION "ENTRY_SERIAL", ROM0[$0058]
    reti ; we don't use this interrupt


; Program starting address
SECTION "ENTRY_START", ROM0[$0100]
    jp main



SECTION "MAIN", ROM0[$0150]
main:
    ; turn the screen off until everything is initialized,
    ; or wild glitches will appear
    ld  a, DISPLAY_OFF
    ld  [LCD_CONTROL_REGISTER], a
    ld  [LCD_STATUS_REGISTER], a

    ; set the stack pointer
    ld  sp, INITIAL_STACK_POINTER

    ; load the video data
    call init_palettes
    call load_tiles
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
    jp  nz, .in_help
    call handle_input_menu
    jp  .cleanup

.in_help:
    cp  a, STATE_HELP
    jp  nz, .in_game
    call handle_input_help
    call update_hint_markings
    call update_guess_objects
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
include "inc/messages.asm"
include "inc/wincondition.asm"
include "inc/interrupts.asm"



;; Game data
SECTION "DATA0", ROM0[$1000]

;; Tiles
; Small 8x8 pixel images, which are addressable
; and will be used for sprite maps and objects.
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
tiles_arrow:
    include "tiles/sign-arrow.asm"
tiles_logo:
    include "tiles/logo.asm"
tiles_end:


;; Maps
; Each map defines a grid of tile addresses,
; which combined will form the desired image.
maps_start:
background:
    include "maps/background.asm"
window_help:
    include "maps/window-help.asm"
window_game:
    include "maps/window-game.asm"
maps_end:


;; Dictionary
; A list of known words to choose from.
dictionary:
    incbin "dict/en.dat"
dictionary_end:


;; Help data
; The help screen will reuse the normal
; game mechanics to provide a manual
; how to play this game.
; Now following is hard coded-data
; to provide a set of information.
help_word:
  DB $12, $09, $07, $08, $14 ; right

help_guess:
  DB $06, $01, $15, $0c, $14 ; fault
  DB $07, $09, $12, $14, $08 ; girth
  DB $12, $09, $07, $08, $14 ; right
  DB $0f, $0e, $0c, $19, $00 ; only
  DB $13, $09, $18, $00, $00 ; six
  DB $14, $12, $09, $05, $13 ; tries

help_guess_hints:
  DB TILE_WRONG,     TILE_WRONG,     TILE_WRONG,     TILE_WRONG,     TILE_RIGHT
  DB TILE_MISPLACED, TILE_MISPLACED, TILE_MISPLACED, TILE_MISPLACED, TILE_MISPLACED
  DB TILE_RIGHT,     TILE_RIGHT,     TILE_RIGHT,     TILE_RIGHT,     TILE_RIGHT
  DB TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE
  DB TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE
  DB TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE,     TILE_WHITE


;; Messages
; This game uses a message system to
; provide feedback to the user.
; For this, nine objects are reserved
; and can be used at will.
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
  DB $88, $70, 13, OBJ_ATTR_PALETTE1 ; M
  DB $88, $78, 05, OBJ_ATTR_PALETTE1 ; E

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
  DB $74, $38, 21, OBJ_ATTR_PALETTE1 ; U
  DB $74, $40, 14, OBJ_ATTR_PALETTE1 ; N
  DB $74, $48, 11, OBJ_ATTR_PALETTE1 ; k
  DB $74, $50, 14, OBJ_ATTR_PALETTE1 ; N
  DB $74, $58, 15, OBJ_ATTR_PALETTE1 ; O
  DB $74, $60, 23, OBJ_ATTR_PALETTE1 ; W
  DB $74, $68, 14, OBJ_ATTR_PALETTE1 ; N
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0

message_won:
  DB $74, $38, 25, OBJ_ATTR_PALETTE1 ; Y
  DB $74, $40, 15, OBJ_ATTR_PALETTE1 ; O
  DB $74, $48, 21, OBJ_ATTR_PALETTE1 ; U
  DB $74, $58, 23, OBJ_ATTR_PALETTE1 ; W
  DB $74, $60, 15, OBJ_ATTR_PALETTE1 ; O
  DB $74, $68, 14, OBJ_ATTR_PALETTE1 ; N
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0
  DB $00, $00,  0, 0
  
message_lost:
  DB $74, $30,  9, OBJ_ATTR_PALETTE1 ; I
  DB $74, $38, 20, OBJ_ATTR_PALETTE1 ; T
  DB $74, $40, 19, OBJ_ATTR_PALETTE1 ; S
  DB $74, $50,  0, OBJ_ATTR_PALETTE1 ; guess[0]
  DB $74, $58,  0, OBJ_ATTR_PALETTE1 ; guess[1]
  DB $74, $60,  0, OBJ_ATTR_PALETTE1 ; guess[2]
  DB $74, $68,  0, OBJ_ATTR_PALETTE1 ; guess[3]
  DB $74, $70,  0, OBJ_ATTR_PALETTE1 ; guess[4]
  DB $00, $00,  0, 0



;; Address reservations within the working ram
SECTION "RAM", WRAM0
; The first 160 Bytes are reserved for a copy
; of the OAM data, which will be updated via DMA.
obj_start:
obj_selected_letter:
    DS 4
obj_guess_letters:
    DS 120
obj_message_letters:
    DS 36
obj_end:
obj_dma_padding:
    DS 160 - (obj_end - obj_start)


; Will be set to 1 after each vblank interrupt
vblank_flag:
    DB

; Saves the current random number consisting of 16 bits
random_number:
    DS 2

; Saves the last keystate
input_state:
    DB

; Saves the current game state (see STATE constants)
current_state:
    DB

; Saves the subordinate state (see STATE constants)
sub_state:
    DB

; Number of the current guess (0..5)
current_guess:
    DB

; Position within the current guess (0..4)
current_char:
    DB

; Saves the current word
current_word:
    DS 5

; The guess attempts
guesses:
    DS 30

; The corresponding hints
guesses_hints:
    DS 30

; Message timeout (remaining number of frames)
message_timeout:
    DB

; Horizontal position of the letter selection within the alphabet grid
selected_letter_x:
    DB

; Vertical position of the letter selection within the alphabet grid
selected_letter_y:
    DB

