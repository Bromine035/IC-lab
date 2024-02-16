module CC(
  in_s0,
  in_s1,
  in_s2,
  in_s3,
  in_s4,
  in_s5,
  in_s6,
  opt,
  a,
  b,
  s_id0,
  s_id1,
  s_id2,
  s_id3,
  s_id4,
  s_id5,
  s_id6,
  out

);
input [3:0]in_s0;
input [3:0]in_s1;
input [3:0]in_s2;
input [3:0]in_s3;
input [3:0]in_s4;
input [3:0]in_s5;
input [3:0]in_s6;
input [2:0]opt;
input [1:0]a;
input [2:0]b;
output [2:0] s_id0;
output [2:0] s_id1;
output [2:0] s_id2;
output [2:0] s_id3;
output [2:0] s_id4;
output [2:0] s_id5;
output [2:0] s_id6;
output [2:0] out; 
//==================================================================
// reg & wire
//==================================================================
wire [3:0]in_s0, in_s1, in_s2, in_s3, in_s4, in_s5, in_s6;
wire [2:0]opt;
wire [1:0]a;
wire [2:0]b;
wire [2:0] s_id0, s_id1, s_id2, s_id3, s_id4, s_id5, s_id6;
wire [2:0] out; 
wire [7:0] w1;
wire [7:0] w2;
wire [6:0] w3;
wire [7:0] ps;
wire [7:0] w4;
wire [2:0] w5;
//==================================================================
// design
//==================================================================
cga ca0_0(.i0({3'd0, in_s0}), .i1({3'd1, in_s1}), .sb(opt[0]), .o0(), .o1());
cga ca0_1(.i0(ca0_0.o1),      .i1({3'd2, in_s2}), .sb(opt[0]), .o0(), .o1());
cga ca0_2(.i0(ca0_1.o1),      .i1({3'd3, in_s3}), .sb(opt[0]), .o0(), .o1());
cga ca0_3(.i0(ca0_2.o1),      .i1({3'd4, in_s4}), .sb(opt[0]), .o0(), .o1());
cga ca0_4(.i0(ca0_3.o1),      .i1({3'd5, in_s5}), .sb(opt[0]), .o0(), .o1());
cga ca0(  .i0(ca0_4.o1),      .i1({3'd6, in_s6}), .sb(opt[0]), .o0(), .o1());
cga ca1_0(.i0(ca0_0.o0),      .i1(ca0_1.o0),      .sb(opt[0]), .o0(), .o1());
cga ca1_1(.i0(ca1_0.o1),      .i1(ca0_2.o0),      .sb(opt[0]), .o0(), .o1());
cga ca1_2(.i0(ca1_1.o1),      .i1(ca0_3.o0),      .sb(opt[0]), .o0(), .o1());
cga ca1_3(.i0(ca1_2.o1),      .i1(ca0_4.o0),      .sb(opt[0]), .o0(), .o1());
cga ca1(  .i0(ca1_3.o1),      .i1(ca0.o0  ),      .sb(opt[0]), .o0(), .o1());
cga ca2_0(.i0(ca1_0.o0),      .i1(ca1_1.o0),      .sb(opt[0]), .o0(), .o1());
cga ca2_1(.i0(ca2_0.o1),      .i1(ca1_2.o0),      .sb(opt[0]), .o0(), .o1());
cga ca2_2(.i0(ca2_1.o1),      .i1(ca1_3.o0),      .sb(opt[0]), .o0(), .o1());
cga ca2(  .i0(ca2_2.o1),      .i1(ca1.o0  ),      .sb(opt[0]), .o0(), .o1());
cga ca3_0(.i0(ca2_0.o0),      .i1(ca2_1.o0),      .sb(opt[0]), .o0(), .o1());
cga ca3_1(.i0(ca3_0.o1),      .i1(ca2_2.o0),      .sb(opt[0]), .o0(), .o1());
cga ca3(  .i0(ca3_1.o1),      .i1(ca2.o0  ),      .sb(opt[0]), .o0(), .o1());
cga ca4_0(.i0(ca3_0.o0),      .i1(ca3_1.o0),      .sb(opt[0]), .o0(), .o1());
cga ca4(  .i0(ca4_0.o1),      .i1(ca3.o0  ),      .sb(opt[0]), .o0(), .o1());
cga ca5(  .i0(ca4_0.o0),      .i1(ca4.o0  ),      .sb(opt[0]), .o0(), .o1());
cgd cd0_0(.i0({3'd0, in_s0}), .i1({3'd1, in_s1}), .sb(opt[0]), .o0(), .o1());
cgd cd0_1(.i0(cd0_0.o1),      .i1({3'd2, in_s2}), .sb(opt[0]), .o0(), .o1());
cgd cd0_2(.i0(cd0_1.o1),      .i1({3'd3, in_s3}), .sb(opt[0]), .o0(), .o1());
cgd cd0_3(.i0(cd0_2.o1),      .i1({3'd4, in_s4}), .sb(opt[0]), .o0(), .o1());
cgd cd0_4(.i0(cd0_3.o1),      .i1({3'd5, in_s5}), .sb(opt[0]), .o0(), .o1());
cgd cd0(  .i0(cd0_4.o1),      .i1({3'd6, in_s6}), .sb(opt[0]), .o0(), .o1());
cgd cd1_0(.i0(cd0_0.o0),      .i1(cd0_1.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd1_1(.i0(cd1_0.o1),      .i1(cd0_2.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd1_2(.i0(cd1_1.o1),      .i1(cd0_3.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd1_3(.i0(cd1_2.o1),      .i1(cd0_4.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd1(  .i0(cd1_3.o1),      .i1(cd0.o0  ),      .sb(opt[0]), .o0(), .o1());
cgd cd2_0(.i0(cd1_0.o0),      .i1(cd1_1.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd2_1(.i0(cd2_0.o1),      .i1(cd1_2.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd2_2(.i0(cd2_1.o1),      .i1(cd1_3.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd2(  .i0(cd2_2.o1),      .i1(cd1.o0  ),      .sb(opt[0]), .o0(), .o1());
cgd cd3_0(.i0(cd2_0.o0),      .i1(cd2_1.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd3_1(.i0(cd3_0.o1),      .i1(cd2_2.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd3(  .i0(cd3_1.o1),      .i1(cd2.o0  ),      .sb(opt[0]), .o0(), .o1());
cgd cd4_0(.i0(cd3_0.o0),      .i1(cd3_1.o0),      .sb(opt[0]), .o0(), .o1());
cgd cd4(  .i0(cd4_0.o1),      .i1(cd3.o0  ),      .sb(opt[0]), .o0(), .o1());
cgd cd5(  .i0(cd4_0.o0),      .i1(cd4.o0  ),      .sb(opt[0]), .o0(), .o1());
comp4 cp4_0(.ni(in_s0), .no());
comp4 cp4_1(.ni(in_s1), .no());
comp4 cp4_2(.ni(in_s2), .no());
comp4 cp4_3(.ni(in_s3), .no());
comp4 cp4_4(.ni(in_s4), .no());
comp4 cp4_5(.ni(in_s5), .no());
comp4 cp4_6(.ni(in_s6), .no());
comp8 cp8_0(.ni({4'b0, cp4_0.no}/w4), .no());
comp8 cp8_1(.ni({4'b0, cp4_1.no}/w4), .no());
comp8 cp8_2(.ni({4'b0, cp4_2.no}/w4), .no());
comp8 cp8_3(.ni({4'b0, cp4_3.no}/w4), .no());
comp8 cp8_4(.ni({4'b0, cp4_4.no}/w4), .no());
comp8 cp8_5(.ni({4'b0, cp4_5.no}/w4), .no());
comp8 cp8_6(.ni({4'b0, cp4_6.no}/w4), .no());
comp8 cp8_7(.ni(w2), .no());
comp8 cp8_8(.ni(cp8_7.no/8'd7), .no());
assign w1 = a+b;
assign w3 = {in_s6[3], in_s5[3], in_s4[3], in_s3[3], in_s2[3], in_s1[3], in_s0[3]} & {7{opt[0]}};
assign w2 = (
    {{4{w3[0]}}, in_s0} + 
    {{4{w3[1]}}, in_s1} + 
    {{4{w3[2]}}, in_s2} + 
    {{4{w3[3]}}, in_s3} + 
    {{4{w3[4]}}, in_s4} + 
    {{4{w3[5]}}, in_s5} + 
    {{4{w3[6]}}, in_s6});
assign ps = (((opt[0] && w2[7])?cp8_8.no:(w2/8'd7)) - w1);
pas pas0(.si((w3[0])?(cp8_0.no):(in_s0*w4)), .ps(ps), .po());
pas pas1(.si((w3[1])?(cp8_1.no):(in_s1*w4)), .ps(ps), .po());
pas pas2(.si((w3[2])?(cp8_2.no):(in_s2*w4)), .ps(ps), .po());
pas pas3(.si((w3[3])?(cp8_3.no):(in_s3*w4)), .ps(ps), .po());
pas pas4(.si((w3[4])?(cp8_4.no):(in_s4*w4)), .ps(ps), .po());
pas pas5(.si((w3[5])?(cp8_5.no):(in_s5*w4)), .ps(ps), .po());
pas pas6(.si((w3[6])?(cp8_6.no):(in_s6*w4)), .ps(ps), .po());
assign w4 = a + 4'd1;
assign w5 = pas0.po + pas1.po + pas2.po + pas3.po + pas4.po + pas5.po + pas6.po;
assign out = (opt[2])?(3'd7 - w5):w5;
assign {s_id0, s_id1, s_id2, s_id3, s_id4, s_id5, s_id6} = (opt[1])?{
  cd5.o0[6:4], cd5.o1[6:4], cd4.o1[6:4], cd3.o1[6:4], cd2.o1[6:4], cd1.o1[6:4], cd0.o1[6:4]}:{
  ca5.o0[6:4], ca5.o1[6:4], ca4.o1[6:4], ca3.o1[6:4], ca2.o1[6:4], ca1.o1[6:4], ca0.o1[6:4]};
endmodule

module cga(i0, i1, o0, o1, sb);
input wire [6:0] i0, i1;
input wire sb;
output wire [6:0] o0, o1;
assign {o0, o1} = ( ((i1[3] && !i0[3] && sb) || (i1[3:0] < i0[3:0])) && (i1[3] || !i0[3] || !sb) )?{i1, i0}:{i0, i1};
endmodule

module cgd(i0, i1, o0, o1, sb);
input wire [6:0] i0, i1;
input wire sb;
output wire [6:0] o0, o1;
assign {o0, o1} = ( ((!i1[3] && i0[3] && sb) || (i1[3:0] > i0[3:0])) && (!i1[3] || i0[3] || !sb) )?{i1, i0}:{i0, i1};
endmodule

module comp4(ni, no);
input wire [3:0] ni;
output wire [3:0] no;
assign no = ~ni + 4'd1;
endmodule

module comp8(ni, no);
input wire [7:0] ni;
output wire [7:0] no;
assign no = ~ni + 8'd1;
endmodule

module pas(si, ps, po);
input wire [7:0] si, ps;
output wire [2:0] po;
assign po = {2'b0, ((!si[7] || ps[7]) && !(si < ps)) || (!si[7] && ps[7])};
endmodule