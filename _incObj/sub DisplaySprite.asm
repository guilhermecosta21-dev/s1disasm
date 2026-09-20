; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite:
		lea	(v_spritequeue).w,a1			; load sprite priority layer buffer
		adda.w	obPriority(a0),a1			; get sprite priority
		cmpi.w	#spritelayer_size-2,(a1)		; is this part of the queue full?
		bcc.s   .DSpr_Full                              ; if yes, branch
		addq.w	#2,(a1)					; increment sprite counter
		adda.w	(a1),a1					; jump to empty position
		move.w	a0,(a1)					; insert RAM address for object

	.DSpr_Full:
		rts						; return
; End of function DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a 2nd sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite1:
		lea	(v_spritequeue).w,a2			; load sprite priority layer buffer
		adda.w	obPriority(a1),a2
		cmpi.w	#spritelayer_size-2,(a2)
		bcc.s	.DSpr1_Full
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

	.DSpr1_Full:
		rts						; return
; End of function DisplaySprite1

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already (priority/2)&$380
; ---------------------------------------------------------------------------

; loc_16530:
DisplaySprite2:
		lea	(v_spritequeue).w,a1
		adda.w  d0,a1
		cmpi.w	#spritelayer_size-2,(a1)
		bhs.s   .return_16542
		addq.w  #2,(a1)
        adda.w  (a1),a1
        move.w  a0,(a1)

	.return_16542:
                rts				         ; return
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; and d0 is already priority*$80
; ---------------------------------------------------------------------------

DisplaySprite3:
		lea	(v_spritequeue).w,a1			; load base sprite queue address
		adda.w	d0,a1					; add precalculated queue offset from d0
		move.w	(a1),d0					; get sprite queue's entry count
		addq.b	#2,d0					; increase count by another entry (word)
		bmi.s	DSpr3_Full				; if byte value went to $80, queue is full
		move.w	d0,(a1)					; set new sprite queue's entry count
		move.w	a0,(a1,d0.w)				; insert RAM address for object to queue

DSpr3_Full:
		rts
; End of function DisplaySprite3