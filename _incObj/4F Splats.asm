; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4F - Splats (scrapped Marble Zone badnik)
; ---------------------------------------------------------------------------

Splats:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Splats_Index(pc,d0.w),d1
		jmp	Splats_Index(pc,d1.w)
; ===========================================================================
Splats_Index:
		dc.w	Splats_Main-Splats_Index		; 0 - object init
		dc.w	Splats_Wait-Splats_Index		; 2 - wait for Sonic to enter a certain trigger zone (bounce in place until then)
		dc.w	Splats_Bounce-Splats_Index		; 4 - trigger zone entered, apply movement and check for floor to bounce
		dc.w	Splats_FallLava-Splats_Index		; 6 - special case after hitting lava: phase through floor and despawn on screen exit
; ===========================================================================

Splats_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; set to Splats_Wait
		move.l	#Map_Splats,obMap(a0)			; set maps
		move.w	#ArtTile_Splats|Tile_Pal2,obGfx(a0)	; set art tile
		move.b	#sprite_cam_field,obRender(a0)		; set render flags
		move.w	#$200,obPriority(a0)			; set sprite priority
		move.b	#24/2,obActWid(a0)			; set width
		move.b	#40/2,obHeight(a0)			; set height
		move.b	#col_24x40|col_badnik,obColType(a0)	; set collision type to badnik

		tst.b	obSubtype(a0)				; is subtype anything but zero?
		beq.s	Splats_Wait				; if not, branch
		move.w	#$300,d2				; set trigger zone to start moving to be significantly larger
		bra.s	Splats_TriggerSet			; skip
; ===========================================================================

Splats_Wait:	; Routine 2
		move.w	#$E0,d2					; set default (small) trigger zone

Splats_TriggerSet:
		move.w	#$100,d1				; prepare X velocity to be $100
		bset	#0,obRender(a0)				; make object face to the right
		move.w	(v_player+obX).w,d0			; get Sonic's X position
		sub.w	obX(a0),d0				; subtract object's X position
		bcc.s	.chkTriggerZoneHit			; if object is to the right of Sonic, branch
		neg.w	d0					; negate distance
		neg.w	d1					; negate prepared X velocity
		bclr	#sprite_xflip_bit,obRender(a0)		; make object face to the left

	.chkTriggerZoneHit:
		cmp.w	d2,d0					; is Sonic within the trigger zone?
		bcc.s	Splats_Bounce				; if not, bounce in place
		move.w	d1,obVelX(a0)				; begin moving horizontally
		addq.b	#2,obRoutine(a0)			; set to Splats_Bounce
; ---------------------------------------------------------------------------

Splats_Bounce:	; Routine 4
		bsr.w	ObjectFall				; apply gravity
		move.b	#1,obFrame(a0)				; set frame to 1 (bouncy, flappy ears)
		tst.w	obVelY(a0)				; is object moving upwards?
		bmi.s	.chkWall				; if yes, branch
		move.b	#0,obFrame(a0)				; set frame to 0 (standard, long ears)

		bsr.w	ObjFloorDist				; get object distance to floor
		tst.w	d1					; is object above floor?
		bpl.s	.chkWall				; if yes, branch
		move.w	(a1),d0					; get floor block object is standing on
		andi.w	#$3FF,d0				; ignore solid/orientation bits (i.e. only look at the actual block ID)
		cmpi.w	#$16A,d0				; is the touched block ID a lava tile? (was $2D2 in the proto, adjusted to $16A for S1 Final)
		blo.s	.bounce					; if not, branch
		addq.b	#2,obRoutine(a0)			; set to Splats_FallLava (makes object fall into lava upon contact)
		bra.s	.chkWall				; skip
; ---------------------------------------------------------------------------

.bounce:
		add.w	d1,obY(a0)				; fix to floor (add floor difference to Y pos)
		move.w	#-$400,obVelY(a0)			; bounce up

.chkWall:
		bsr.w	ChkHitLeftRightWall			; check if object hit a wall to the left or right (this routine is shared with Yadrin)
		beq.s	.display				; if not, branch

		neg.w	obVelX(a0)				; invert X movement direction
		bchg	#sprite_xflip_bit,obRender(a0)		; invert sprite flip (render flags)
		bchg	#sprite_xflip_bit,obStatus(a0)		; invert sprite flip (status flags)

	.display:
		bra.w	RememberState				; display
; ===========================================================================

Splats_FallLava: ; Routine 6 
		bsr.w	ObjectFall				; apply gravity
		tst.b	obRender(a0)				; is object still on screen?
		bpl.w	DeleteObject				; if not, delete
		bra.w	DisplaySprite				; display
; ---------------------------------------------------------------------------