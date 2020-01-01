    PROCESSOR   6502
    INCLUDE     "./vcs.h"
    ORG         $F000

;;
;; Variables
;;

;;
;; Setup
;;

Start
	sei
	cld
	ldx			#$FF
	txs
	lda			#0

ClearMem
	sta			0,X
	dex
	bne			ClearMem

Main
    LDA         #2          ;; turn off electron beam and return to start position
    STA         VSYNC       ;; set sync three times
    STA         WSYNC
    STA         WSYNC
    STA         WSYNC
    LDA         #0      
    STA         VSYNC       ;; electron beam on again

    LDA         #43         ;; ((37 scanlines * 76 machine cycles) + 5 timer init cycles + 3 VSYNC cycles + 6 loop cycles - 14 VBLANK cycles)/64
    STA         TIM64T      ;; set timer

    LDA         #2
    STA         VBLANK

;;
;;  Game logic
;;


WaitVblank
    LDA         INTIM
    bne         WaitVblank  ;; idle while timer runs out

    STA         WSYNC

    LDY         #191        ;; number of scanlines
    STA         WSYNC
    STA         VBLANK

    LDA         #$00
    STA         WSYNC


;;
;; Display
;;

Display
    STA         WSYNC

EndDisplay
    DEY         
    BNE         Display     ;; continue drawing lines until the screen is full

    LDA         #2
    STA         WSYNC
    STA         VBLANK

    LDX         #30         ;; 30 lines of overscan

Overscan
    STA         WSYNC
    DEX
    BNE         Overscan

    JMP         Main

;;
;; Reset
;;

    ORG         $FFFC
    .word       Start
    .word       Start