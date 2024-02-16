//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date				: 2023/03
//		Version			: v1.0
//   	File Name   : PATTERN_IP.v
//   	Module Name : PATTERN_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
// ============================================================================
//
//      Lab 6 PATTERN_IP.v
//      Inversion in Prime Field
//      Module name: PATTERN
//
// ----------------------------------------------------------------------------
// DATE       | VERSION | Author    | Description
// -----------+---------+-----------+------------------------------------------
// 02/02/2023 | V0.0    | Z.T.DONG  | Create
// -----------+---------+-----------+------------------------------------------
//            |         |           | 
// -----------+---------+-----------+------------------------------------------
//            |         |           |
// ----------------------------------------------------------------------------
//
// ============================================================================

`ifdef RTL
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE
    `define CYCLE_TIME 60.0
`endif

module PATTERN_IP #(parameter IP_WIDTH = 8) (
    // Output signals
    IN_1, IN_2,
    // Input signals
    OUT_INV
);

//pragma protect begin_protected
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=CDS_KEY
//pragma protect key_method=RC5
//pragma protect key_block
DGRyS+rfGsUkxDjMu6WHsoQd66sK2PetLqR9j0xayaKBdEhLDya3JO+rTyft+Z9S
FfUuLxT/ZOll8fDSHuIw5/fKcFGxhbC8nAScf8//qAWD+XTnMsFeyWAdCqBK/rQT
S50yoqv1JvNbmFNgd3VskG4D6wDUQ8EokI57sYgC4LRlfCi2dNoWpw==
//pragma protect end_key_block
//pragma protect digest_block
R3avop622nWhJgODEocTA6YMEps=
//pragma protect end_digest_block
//pragma protect data_block
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

//pragma protect end_data_block
//pragma protect digest_block
jHAEx7wYF8h/SPC8qYCh+RZIYUY=
//pragma protect end_digest_block
//pragma protect end_protected
