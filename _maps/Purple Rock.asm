; ---------------------------------------------------------------------------
; Sprite mappings - purple rock (GHZ)
; ---------------------------------------------------------------------------
Map_PRock_internal:	mappingsTable
	mappingsTableEntry.w	.solid
	mappingsTableEntry.w	.fragmented

.solid:	spriteHeader
	spritePiece -24, -16, 3, 4, 0, 0, 0, 0, 0
	spritePiece 0, -16, 3, 4, 12, 0, 0, 0, 0
.solid_End

.fragmented:	spriteHeader	; same as ".solid" but with more pieces
	spritePiece -24, -16, 2, 4, 0, 0, 0, 0, 0
	spritePiece -8, -16, 1, 4, 8, 0, 0, 0, 0
	spritePiece 0, -16, 1, 4, 12, 0, 0, 0, 0
	spritePiece 8, -16, 2, 4, 16, 0, 0, 0, 0
.fragmented_End

	even