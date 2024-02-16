/**************************************************************************/
// Copyright (c) 2023, OASIS Lab
// FILE NAME: readme.txt
// VERSRION: 1.0
// DATE: March 13, 2023
// AUTHOR: Kuan-Wei Chen, NYCU IEE
// DESCRIPTION: 2023 Spring IC Lab / Lab03_demo(student) / readme.txt
// MODIFICATION HISTORY:
// Date                 Description
// 
/**************************************************************************/

/00. pattern
	Total: 2 files
	PATTERN_TA.vp
		- random pattern
		- pattern number: 100,000

	PATTERN_TA_corner.vp
		- corner case pattern
		- pattern number: 5


/01. wrong_design
	Total: 22 files
	
(1) single spec violation case:

	SUBWAY_3_1.vp
		- spec 3 failed design

	SUBWAY_3_2.vp
		- spec 3 failed design

	SUBWAY_4.vp
		- spec 4 failed design

	SUBWAY_5.vp
		- spec 5 failed design

	SUBWAY_6.vp
		- spec 6 failed design

	SUBWAY_7.vp
		- spec 7 failed design

	SUBWAY_8_1.vp
		- spec 8-1 failed design

	SUBWAY_8_2.vp
		- spec 8-2 failed design

	SUBWAY_8_3.vp
		- spec 8-3 failed design

	SUBWAY_8_4.vp
		- spec 8-4 failed design

	SUBWAY_8_5.vp
		- spec 8-5 failed design


(2) multiple spec violation case:

	SUBWAY_prior_4_5.vp
		- spec 4 failed design (SPEC 4 > SPEC 5)

	SUBWAY_prior_4_6.vp
		- spec 4 failed design (SPEC 4 > SPEC 6)

	SUBWAY_prior_4_7.vp
		- spec 4 failed design (SPEC 4 > SPEC 7)

	SUBWAY_prior_4_8_1.vp
		- spec 4 failed design (SPEC 4 > SPEC 8-1)

	SUBWAY_prior_4_8_2.vp
		- spec 4 failed design (SPEC 4 > SPEC 8-2)

	SUBWAY_prior_4_8_3.vp
		- spec 4 failed design (SPEC 4 > SPEC 8-3)

	SUBWAY_prior_4_8_4.vp
		- spec 4 failed design (SPEC 4 > SPEC 8-4)

	SUBWAY_prior_4_8_5.vp
		- spec 4 failed design (SPEC 4 > SPEC 8-5)

	SUBWAY_prior_5_6.vp
		- spec 5 failed design (SPEC 5 > SPEC 6)

	SUBWAY_prior_5_7.vp
		- spec 5 failed design (SPEC 5 > SPEC 7)

	SUBWAY_prior_6_7.vp
		- spec 6 failed design (SPEC 6 > SPEC 7)

	