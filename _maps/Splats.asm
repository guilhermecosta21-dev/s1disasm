; --------------------------------------------------------------------------------
; Sprite mappings - Splats
; --------------------------------------------------------------------------------

Map_Splats_internal:	mappingsTable
	mappingsTableEntry.w	.bounce0
	mappingsTableEntry.w	.bounce1

.bounce0:	spriteHeader
	spritePiece -12, -20, 3, 4, 0, 0, 0, 0, 0
	spritePiece -12, 12, 3, 1, 12, 0, 0, 0, 0
.bounce0_End

.bounce1:	spriteHeader
	spritePiece -12, -20, 3, 4, 15, 0, 0, 0, 0
	spritePiece -5, 12, 2, 1, 27, 0, 0, 0, 0
.bounce1_End