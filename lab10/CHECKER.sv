//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

logic [2:0] r0;
logic [2:0] r1;
logic ract;
logic rchk;
logic [2:0] r2;

//covergroup Spec1 @();
//	
//       finish your covergroup here
//	
//	
//endgroup

//declare other cover group

//declare the cover group 
//Spec1 cov_inst_1 = new();

covergroup cg1 @(posedge clk iff(inf.amnt_valid));
    cp1: coverpoint inf.D.d_money
    {
        bins b0 = {[16'd0:16'd12000]};
        bins b1 = {[16'd12001:16'd24000]};
        bins b2 = {[16'd24001:16'd36000]};
        bins b3 = {[16'd36001:16'd48000]};
        bins b4 = {[16'd48001:16'd60000]};
        option.at_least = 'd10;
    }
endgroup

covergroup cg2 @(posedge clk iff(inf.id_valid));
    cp2: coverpoint inf.D.d_id[0]
    {
        bins b0 [] = {[8'd0:8'd255]};
        option.auto_bin_max = 'd256;
        option.at_least = 'd2;
    }
endgroup

covergroup cg3 @(posedge clk iff(inf.act_valid));
    cp3: coverpoint inf.D.d_act[0]
    {
        bins b0  = (Buy => Buy);
        bins b1  = (Buy => Check);
        bins b2  = (Buy => Deposit);
        bins b3  = (Buy => Return);
        bins b4  = (Check => Buy);
        bins b5  = (Check => Check);
        bins b6  = (Check => Deposit);
        bins b7  = (Check => Return);
        bins b8  = (Deposit => Buy);
        bins b9  = (Deposit => Check);
        bins b10 = (Deposit => Deposit);
        bins b11 = (Deposit => Return);
        bins b12 = (Return => Buy);
        bins b13 = (Return => Check);
        bins b14 = (Return => Deposit);
        bins b15 = (Return => Return);
        option.at_least = 'd10;
    }
endgroup

covergroup cg4 @(posedge clk iff(inf.item_valid));
    cp4: coverpoint inf.D.d_item[0]
    {
        bins b1 = {Large};
        bins b2 = {Medium};
        bins b3 = {Small};
        option.at_least = 'd20;
    }
endgroup

covergroup cg5 @(posedge clk iff(inf.out_valid));
    cp5: coverpoint inf.err_msg
    {
        bins b0 = {INV_Not_Enough};
        bins b1 = {Out_of_money};
        bins b2 = {INV_Full};
        bins b3 = {Wallet_is_Full};
        bins b4 = {Wrong_ID};
        bins b5 = {Wrong_Num};
        bins b6 = {Wrong_Item};
        bins b7 = {Wrong_act};
        option.at_least = 'd20;
    }
endgroup

covergroup cg6 @(posedge clk iff(inf.out_valid));
    cp6: coverpoint inf.complete
    {
        bins b0 = {1'b0};
        bins b1 = {1'b1};
        option.at_least = 'd200;
    }
endgroup

cg1 cgmny = new();
cg2 cguid = new();
cg3 cgact = new();
cg4 cgitm = new();
cg5 cgerm = new();
cg6 cgcmp = new();

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write other assertions at the below
// assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0)
// else
// begin
// 	$display("Assertion X is violated");
// 	$fatal; 
// end

//write other assertions
wire #(0.5) rst0 = inf.rst_n;
ast1_1 : assert property ( @(negedge rst0) (!inf.out_valid && !inf.err_msg && !inf.complete && !inf.out_info))
else begin
	$display("Assertion 1 is violated");
	$fatal;
end

ast1_2 : assert property ( @(negedge rst0) (!inf.C_addr && !inf.C_data_w && !inf.C_in_valid && !inf.C_r_wb))
else begin
	$display("Assertion 1 is violated");
	$fatal;
end

ast1_3 : assert property ( @(negedge rst0) (!inf.C_out_valid && !inf.C_data_r && !inf.AR_VALID && !inf.AR_ADDR))
else begin
	$display("Assertion 1 is violated");
	$fatal;
end

ast1_4 : assert property ( @(negedge rst0) (!inf.R_READY && !inf.AW_VALID && !inf.AW_ADDR && !inf.W_VALID && !inf.W_DATA && !inf.B_READY))
else begin
	$display("Assertion 1 is violated");
	$fatal;
end

ast2 : assert property ( @(posedge clk)  inf.complete |-> inf.err_msg == 4'b0)
else begin
	$display("Assertion 2 is violated");
	$fatal; 
end

ast3 : assert property ( @(posedge clk)  !inf.complete |-> inf.out_info == 32'b0)
else begin
	$display("Assertion 3 is violated");
	$fatal; 
end

ast4_1 : assert property ( @(posedge clk)  inf.id_valid |=> inf.id_valid == 1'b0)
else begin
	$display("Assertion 4 is violated");
	$fatal; 
end

ast4_2 : assert property ( @(posedge clk)  inf.act_valid |=> inf.act_valid == 1'b0)
else begin
	$display("Assertion 4 is violated");
	$fatal; 
end

ast4_3 : assert property ( @(posedge clk)  inf.item_valid |=> inf.item_valid == 1'b0)
else begin
	$display("Assertion 4 is violated");
	$fatal; 
end

ast4_4 : assert property ( @(posedge clk)  inf.amnt_valid |=> inf.amnt_valid == 1'b0)
else begin
	$display("Assertion 4 is violated");
	$fatal; 
end

ast4_5 : assert property ( @(posedge clk)  inf.num_valid |=> inf.num_valid == 1'b0)
else begin
	$display("Assertion 4 is violated");
	$fatal; 
end

ast5_1 : assert property ( @(posedge clk)  inf.id_valid |-> (!inf.act_valid && !inf.item_valid && !inf.amnt_valid && !inf.num_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal; 
end

ast5_2 : assert property ( @(posedge clk)  inf.act_valid |-> (!inf.id_valid && !inf.item_valid && !inf.amnt_valid && !inf.num_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal; 
end

ast5_3 : assert property ( @(posedge clk)  inf.item_valid |-> (!inf.id_valid && !inf.act_valid && !inf.amnt_valid && !inf.num_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal; 
end

ast5_4 : assert property ( @(posedge clk)  inf.amnt_valid |-> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.num_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal; 
end

ast5_5 : assert property ( @(posedge clk)  inf.num_valid |-> (!inf.id_valid && !inf.act_valid && !inf.item_valid && !inf.amnt_valid))
else begin
	$display("Assertion 5 is violated");
	$fatal; 
end

ast6_1 : assert property ( @(posedge clk) (inf.id_valid && !ract) |-> ##[2:6] inf.act_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_1_1 : assert property ( @(posedge clk) (inf.id_valid && !ract) |=> !inf.act_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_2 : assert property ( @(posedge clk) (inf.act_valid && (inf.D.d_act[0] == Buy || inf.D.d_act[0] == Return)) |-> ##[2:6] inf.item_valid ##[2:6] inf.num_valid ##[2:6] inf.id_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_2_1 : assert property ( @(posedge clk) (inf.act_valid && (inf.D.d_act[0] == Buy || inf.D.d_act[0] == Return)) |=> !inf.item_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_2_2 : assert property ( @(posedge clk) inf.item_valid |=> !inf.num_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_2_3 : assert property ( @(posedge clk) inf.num_valid |=> !inf.id_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_3 : assert property ( @(posedge clk) (inf.id_valid && rchk) |-> ($past(inf.act_valid, 2) == 1'b1 || $past(inf.act_valid, 3) == 1'b1 || $past(inf.act_valid, 4) == 1'b1 || $past(inf.act_valid, 5) == 1'b1 || $past(inf.act_valid, 6) == 1'b1))
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_3_1 : assert property ( @(posedge clk) (inf.id_valid && rchk) |-> ($past(inf.act_valid, 1) == 1'b0))
else begin
	$display("Assertion 6 is violated");
	$fatal;
end

ast6_4 : assert property ( @(posedge clk) (inf.act_valid && inf.D.d_act[0] == Deposit) |-> ##[2:6] inf.amnt_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal; 
end

ast6_4_1 : assert property ( @(posedge clk) (inf.act_valid && inf.D.d_act[0] == Deposit) |=> !inf.amnt_valid)
else begin
	$display("Assertion 6 is violated");
	$fatal; 
end

always_ff @(posedge clk, negedge inf.rst_n) begin : blockname
    if(!inf.rst_n) rchk <= 1'b0;
    else if(inf.act_valid && inf.D.d_act[0] == Check) rchk <= 1'b1;
    else if(inf.id_valid || r0 == 5) rchk <= 1'b0;

    if(!inf.rst_n) r0 <= 0;
    else if(!rchk || (rchk && inf.id_valid) || r0 == 5) r0 <= 0;
    else if(r0 < 5) r0 <= r0 + 1;

    if(!inf.rst_n) ract <= 1'b0;
    else if(inf.act_valid) ract <= 1'b1;
    else if(inf.out_valid) ract <= 1'b0;

    // if(rchk  && inf.id_valid) begin
    //     $display("check: %d", $past(inf.act_valid, 2));
    //     $display("check: %d", $past(inf.act_valid, 3));
    //     $display("check: %d", $past(inf.act_valid, 4));
    //     $display("check: %d", $past(inf.act_valid, 5));
    //     $display("check: %d", $past(inf.act_valid, 6));
    //     $display("check: %b", $past(inf.act_valid, 2) == 1'b1);
    //     $display("check: %b", $past(inf.act_valid, 3) == 1'b1);
    //     $display("check: %b", $past(inf.act_valid, 4) == 1'b1);
    //     $display("check: %b", $past(inf.act_valid, 5) == 1'b1);
    //     $display("check: %b", $past(inf.act_valid, 6) == 1'b1);
    //     $display("check: %b", $past(inf.act_valid, 2) == 1);
    //     $display("check: %b", $past(inf.act_valid, 3) == 1);
    //     $display("check: %b", $past(inf.act_valid, 4) == 1);
    //     $display("check: %b", $past(inf.act_valid, 5) == 1);
    //     $display("check: %b", $past(inf.act_valid, 6) == 1);
    // end
end

ast7 : assert property ( @(posedge clk) inf.out_valid |=> inf.out_valid == 1'b0)
else begin
	$display("Assertion 7 is violated");
	$fatal; 
end

ast8 : assert property ( @(posedge clk) inf.out_valid |-> ##[2:10] (inf.id_valid || inf.act_valid))
else begin
	$display("Assertion 8 is violated");
	$fatal; 
end

ast9 : assert property ( @(posedge clk) ((inf.id_valid && ract) || (r0 == 5) || inf.amnt_valid) |-> ##[1:10000] (inf.out_valid))
else begin
    $display("Assertion 9 is violated");
    $fatal;
end

endmodule