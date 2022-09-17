;; ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
;; ██░▄▄░█░▄▄▀█░▄▀▄░█░▄▄████░▄▄▀█▀▄▄▀█░██░████░▄▄▀█▀▄▄▀█░▄▄▀█░▄▄█▄░▄█░▄▄▀█░▄▄▀█▄░▄█░▄▄██
;; ██░█▀▀█░▀▀░█░█▄█░█░▄▄████░▄▄▀█░██░█░▀▀░████░████░██░█░██░█▄▄▀██░██░▀▀░█░██░██░██▄▄▀██
;; ██░▀▀▄█▄██▄█▄███▄█▄▄▄████░▀▀░██▄▄██▀▀▀▄████░▀▀▄██▄▄██▄██▄█▄▄▄██▄██▄██▄█▄██▄██▄██▄▄▄██
;; ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;; Hardware specific values and addresses

; Interrupt Flags
INTERRUPT_SETTINGS      EQU $ffff
INT_VBLANK_ON           EQU %00000001
INT_VBLANK_OFF          EQU %00000000
INT_LCDC_ON             EQU %00000010
INT_LCDC_OFF            EQU %00000000
INT_TIMER_ON            EQU %00000100
INT_TIMER_OFF           EQU %00000000
INT_SERIAL_ON           EQU %00001000
INT_SERIAL_OFF          EQU %00000000

; LCD Control
LCD_CONTROL_REGISTER    EQU $ff40
LCD_POSITION_REGISTER   EQU $ff44
BKG_DISPLAY_ON          EQU %00000001
BKG_DISPLAY_OFF         EQU %00000000
OBJ_DISPLAY_ON          EQU %00000010
OBJ_DISPLAY_OFF         EQU %00000000
OBJ_SIZE_8X8            EQU %00000000
OBJ_SIZE_16X8           EQU %00000100
BKG_USE_LOC_9800        EQU %00000000
BKG_USE_LOC_9C00        EQU %00001000
TLS_USE_LOC_8800        EQU %00000000
TLS_USE_LOC_8000        EQU %00010000
WND_DISPLAY_ON          EQU %00100000
WND_DISPLAY_OFF         EQU %00000000
WND_USE_LOC_9800        EQU %00000000
WND_USE_LOC_9C00        EQU %01000000
DISPLAY_ON              EQU %10000000
DISPLAY_OFF             EQU %00000000

; LCD Status
LCD_STATUS_REGISTER     EQU $ff41
LCD_VBLANK_MODE         EQU %00000000
LCD_HBLANK_MODE         EQU %00000001
LCD_SPRITE_MODE         EQU %00000010
LCD_TRANSFER_ACTIVE     EQU %00000011

; Timer
TIMER_REGISTER          EQU $ff06
TIMER_SETTINGS          EQU $ff07
TIMER_4KHZ              EQU %00000000
TIMER_16KHZ             EQU %00000011
TIMER_65KHZ             EQU %00000010
TIMER_262KHZ            EQU %00000001
TIMER_START             EQU %00000100
TIMER_STOP              EQU %00000000

; Input Register
INPUT_REGISTER          EQU $ff00
INPUT_A                 EQU %00000001
INPUT_B                 EQU %00000010
INPUT_SELECT            EQU %00000100
INPUT_START             EQU %00001000
INPUT_RIGHT             EQU %00010000
INPUT_LEFT              EQU %00100000
INPUT_UP                EQU %01000000
INPUT_DOWN              EQU %10000000

; Video Registers
BKG_POS_X_REGISTER      EQU $ff43
BKG_POS_Y_REGISTER      EQU $ff42
WND_POS_X_REGISTER      EQU $ff4b
WND_POS_Y_REGISTER      EQU $ff4a

; DMA Register
DMA_REGISTER            EQU $ff46

; Palette Registers
PALETTE_BKG_REGISTER    EQU $ff47
PALETTE_OBJ0_REGISTER   EQU $ff48
PALETTE_OBJ1_REGISTER   EQU $ff49

; Video Locations
TLS_LOC_8000            EQU $8000
TLS_LOC_8800            EQU $8800
BKG_LOC_9800            EQU $9800
BKG_LOC_9C00            EQU $9C00
WND_LOC_9800            EQU $9800
WND_LOC_9C00            EQU $9c00

; Object attributes
OBJ_ATTR_PALETTE0       EQU %00000000
OBJ_ATTR_PALETTE1       EQU %00010000
OBJ_ATTR_MIRROR_X       EQU %00100000
OBJ_ATTR_MIRROR_Y       EQU %01000000
OBJ_ATTR_PRIORITY       EQU %10000000

; Initial Stack Pointer
INITIAL_STACK_POINTER   EQU $fff4

