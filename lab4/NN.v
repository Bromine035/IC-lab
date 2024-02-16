//synopsys translate_off
`include "/RAID2/cad/synopsys/synthesis/2022.03/dw/sim_ver/DW_fp_add.v"
`include "/RAID2/cad/synopsys/synthesis/2022.03/dw/sim_ver/DW_fp_exp.v"
`include "/RAID2/cad/synopsys/synthesis/2022.03/dw/sim_ver/DW_fp_mult.v"
`include "/RAID2/cad/synopsys/synthesis/2022.03/dw/sim_ver/DW_fp_recip.v"
`include "/RAID2/cad/synopsys/synthesis/2022.03/dw/sim_ver/DW_fp_dp3.v"
//synopsys translate_on

module NN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	weight_u,
	weight_w,
	weight_v,
	data_x,
	data_h,
	// Output signals
	out_valid,
	out
);

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;

parameter idle = 3'd0;
parameter indt = 3'd1;
parameter rzr0 = 3'd2;
parameter calc = 3'd3;
// parameter acti = 3'd4;
parameter rzr1 = 3'd5;
parameter over = 3'd6;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid;
input [inst_sig_width+inst_exp_width:0] weight_u, weight_w, weight_v;
input [inst_sig_width+inst_exp_width:0] data_x,data_h;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

reg [2:0] cst, nst;
reg [1:0] r0, r1, r2, rr0, rr1, rr2;
reg [31:0] rru, rrw, rrv, rrh, rrx, rro, roval;
reg [31:0] ru [2:0][2:0];
reg [31:0] rw [2:0][2:0];
reg [31:0] rv [2:0][2:0];
reg [31:0] rh  [2:0];
reg [31:0] rhh [1:0];
reg [31:0] rx [2:0][2:0];
reg [31:0] ry [2:0][2:0];
reg [31:0] rux [2:0];
reg [31:0] rwh;
reg [31:0] rvh;
reg hsok; // ok signal of one stall cycle for h updating
wire [2:0] wrnd; // rounding
wire [31:0] wzpo; // float 0.1
wire [31:0] wone; // float 1
wire [31:0] wm0a, wm1a, wm2a, wm0b, wm1b, wm2b, wea, waa, wab;
wire [31:0] ma0z, md0z, mm3z, me0z, mr0z;

assign wrnd = 3'b0;
assign wone = 32'b00111111100000000000000000000000;
assign wzpo = 32'b00111101110011001100110011001101;
assign wm0a = (r1 == 2)?(rv[r0][0]):((r1 == 1)?(rw[r0][0]):(ru[r0][0]));
assign wm1a = (r1 == 2)?(rv[r0][1]):((r1 == 1)?(rw[r0][1]):(ru[r0][1]));
assign wm2a = (r1 == 2)?(rv[r0][2]):((r1 == 1)?(rw[r0][2]):(ru[r0][2]));
assign wm0b = (r1 == 0)?(rx[r2][0]):(rh[0]);
assign wm1b = (r1 == 0)?(rx[r2][1]):(rh[1]);
assign wm2b = (r1 == 0)?(rx[r2][2]):(rh[2]);
assign wea[30:0] = rvh[30:0];
assign wea[31] = ~(rvh[31]);
assign waa = (rr1 == 2)?(wone):(rux[rr0]);
assign wab = (rr1 == 2)?(me0z):(rwh);

DW_fp_dp3   #(.sig_width(inst_sig_width), .exp_width(inst_exp_width), .ieee_compliance(inst_ieee_compliance))
md0(.a(wm0a), .b(wm0b), .c(wm1a), .d(wm1b), .e(wm2a), .f(wm2b), .rnd(wrnd), .z(md0z), .status());
DW_fp_add   #(.sig_width(inst_sig_width), .exp_width(inst_exp_width), .ieee_compliance(inst_ieee_compliance))
ma0(.a(waa), .b(wab), .rnd(wrnd), .z(ma0z), .status());
DW_fp_mult  #(.sig_width(inst_sig_width), .exp_width(inst_exp_width), .ieee_compliance(inst_ieee_compliance))
mm3(.a(ma0z), .b(wzpo), .rnd(wrnd), .z(mm3z), .status());
DW_fp_exp   #(.sig_width(inst_sig_width), .exp_width(inst_exp_width), .ieee_compliance(inst_ieee_compliance), .arch(inst_arch))
me0(.a(wea), .z(me0z), .status());
DW_fp_recip #(.sig_width(inst_sig_width), .exp_width(inst_exp_width), .ieee_compliance(inst_ieee_compliance))
mr0(.a(ma0z), .rnd(wrnd), .z(mr0z), .status());

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cst <= idle;
		out_valid <= 1'b0;
		out <= 32'b0;
		rru <= 32'b0;
		rrw <= 32'b0;
		rrv <= 32'b0;
		rrh <= 32'b0;
		rrx <= 32'b0;
	end
	else begin
		cst <= nst;
		out_valid <= roval;
		out <= rro;
		rru <= weight_u;
		rrw <= weight_w;
		rrv <= weight_v;
		rrh <= data_h;
		rrx <= data_x;
	end
end

always @(*) begin
	case(cst)
	idle:
	if(!rst_n) begin
		nst <= idle;
	end
	else if(in_valid) begin
		nst <= indt;
	end
	else begin
		nst <= idle;
	end

	indt:
	if(!rst_n) begin
		nst <= idle;
	end
	else if(in_valid) begin
		nst <= indt;
	end
	else begin
		nst <= rzr0;
	end

	rzr0:
	if(!rst_n) begin
		nst <= idle;
	end
	else begin
		nst <= calc;
	end

	calc:
	if(!rst_n) begin
		nst <= idle;
	end
	else if(rr2 == 3) begin
		nst <= rzr1;
	end
	else begin
		nst <= calc;
	end

	rzr1:
	if(!rst_n) begin
		nst <= idle;
	end
	else begin
		nst <= over;
	end

	over:
	if(!rst_n) begin
		nst <= idle;
	end
	else if(r0 == 2 && r1 == 2) begin
		nst <= idle;
	end
	else begin
		nst <= over;
	end

	default:
	nst <= idle;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		r0 <= 2'b0; // 00 01 02 -> 10 11 12 -> 20 21 22
		r1 <= 2'b0; // ux -> wh -> vh
		r2 <= 2'b0; // x1 y1 -> x2 y2 -> x3 y3
		rr0 <= 2'b0;
		rr1 <= 2'b0;
		rr2 <= 2'b0;
		rro <= 32'b0;
		roval <= 1'b0;
		hsok <= 1'b0;
		ry[0][0] <= 32'b0;
		ry[0][1] <= 32'b0;
		ry[0][2] <= 32'b0;
		ry[1][0] <= 32'b0;
		ry[1][1] <= 32'b0;
		ry[1][2] <= 32'b0;
		ry[2][0] <= 32'b0;
		ry[2][1] <= 32'b0;
		ry[2][2] <= 32'b0;
	end
	else if(cst == indt) begin
		r0 <= (r0 == 32'd2)?32'b0:(r0 + 1);
		r1 <= (r0 == 32'd2)?(r1+1):r1;
		ru[r1][r0] <= rru;
		rw[r1][r0] <= rrw;
		rv[r1][r0] <= rrv;
		rx[r1][r0] <= rrx;
		rh[r0] <= (r1 == 32'b0)?rrh:rh[r0];
	end
	else if(cst == rzr0) begin
		r0 <= 2'b0;
		r1 <= 2'b0;
		r2 <= 2'b0;
		rr0 <= 2'b0;
		rr1 <= 2'b0;
		rr2 <= 2'b0;
	end
	else if(cst == calc) begin
		if(r1 == 1 && r0 == 2 && !hsok) begin
			hsok <= 1'b1;
		end
		else begin
			r0 <= (r0 == 2'd2)?2'b0:(r0 + 1);
			r1 <= (r1 == 2'd2 && r0 == 2'd2)?2'b0:((r0 == 2'd2)?(r1+1):r1);
			r2 <= (r1 == 2'd2 && r0 == 2'd2)?(r2+1):r2;
			hsok <= 1'b0;
		end
		rr0 <= r0;
		rr1 <= r1;
		rr2 <= r2;

		if(r1 == 0) begin
			rux[r0] <= md0z;
		end
		else if(r1 == 1) begin
			rwh <= md0z;
		end
		else if(r1 == 2) begin
			rvh <= md0z;
		end
		else ;

		if(rr1 == 1) begin
			if(rr0 == 2) begin
				rh[0] <= rhh[0];
				rh[1] <= rhh[1];
				rh[2] <= (ma0z[31])?(mm3z):(ma0z);
			end
			else begin
				rhh[rr0] <= (ma0z[31])?(mm3z):(ma0z);
			end
		end
		else if(rr1 == 2) begin
			ry[rr2][rr0] <= mr0z;
		end
		else ;
	end
	else if(cst == rzr1) begin
		r0 <= 2'b0;
		r1 <= 2'b0;
		r2 <= 2'b0;
		rr0 <= 2'b0;
		rr1 <= 2'b0;
		rr2 <= 2'b0;
	end
	else if(cst == over) begin
		r0 <= (r0 == 2'd2)?2'b0:(r0 + 1);
		r1 <= (r0 == 2'd2)?(r1+1):r1;
		roval <= 1'b1;
		rro <= ry[r1][r0];
	end
	else begin
		r0 <= 2'b0;
		r1 <= 2'b0;
		r2 <= 2'b0;
		rr0 <= 2'b0;
		rr1 <= 2'b0;
		rr2 <= 2'b0;
		rro <= 32'b0;
		roval <= 1'b0;
		hsok <= 1'b0;
		ry[0][0] <= 32'b0;
		ry[0][1] <= 32'b0;
		ry[0][2] <= 32'b0;
		ry[1][0] <= 32'b0;
		ry[1][1] <= 32'b0;
		ry[1][2] <= 32'b0;
		ry[2][0] <= 32'b0;
		ry[2][1] <= 32'b0;
		ry[2][2] <= 32'b0;
	end
end

//synopsys dc_script_begin
//set_implementation rtl md0
//set_implementation rtl ma0
//set_implementation rtl mm3
//set_implementation rtl me0
//set_implementation rtl mr0
//synopsys dc_script_end
endmodule

/*
module Br35_recip(ni, wrnd, no);
input wire [31:0] ni;
input wire [31:0] wrnd;
output wire [31:0] no;

wire [7:0] w0;
wire [7:0] w1;
wire [7:0] w2;
assign w0 = ni[30:23];
assign w1 = mr0.z[30:23] - 8'd127;
assign w2 = w0 + w1;
DW_fp_recip mr0(.a({ni[31], 8'd127, ni[22:0]}), .rnd(wrnd), .z(), .status());
assign no = {mr0.z[31], w2, mr0.z[22:0]};
endmodule
*/

