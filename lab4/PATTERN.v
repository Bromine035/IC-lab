`ifdef RTL
	`include "NN.v"  
	`define CYCLE_TIME 50.0
`endif
`ifdef GATE
	`include "NN_SYN.v"
	`define CYCLE_TIME 50.0
`endif

module PATTERN(
	// Output signals
	clk,
	rst_n,
	in_valid,
	data_x,
	data_h,
	weight_u,
	weight_w,
	weight_v,
	// Input signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
	parameter inst_sig_width = 23;
	parameter inst_exp_width = 8;
	parameter inst_ieee_compliance = 0;

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
	output reg clk,rst_n,in_valid;
	output reg [inst_sig_width + inst_exp_width: 0] weight_u,weight_w,weight_v,data_x,data_h;
	input	out_valid;
	input	[inst_sig_width + inst_exp_width: 0] out;
	
//================================================================
// parameters & integer
//================================================================


//================================================================
// PATTERN
//================================================================

endmodule