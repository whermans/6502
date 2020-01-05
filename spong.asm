    PROCESSOR   6502
    INCLUDE     vcs.h
    INCLUDE     macro.h

;; ===================================
;; Switch between NTSC and PAL version
;; ===================================

NTSC            =   1
PAL             =   0

TV_VERSION      =   PAL

;; =========
;; Constants
;; =========

ROMTOP          =   $F000

    IF TV_VERSION   =   NTSC

;; NTSC Screen

OVERSCAN_TIME       =   34
VBLANK_TIME         =   42

SCANLINES           =   192
TOP_SCANLINES       =   39
BOTTOM_SCANLINES    =   113

;; NTSC Colors

BLACK               =   $00
WHITE               =   $0E

    ELSE

;; PAL Screen

OVERSCAN_TIME       =   43
VBLANK_TIME         =   54

SCANLINES           =   227
TOP_SCANLINES       =   48
BOTTOM_SCANLINES    =   139

;; PAL Colors

BLACK               =   $00
WHITE               =   $0E

    ENDIF

;; =========
;; Variables
;; =========

;; ====
;; Code
;; ====

    SEG         Bank0
    ORG         ROMTOP

Start
    SEI
    CLD
    LDX         #$FF
    TXS

    LDA         #0

ClearMem
    STA         0,X
    DEX
    BNE         ClearMem

    LDA         BLACK
    STA         COLUBK

    LDA         WHITE
    STA         COLUP0

MainLoop
    LDA         #2
    STA         VSYNC

    STA         WSYNC
    STA         WSYNC
    STA         WSYNC

    LDA         VBLANK_TIME
    STA         TIM64T

    LDA         #0
    STA         VSYNC

;; ========================
;; Game logic during VBLANK
;; ========================

;; =================
;; Prepare scan loop
;; =================

WaitVblankEnd
    LDA         INTIM
    BNE         WaitVblankEnd

    ldy         SCANLINES

    STA         WSYNC
    STA         HMOVE

ScanLoop
    STA         WSYNC
    LDA         #2
    STA         ENAM0

    DEY
    BNE         ScanLoop

    LDA         #2
    STA         WSYNC
    STA         VBLANK

;; ========
;; Overscan
;; ========

    LDX         OVERSCAN_TIME
OverscanLoop
    STA         WSYNC
    DEX
    BNE         OverscanLoop

    JMP         MainLoop

;; ====
;; Init
;; ====

    .ORG        ROMTOP + 4096 - 6,0
    .word       Start
    .word       Start
    .word       Start