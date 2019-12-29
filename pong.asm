	processor 	6502
	include 	"./vcs.h"
	org			$F000

;;
;; Variables in memory
;;

dot_x		=	$80
dot_y		=	$81
dot_v		=	$82
dot_sz		=	$83

y_max		=	$84
y_min		=	$85

p0_y		=	$86
p1_y		=	$87

p0_sz		=	$88
p1_sz		=	$89

p0_sz_real	=	$90
p1_sz_real	=	$91

p0_life		=	$92
p1_life 	=	$93

;;
;; Program code
;;

;; Entry point

Start
	sei
	cld
	ldx			#$FF
	txs
	lda			#0

Clear_mem
	sta			0,X
	dex
	bne			Clear_mem

	lda			#190
	sta 		dot_y
	lda			#194
	sta 		y_max
	lda			#6
	sta 		y_min

	lda			#0
	sta 		dot_sz
	sta 		dot_v
	lda			#$10
	sta 		dot_x
	
	lda			#110
	sta 		p0_y
	sta 		p1_y
	lda			#0
	sta 		p0_sz
	sta 		p1_sz
	lda			#30
	sta 		p0_sz_real
	sta 		p1_sz_real
	lda 		#30
	sta 		p0_life
	sta 		p1_life

Define_colors
	lda			#$0E
	sta 		COLUBK 	
	lda			#$21
	sta 		CTRLPF
	lda			#$10
	sta 		PF0
	lda 		#$10	
	sta 		COLUPF

;;
;; Game logic loop
;;

Main
	;; Position electron beam
	lda 		#2
	sta 		VSYNC

	sta 		WSYNC
	sta 		WSYNC
	sta 		WSYNC
	
	lda 		#0
	sta 		VSYNC

	lda 		#43
	sta   		TIM64T

	lda			#2
	sta  		VBLANK

	;; Clock is running

	lda 		dot_v
	bne			Check_dot_direction
	dec 		dot_y
	lda 		y_min
	cmp			dot_y
	bne 		Control_p0_down

Check_dot_direction
	lda			#1
	sta 		dot_v
	inc 		dot_y
	lda 		y_max
	cmp 		dot_y
	bne 		Control_p0_down
	lda 		#0
	sta 		dot_v

Control_p0_down
	lda			#%00010000
	bit 		SWCHA
	bne			Control_p0_up
	inc 		p0_y
	inc 		p0_y

Control_p0_up
	lda			#%00100000
	bit 		SWCHA
	bne			Control_p1_down
	dec 		p0_y
	dec 		p0_y

Control_p1_down
	lda			#%00000001
	bit 		SWCHA
	bne			Control_p1_up
	inc 		p1_y
	inc 		p1_y	

Control_p1_up
	lda			#%00000010
	bit 		SWCHA
	bne			Control_p0_collision
	dec 		p1_y
	dec 		p1_y

Control_p0_collision
	lda			#%1000000
	bit 		CXP0FB
	beq			Control_p1_collision
	lda			#$10
	sta 		dot_x

Control_p1_collision
	lda			#%1000000
	bit 		CXP1FB
	beq			Control_playfield_collision
	lda			#$F0
	sta 		dot_x

Control_playfield_collision
	lda			#%10000000
	bit			CXBLPF
	beq			Control_no_collision
	sta 		CXCLR
	ldx			#$10
	cpx 		dot_x
	beq 		Penalty_p1

Penalty_p0
	dec 		p0_sz_real
	dec 		p0_life
	beq			End
	jmp			Control_no_collision

Penalty_p1
	dec 		p1_sz_real
	dec 		p1_life
	beq			End
	jmp			Control_no_collision

Control_no_collision
	sta 		CXCLR
	jmp 		Wait_vblank

End
	jmp Start

;; 
;; Display loop
;;

Wait_vblank
	lda 		INTIM
	bne 		Wait_vblank

	sta 		WSYNC
	sta 		RESP1

	ldy 		#191
	sta 		WSYNC
	sta 		VBLANK

	lda 		dot_x
	sta 		HMBL
	lda 		#$00
	sta 		GRP0
	sta 		GRP1

	sta 		WSYNC
	sta 		HMOVE

Scan
	sta 		WSYNC

Dot_check
	cpy 		dot_y
	beq 		Dot_set_size
	lda 		dot_sz
	bne 		Dot_draw

Dot_none
	lda			#0
	sta 		ENABL
	jmp 		P0_check

Dot_set_size
	lda			#8
	sta 		dot_sz

Dot_draw
	lda 		#2
	sta 		ENABL
	dec 		dot_sz

P0_check
	cpy 		p0_y
	beq 		P0_set_size
	lda 		p0_sz
	bne 		P0_draw

P0_none
	lda			#0
	sta 		GRP0
	jmp			P1_check

P0_set_size
	lda 		p0_sz_real
	sta 		p0_sz

P0_draw
	lda 		#2
	sta 		GRP0
	dec 		p0_sz

P1_check
	cpy 		p1_y
	beq 		P1_set_size
	lda 		p1_sz
	bne 		P1_draw

P1_none
	lda			#0
	sta 		GRP1
	jmp			Scan_end

P1_set_size
	lda 		p1_sz_real
	sta 		p1_sz

P1_draw
	lda 		#2
	sta 		GRP1
	dec 		p1_sz

Scan_end
	dey
	bne 		Scan

	lda 		#2
	sta 		WSYNC
	sta 		VBLANK

	ldx			#30

Overscan
	sta 		WSYNC
	dex
	bne 		Overscan

	jmp 		Main

;;
;; On reset, start at memory address defined by 'start'
;;

	org			$FFFC
	.word		Start
	.word		Start