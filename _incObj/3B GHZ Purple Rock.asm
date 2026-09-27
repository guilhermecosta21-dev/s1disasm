; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

PurpleRock:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Rock_Index(pc,d0.w),d1
		jmp	Rock_Index(pc,d1.w)
; ===========================================================================
Rock_Index:	dc.w Rock_Main-Rock_Index	; 0
		dc.w Rock_Solid-Rock_Index	; 2
		dc.w Rock_Fragment-Rock_Index	; 4 <-- gets set from SmashObject
; ===========================================================================

Rock_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_PRock,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Purple_Rock,3,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$13,obActWid(a0)
		move.w	#$200,obPriority(a0)

Rock_Solid:	; Routine 2
		moveq	#$1B,d1			; width
		moveq	#$10,d2			; height
		moveq	#$10,d3			; height
		move.w	obX(a0),d4		; X position	
		bsr.w	SolidObject		; check Sonic's collision with this object
		btst	#3,obStatus(a0)		; has Sonic landed on the rock?
		beq.s	Rock_Display		; if not, branch
		lea	(v_player).w,a1		; load Sonic object to a1
		cmpi.b	#id_Roll,obPrevAni(a1)	; was Sonic in his rolling animation when he landed on the rock?
		bne.s	Rock_Display		; if not, branch. (otherwise, trigger smash now...)

		; set Sonic to rebound from the rock
		bset	#1,obStatus(a1)		; set Sonic airborne
		bset	#2,obStatus(a1)		; set Sonic rolling
		bclr	#3,obStatus(a1)		; clear Sonic's stand-on-object flag
		move.b	#$E,obHeight(a1)	; reset rolling state height
		move.b	#7,obWidth(a1)		; reset rolling state width
		move.b	#id_Roll,obAnim(a1)	; reset rolling  animation
		move.w	#-$300,obVelY(a1)	; rebound Sonic up
		move.b	#2,obRoutine(a1)	; reset Sonic to default routine
		
		; prepare rock for the smashing effect
		clr.b	obSolid(a0)		; clear rock's "Sonic has touched me" flag
		bclr	#3,obStatus(a0)		; clear rock's "Sonic is standing on me" flag
		move.b	#1,obFrame(a0)		; set rock to the frame that has more sprite pieces (looks better)

		; spawn the actual fragments themselves
		lea	Rock_Fragments_Speeds(pc),a4 ; load broken fragment speed data
		moveq	#4-1,d1			; set number of fragments to spawn (minus 1)
		moveq	#$38,d2			; set initial Y-velocity for fragments to $38
		bsr.w	SmashObject		; smash the rock now (this will also set the routine to 4 for all fragments)
		bra.s	Rock_Fragment		; continue to routine 4

Rock_Display:
		out_of_range.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Rock_Fragment:	; Routine 4
		bsr.w	ObjectFall		; continue to apply gravity to fragment and update positions
		tst.b	obRender(a0)		; is fragment still on screen?
		bpl.w	DeleteObject		; if not, delete it
		bra.w	DisplaySprite		; otherwise, continue displaying 
; ===========================================================================

Rock_Fragments_Speeds: ; x-speed, y-speed
		dc.w -$200, -$200 ; fragment 1
		dc.w -$100, -$100 ; fragment 2
		dc.w  $100, -$100 ; fragment 3
		dc.w  $200, -$200 ; fragment 4
		even