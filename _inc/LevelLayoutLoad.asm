; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to load basic level data
; ---------------------------------------------------------------------------

LevelDataLoad:
	; --- Load Level Header ---
		moveq	#0,d0					; clear d0
		move.b	(v_zone).w,d0				; get zone ID to load
		lsl.w	#4,d0					; multiply by $10 (size per level header entry)
		lea	(LevelHeaders).l,a2			; load level header data
		lea	(a2,d0.w),a2				; advance to level header for current zone
		move.l	a2,-(sp)				; remember header address for later
		addq.l	#4,a2					; skip 1st PLC and level gfx entry (handled in GM_Level)

	; --- 16x16 Block Mappings ---
		movea.l	(a2)+,a0				; get 16x16 data pointer from level header
		lea	(v_16x16).w,a1				; set target RAM buffer for 16x16 mappings
		move.w	#ArtTile_Level,d0			; set base art tile (0)
		bsr.w	EniDec					; decompress Enigma-compressed block data to buffer

	; --- 128x128 Chunk Mappings ---
		movea.l	(a2)+,a0				; get 128x128 chunk data pointer from level header
		lea	(v_128x128).l,a1			; set target RAM buffer for 128x128 mappings
		bsr.w	KosDec					; decompress Kosinski-compressed chunk data to buffer

	; --- Level Layout (FG/BG) ---
		bsr.w	LevelLayoutLoad				; load FG and BG layout

	; --- Music (unused) ---
		move.w	(a2)+,d0				; load music (unused)

	; --- Palette ---
		move.w	(a2),d0					; load palette ID
		andi.w	#$FF,d0					; only use lower byte (palette ID is duplicated in headers)

		cmpi.w	#id_LZ_act4,(v_zone_act).w		; is level SBZ3 (LZ4)?
		bne.s	.notSBZ3				; if not, branch
		moveq	#palid_SBZ3,d0				; use SB3 palette instead
	.notSBZ3:
		cmpi.w	#id_SBZ_act2,(v_zone_act).w		; is level SBZ2?
		beq.s	.isSBZorFZ				; if yes, branch
		cmpi.w	#id_FZ,(v_zone_act).w			; is level FZ?
		bne.s	.normalpal				; if not, branch
	.isSBZorFZ:
		moveq	#palid_SBZ2,d0				; use SBZ2/FZ palette instead
	.normalpal:
		bsr.w	PalLoad_Fade				; load specified palette into fade-in buffer

	; --- 2nd PLC ---
		movea.l	(sp)+,a2				; restore base level header pointer
		addq.w	#4,a2					; advance to 2nd PLC entry
		moveq	#0,d0
		move.b	(a2),d0					; load 2nd PLC entry from level headers
		beq.s	.skipPLC				; if 2nd PLC is 0 (i.e. the ending sequence), branch
		bsr.w	AddPLC					; load secondary pattern load cues
	.skipPLC:
		rts
; End of function LevelDataLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Level layout loading subroutine
; ---------------------------------------------------------------------------

LevelLayoutLoad:
		move.w	(v_zone_act).w,d0			; get current zone and act
		lsl.b	#6,d0					; shift only act byte
		lsr.w	#5,d0					; d0 = pointer for current level in Level_Index
		lea	(Level_Index).l,a0			; get layout index
		move.w	(a0,d0.w),d0				; advance to desired layout pointer in index
		lea	(a0,d0.w),a0				; load layout pointer from index
		lea	(v_lvllayout).w,a1			; MJ: FG and BG rows are interlaced $80 bytes each
		bra.w	KosDec					; MJ: decompress layout
; End of function LevelLayoutLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Zone tiles loading subroutine
; ---------------------------------------------------------------------------

LoadZoneTiles:
		moveq	#0,d0			; Clear d0
		move.b	(v_zone).w,d0		; Load number of current zone to d0
		lsl.w	#4,d0			; Multiply by $10, converting the zone ID into an offset
		lea	(LevelHeaders).l,a2	; Load LevelHeaders's address into a2
		lea	(a2,d0.w),a2		; Offset LevelHeaders by the zone-offset, and load the resultant address to a2
		move.l	(a2)+,d0		; Move the first longword of data that a2 points to to d0, this contains the zone's first PLC ID and its art's address.
						; The auto increment is pointless as a2 is overwritten later, and nothing reads from a2 before then
		andi.l	#$FFFFFF,d0    		; Filter out the first byte, which contains the first PLC ID, leaving the address of the zone's art in d0
		movea.l	d0,a0			; Load the address of the zone's art into a0 (source)
		lea	(v_ram_start).l,a1	; Load v_ram_start (in this context, an art buffer) into a1 (destination)
		bsr.w   KosDec			; Decompress a0 to a1 (Kosinski compression)

		move.w	a1,d3			; Move a word of a1 to d3, note that a1 doesn't exactly contain the address of v_ram_start anymore, after KosDec, a1 now contains v_ram_start + the size of the file decompressed to it, d3 now contains the length of the file that was decompressed
		move.w	d3,d7			; Move d3 to d7, for use in separate calculations

		andi.w	#$FFF,d3		; Remove the high nibble of the high byte of the length of decompressed file, this nibble is how many $1000 bytes the decompressed art is
		lsr.w	#1,d3			; Half the value of 'length of decompressed file', d3 becomes the 'DMA transfer length'

		rol.w	#4,d7			; Rotate (left) length of decompressed file by one nibble
		andi.w	#$F,d7			; Only keep the low nibble of low byte (the same one filtered out of d3 above), this nibble is how many $1000 bytes the decompressed art is

.loop:		move.w	d7,d2			; Move d7 to d2, note that the ahead dbf removes 1 byte from d7 each time it loops, meaning that the following calculations will have different results each time
		lsl.w	#7,d2			; Shift (left) d2 by $C, making it high nibble of the high byte, d2 is now the size of the decompressed file rounded down to the nearest $1000 bytes, d2 becomes the 'destination address'
		lsl.w	#5,d2			; See above (needs to be two lines, maximum count for a single bit shift instruction is 7)

		move.l	#$FFFFFF,d1		; Fill d1 with $FF
		move.w	d2,d1			; Move d2 to d1, overwriting the last word of $FF's with d2, this turns d1 into 'v_ram_start'+'However many $1000 bytes the decompressed art is', d1 becomes the 'source address'

		jsr	(QueueDMATransfer).l	; Use d1, d2, and d3 to locate the decompressed art and ready for transfer to VRAM
		move.w	d7,-(sp)		; Store d7 in the Stack
		move.b	#id_VBlank_TitleCards,(v_vblank_routine).w ; Set VBlank routine to $C (title cards sequence)
		bsr.w	WaitForVBlank		; Wait for VBlank to run DMA
		bsr.w	RunPLC			; Process any pending PLCs
		move.w	(sp)+,d7		; Restore d7 from the Stack
		move.w	#$1000/2,d3		; Force the DMA transfer length to be $1000/2 (the first cycle is dynamic because the art's DMA'd backwards)
		dbf	d7,.loop		; Loop for each $1000 bytes the decompressed art is

		rts
; End of function LoadZoneTiles