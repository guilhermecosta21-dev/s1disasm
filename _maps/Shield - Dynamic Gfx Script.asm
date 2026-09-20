; --------------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3

.frame0:	dplcHeader
.frame0_End

.frame1:	dplcHeader
	dplcEntry	16, 0
	dplcEntry	2, 16
.frame1_End

.frame2:	dplcHeader
	dplcEntry	9, 18
.frame2_End

.frame3:	dplcHeader
	dplcEntry	16, 0
	dplcEntry	2, 16
.frame3_End

	even
