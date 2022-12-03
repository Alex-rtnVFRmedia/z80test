org #8000
	jp Start
;	jp PutSprite
;	jp GetMempos
Result:	dw 0		; blanco place to store HL for testing


; note to self, do not put colon after equ statements or that doesn't work

Start:
width	equ 6		; width in bytes
height	equ 24		; height in lines
delay	equ 2		; delay to slow down animation

	ld b,5
	ld c,100		; set x and y
	
; test code commented out or BC gets clobbered here and everything is offset
;	call GetScreenPos
;	ld (result),hl		; get screen address and store in test area

	ld ixl,5
 


Loop3:	
		
Loop1:	
	push bc			; save coordinates
	
	ld de, Sprite1		; get the address of the smiley
	call WaitVs
	call PutSprite		; put sprite to screen and RET at end of this
	ld b, delay
Dloop:	djnz Dloop
	pop bc
	inc b
	ld a,70
	cp b
	jr nz,Loop1
Loop2:				; now do the same backwards
	push bc
	
	ld de, Sprite1
	call WaitVs
	call PutSprite
	ld b, delay
Dloop2:	djnz Dloop2
	pop bc	
	dec b	
	jr nz, Loop2

	dec ixl
	ret z
	jr Loop3

; wait for a vsync to avoid flicker

WaitVs:	
	ld a, &F5
	in a, (&DB)	; bit 0 is vsync
	rra		; roll it right into the carry
	jr nc, WaitVs
	ret

GetScreenPos:
	; B = x coordinate (bytes) C = y coordinate (lines)
	
	push bc	; preserve BC
		ld b,0
		ld hl,ScrAddrTable
		add hl,bc
		add hl,bc	; twice as there are two bytes in table
		ld a,(hl)
		inc l		; we don't need to worry about H 
		ld h,(hl)	; get the high byte at offset+01 in each word
		ld l,a		; get the lowbyte
	pop bc
	ld c,b			; get x coordinate bback into lowbyte
	ld b,#C0		; b = highbyte start of screen
	add hl,bc
	ret			; HL = screen position address

GetNextLine:			; HL = screen address
	ld a,h			
	add #08			
	ld h,a			;add #0800 to H
	bit 7,h			;have we rolled over the end of screen memory?
	ret nz			;return if not
	ld bc,#C050		;rollover correction
	add hl,bc
	ret			;HL now corrected

;PutSprite  DE = sprite address HL = screen address / BC = x (bytes), y (lines)
; iyh = height (lines), iyl = width (bytes), not used as hardcoded to 6 bytes here
		
PutSprite:

	ld iyh,height
	call GetScreenPos
DoLine:
	push hl			; or HL will be offset by next bit of code
	ex hl,de		; now DE is screen address and HL is sprite index
; clear trail at left 
; (NB cursed code, this will corrupt memory just before the framebuffer if BC=0)
	dec de			; go back one byte
	xor a
	ld (de),a
	inc de			; put de back to where it should be

	ldi
	ldi
	ldi
	ldi
	ldi
	ldi			; do all 6 bytes
; clear the trail
	xor a			; zero accumulator
	ld (de),a		; put the zero to the framebuffer 
	ex hl,de		; HL is screen address and DE is sprite index
	pop hl			; get original screen address
	call GetNextLine
	dec iyh
	jp nz,DoLine		; repeat the line
	ret
	


; lookup table for screen addresses, offset from screenstart

align 2
ScrAddrTable:
    defb &00,&00, &00,&08, &00,&10, &00,&18, &00,&20, &00,&28, &00,&30, &00,&38;1
    defb &50,&00, &50,&08, &50,&10, &50,&18, &50,&20, &50,&28, &50,&30, &50,&38;2
    defb &A0,&00, &A0,&08, &A0,&10, &A0,&18, &A0,&20, &A0,&28, &A0,&30, &A0,&38;3
    defb &F0,&00, &F0,&08, &F0,&10, &F0,&18, &F0,&20, &F0,&28, &F0,&30, &F0,&38;4
    defb &40,&01, &40,&09, &40,&11, &40,&19, &40,&21, &40,&29, &40,&31, &40,&39;5
    defb &90,&01, &90,&09, &90,&11, &90,&19, &90,&21, &90,&29, &90,&31, &90,&39;6
    defb &E0,&01, &E0,&09, &E0,&11, &E0,&19, &E0,&21, &E0,&29, &E0,&31, &E0,&39;7
    defb &30,&02, &30,&0A, &30,&12, &30,&1A, &30,&22, &30,&2A, &30,&32, &30,&3A;8
    defb &80,&02, &80,&0A, &80,&12, &80,&1A, &80,&22, &80,&2A, &80,&32, &80,&3A;9
    defb &D0,&02, &D0,&0A, &D0,&12, &D0,&1A, &D0,&22, &D0,&2A, &D0,&32, &D0,&3A;10
    defb &20,&03, &20,&0B, &20,&13, &20,&1B, &20,&23, &20,&2B, &20,&33, &20,&3B;11
    defb &70,&03, &70,&0B, &70,&13, &70,&1B, &70,&23, &70,&2B, &70,&33, &70,&3B;12
    defb &C0,&03, &C0,&0B, &C0,&13, &C0,&1B, &C0,&23, &C0,&2B, &C0,&33, &C0,&3B;13
    defb &10,&04, &10,&0C, &10,&14, &10,&1C, &10,&24, &10,&2C, &10,&34, &10,&3C;14
    defb &60,&04, &60,&0C, &60,&14, &60,&1C, &60,&24, &60,&2C, &60,&34, &60,&3C;15
    defb &B0,&04, &B0,&0C, &B0,&14, &B0,&1C, &B0,&24, &B0,&2C, &B0,&34, &B0,&3C;16
    defb &00,&05, &00,&0D, &00,&15, &00,&1D, &00,&25, &00,&2D, &00,&35, &00,&3D;17
    defb &50,&05, &50,&0D, &50,&15, &50,&1D, &50,&25, &50,&2D, &50,&35, &50,&3D;18
    defb &A0,&05, &A0,&0D, &A0,&15, &A0,&1D, &A0,&25, &A0,&2D, &A0,&35, &A0,&3D;19
    defb &F0,&05, &F0,&0D, &F0,&15, &F0,&1D, &F0,&25, &F0,&2D, &F0,&35, &F0,&3D;20
    defb &40,&06, &40,&0E, &40,&16, &40,&1E, &40,&26, &40,&2E, &40,&36, &40,&3E;21
    defb &90,&06, &90,&0E, &90,&16, &90,&1E, &90,&26, &90,&2E, &90,&36, &90,&3E;22
    defb &E0,&06, &E0,&0E, &E0,&16, &E0,&1E, &E0,&26, &E0,&2E, &E0,&36, &E0,&3E;23
    defb &30,&07, &30,&0F, &30,&17, &30,&1F, &30,&27, &30,&2F, &30,&37, &30,&3F;24
    defb &80,&07, &80,&0F, &80,&17, &80,&1F, &80,&27, &80,&2F, &80,&37, &80,&3F;25

Sprite1:
defb &00,&00,&00,&00,&00,&00; line 0
defb &00,&00,&70,&E0,&00,&00; line 1
defb &00,&10,&80,&10,&80,&00; line 2
defb &00,&20,&00,&00,&60,&00; line 3
defb &00,&C0,&00,&00,&10,&00; line 4
defb &00,&80,&00,&00,&00,&80; line 5
defb &10,&30,&00,&00,&C0,&80; line 6
defb &20,&70,&80,&10,&E0,&40; line 7
defb &20,&70,&80,&10,&E0,&40; line 8
defb &40,&30,&00,&00,&C0,&20; line 9
defb &40,&00,&00,&00,&00,&20; line 10
defb &40,&00,&00,&00,&00,&20; line 11
defb &40,&00,&00,&00,&00,&20; line 12
defb &40,&00,&00,&00,&00,&20; line 13
defb &40,&30,&00,&00,&C0,&20; line 14
defb &20,&30,&00,&00,&C0,&40; line 15
defb &20,&10,&80,&10,&80,&40; line 16
defb &10,&00,&F0,&F0,&00,&80; line 17
defb &10,&00,&70,&E0,&00,&80; line 18
defb &00,&80,&00,&00,&10,&00; line 19
defb &00,&60,&00,&00,&60,&00; line 20
defb &00,&10,&80,&10,&80,&00; line 21
defb &00,&00,&70,&E0,&00,&00; line 22
defb &00,&00,&00,&00,&00,&00; line 23


.maskLookupTable ; lookup table for masks, indexed by sprite byte. AND with screen data, then OR with pixel data.
defb &FF,&EE,&DD,&CC,&BB,&AA,&99,&88,&77,&66,&55,&44,&33,&22,&11,&00,&EE,&EE,&CC,&CC,&AA,&AA,&88,&88,&66,&66,&44,&44,&22,&22,&00,&00
defb &DD,&CC,&DD,&CC,&99,&88,&99,&88,&55,&44,&55,&44,&11,&00,&11,&00,&CC,&CC,&CC,&CC,&88,&88,&88,&88,&44,&44,&44,&44,&00,&00,&00,&00
defb &BB,&AA,&99,&88,&BB,&AA,&99,&88,&33,&22,&11,&00,&33,&22,&11,&00,&AA,&AA,&88,&88,&AA,&AA,&88,&88,&22,&22,&00,&00,&22,&22,&00,&00
defb &99,&88,&99,&88,&99,&88,&99,&88,&11,&00,&11,&00,&11,&00,&11,&00,&88,&88,&88,&88,&88,&88,&88,&88,&00,&00,&00,&00,&00,&00,&00,&00
defb &77,&66,&55,&44,&33,&22,&11,&00,&77,&66,&55,&44,&33,&22,&11,&00,&66,&66,&44,&44,&22,&22,&00,&00,&66,&66,&44,&44,&22,&22,&00,&00
defb &55,&44,&55,&44,&11,&00,&11,&00,&55,&44,&55,&44,&11,&00,&11,&00,&44,&44,&44,&44,&00,&00,&00,&00,&44,&44,&44,&44,&00,&00,&00,&00
defb &33,&22,&11,&00,&33,&22,&11,&00,&33,&22,&11,&00,&33,&22,&11,&00,&22,&22,&00,&00,&22,&22,&00,&00,&22,&22,&00,&00,&22,&22,&00,&00
defb &11,&00,&11,&00,&11,&00,&11,&00,&11,&00,&11,&00,&11,&00,&11,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00,&00