`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"
`define CYCLE_TIME 10.0

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter IDNUM   = 256;
parameter simulation_cycle = `CYCLE_TIME;
integer	Pat_num = 50000;
integer n0, f0, i0;

//================================================================
// wire & registers 
//================================================================

Money rmny;
User_id rdid;
Action ract;
Item_id ritm;
Item_num rnum;
logic [3:0] rerm;
logic rcmp;
User_id ruid, rsid;
Item_num wuiv, wsiv;
wire [31:0] wfee, wprc, wexp;
wire wupg; // upgrade
logic [255:0] rbuy;
logic [255:0] rsel; // just be a seller

assign wuiv = (ritm == Large)?(vu[ruid].si.large_num):((ritm == Medium)?(vu[ruid].si.medium_num):(vu[ruid].si.small_num));
assign wsiv = (ritm == Large)?(vu[rsid].si.large_num):((ritm == Medium)?(vu[rsid].si.medium_num):(vu[rsid].si.small_num));
assign wfee = (vu[ruid].si.level[1])?((vu[ruid].si.level[0])?('d70):('d50)):((vu[ruid].si.level[0])?('d30):('d10));
assign rcmp = (rerm == 4'b0000);

class user;
    Shop_Info si;
    User_Info ui;
    function new();
        ;
    endfunction
endclass

user vu [255:0];

covergroup cg1 @(posedge clk or negedge inf.rst_n iff(inf.amnt_valid));
    cp0: coverpoint rmny
    {
        bins b0 = {[16'd0:16'd12000]};
        bins b1 = {[16'd12001:16'd24000]};
        bins b2 = {[16'd24001:16'd36000]};
        bins b3 = {[16'd36001:16'd48000]};
        bins b4 = {[16'd48001:16'd60000]};
        option.at_least = 'd10;
    }
endgroup

covergroup cg2 @(posedge clk or negedge inf.rst_n iff(inf.id_valid));
    cp0: coverpoint rdid
    {
        bins b0 [] = {[8'd0:8'd255]};
        option.auto_bin_max = 'd256;
        option.at_least = 'd2;
    }
endgroup

covergroup cg3 @(posedge clk or negedge inf.rst_n iff(inf.act_valid));
    cp0: coverpoint ract
    {
        bins b0 [] = ({Buy, Check, Deposit, Return} => {Buy, Check, Deposit, Return});
        option.at_least = 'd10;
    }
endgroup

covergroup cg4 @(posedge clk or negedge inf.rst_n iff(inf.item_valid));
    cp0: coverpoint ritm
    {
        bins b1 = Large;
        bins b2 = Medium;
        bins b3 = Small;
        option.at_least = 'd20;
    }
endgroup

covergroup cg5 @(posedge clk or negedge inf.rst_n iff(inf.out_valid));
    cp0: coverpoint rerm
    {
        bins b0 = 4'b0010;
        bins b1 = 4'b0011;
        bins b2 = 4'b0100;
        bins b3 = 4'b1000;
        bins b4 = 4'b1001;
        bins b5 = 4'b1100;
        bins b6 = 4'b1010;
        bins b7 = 4'b1111;
        option.at_least = 'd20;
    }
    cp1: coverpoint rcmp
    {
        bins b0 = 1'b0;
        bins b1 = 1'b1;
        option.at_least = 'd200;
    }
endgroup

cg1 cgmny = new();
cg2 cgdid = new();
cg3 cgact = new();
cg4 cgitm = new();
cg5 cgout = new();

always_comb begin : block_erm
    case(ract)
    4'd1: // Buy
    if(({26'b0, wuiv} + rnum) > 32'd63) begin
        rerm <= 4'b0100; // INV_Full;
    end
    else if(rnum > {10'b0, wsiv}) begin
        rerm <= 4'b0010; // INV_Not_Enough;
    end
    else if((wfee + wprc*rnum) > vu[ruid].ui.money) begin
        rerm <= 4'b0011; // Out_of_money;
    end
    else begin
        rerm <= 4'b0000; // No_Err;
    end
    4'd2: // Check
    rerm <= 4'b0000;

    4'd4: // Deposit
    if(({16'b0, vu[ruid].ui.money} + rmny) > 16'hffff) begin
        rerm <= 4'b1000; // Wallet_is_Full;
    end
    else begin
        rerm <= 4'b0000;
    end
    4'd8: // Return
    if(!rbuy[ruid] || !rsel[vu[ruid].ui.shop_history.seller_ID] || vu[rsid].ui.shop_history.seller_ID != ruid) begin
        rerm <= 4'b1111; // Wrong_act;
    end
    else if(ruui.shop_history.seller_ID != rser) begin
        rerm <= 4'b1001; // Wrong_ID;
    end
    else if(ruui.shop_history.item_num != rnum) begin
        rerm <= 4'b1100; // Wrong_Num;
    end
    else if(ruui.shop_history.item_ID != ritm) begin
        rerm <= 4'b1010; // Wrong_Item;
    end
    else begin
        rerm <= 4'b0000;
    end
    default:
    rerm <= 4'b0000;
    endcase
end

//================================================================
// initial
//================================================================
// initial $readmemh(DRAM_p_r, golden_DRAM);

initial begin
    n0 = $urandom('d315);
    init_dram;
    inf.D = 'bx;
    inf.id_valid = 1'b0;
    inf.act_valid = 1'b0;
    inf.item_valid = 1'b0;
    inf.num_valid = 1'b0;
    inf.amnt_valid = 1'b0;
    inf.rst_n = 1'b1;
    #10
    inf.rst_n = 1'b0;
    #10
    inf.rst_n = 1'b1;
    #10
    #simulation_cycle;
    $finish;
end

task init_dram; begin
    f0 = $fopen(DRAM_p_r, "w");
    for(i0 = 0; i0 < 256; i0 = i0+1) begin
        vu[i0] = new();
        vu[i0].si = $random();
        vu[i0].ui = $random();
        if(vu[i0].si.level == 2'b11) begin // copper
            vu[i0].si.exp = $random%'d999;
        end
        else if(vu[i0].si.level == 2'b10) begin // silver
            vu[i0].si.exp = $random%'d2499;
        end
        else if(vu[i0].si.level == 2'b10) begin // gold
            vu[i0].si.exp = $random%'d3999;
        end
        else begin // purachina
            vu[i0].si.exp = 12'b0;
        end
        vu[i0].ui.shop_history = 16'b0;
        $fwrite(f0, "@%5h\n", 'h10000 + i0*'h8);
        $fwrite(f0, "%2h %2h %2h %2h\n", vu[i0].si[31:24], vu[i0].si[23:16], vu[i0].si[15:8], vu[i0].si[7:0]);
        $fwrite(f0, "@%5h\n", 'h10004 + i0*'h8);
        $fwrite(f0, "%2h %2h %2h %2h\n", vu[i0].ui[31:24], vu[i0].ui[23:16], vu[i0].ui[15:8], vu[i0].ui[7:0]);
    end
    $fclose(f0);
end endtask

endprogram