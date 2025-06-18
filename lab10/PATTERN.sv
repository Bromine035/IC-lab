`timescale 1ns/1ps
`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_OS.sv"
`define CYCLE_TIME 10.0

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================

parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
// parameter IDNUM   = 256;
parameter cycle = `CYCLE_TIME;
integer	pnum = 1000000;
integer n0, n1, n2, f0, i0, i1, i2, i3, i4, i5, latency, total_latency;

//================================================================
// wire & registers 
//================================================================

User_id ruid, rsid;
Action ract;
Item_id ritm;
Item_num rnum, rnum1, rnum2;
Money ramt;

User_id vuid_rt [15:0];
User_id vsid_rt [15:0];
Item_id vitm_rt [15:0];
Item_num vnum_rt [15:0];
logic [3:0] vdrt [15:0]; // delay time of trturn task
logic [4:0] nfrt; // number for the fifo of return task
logic [3:0] nirt; // index of the fifo of return task

Error_Msg rerm, rerm0;
logic rcmp;
logic [31:0] roif;

logic [255:0] rbuy;
logic [255:0] rsel; // just be a seller
logic rchu; // change user
logic rcks; // check seller's inventory
logic [1:0] rstk; // stock
logic [5:0] v0 [2:0];
Item_id vitm [2:0];

class user;
    Shop_Info si;
    User_Info ui;
    function new();
        ;
    endfunction
endclass

class randomer_uid;
    randc int nuid;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint l0{
        nuid inside{[0:255]};
    }
endclass

class randomer_sid;
    randc int nsid;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint l0{
        nsid inside{[0:255]};
    }
endclass

class randomer_itm;
    rand Item_id nitm;
    function new(int seed);
        this.srandom(seed);
    endfunction
    constraint l0{
        nitm inside{Large, Medium, Small};
    }
endclass

user vu [255:0];
randomer_uid rd0 = new(118);
randomer_sid rd1 = new(315);
randomer_sid rd1_1 = new(613);
randomer_itm rd2 = new(514);

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
    #cycle;
    inf.rst_n = 1'b0;
    #cycle;
    inf.rst_n = 1'b1;
    #cycle;
    #cycle;

    total_latency = 0;
    nfrt = 0;
    rbuy = 256'b0;
    rsel = 256'b0;
    for(i1 = 0; i1 < pnum; i1 = i1 + 1) begin
        if(nfrt > 0) begin
            for(i4 = 0; i4 < nfrt; i4 = i4 + 1) begin
                if(vdrt[i4] == 0) nirt = i4;
            end
            if(vdrt[nirt] == 0) begin
                return_task;
            end
            else begin
                decide_task;
            end
        end
        else begin
            decide_task;
        end
        if(nfrt > 0) begin
            for(i5 = 0; i5 < nfrt; i5 = i5 + 1) begin
                vdrt[i5] = (vdrt[i5] == 0)?(0):(vdrt[i5] - 1);
            end
        end
        judge_task;
        $display("\033[1;34mPat No.%6d - User_ID: %3d, Action: %10s, Item: %6s, Item_number: %2d, Amount: %5d, Seller_ID: %3d", i1, ruid, ract.name(), ritm.name(), rnum, ramt, rsid);
        $display("\033[1;32mGolden result - Complete: %1b, Error_Msg: %14s, Out_info: %8h", rcmp, rerm.name(), roif);
        #cycle;
        send_task;
        wait_task;
        output_task;
        n0 = $urandom()%9;
        #(cycle*n0);

        @(negedge clk);
    end
    $display("-------------------------------------------------");
    $display("-- All pattern passed because Br35 is handsome --");
    $display("-------------------------------------------------");
    $finish;
end

task init_dram; begin
    f0 = $fopen(DRAM_p_r, "w");
    for(i0 = 0; i0 < 256; i0 = i0 + 1) begin
        vu[i0] = new();
        vu[i0].si = $urandom();
        vu[i0].ui = $urandom();
        if(vu[i0].si.level == Copper) begin
            vu[i0].si.exp = $urandom()%'d999;
        end
        else if(vu[i0].si.level == Silver) begin
            vu[i0].si.exp = $urandom()%'d2499;
        end
        else if(vu[i0].si.level == Gold) begin
            vu[i0].si.exp = $urandom()%'d3999;
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
end 
endtask

task decide_task; begin
    n0 = $urandom()%'d2;
    if(n0 == 0 || i1 == 0) begin
        rd0.randomize();
        ruid = rd0.nuid;
        rchu = 1'b1;
    end
    else begin
        rchu = 1'b0;
    end
    n0 = $urandom()%'d16; // 9 3 3 1
    if(n0 < 9) ract = Buy;
    else if(n0 < 12) ract = Check;
    else if(n0 < 15) ract = Deposit;
    else ract = Return;
    
    if(ract == Buy) begin
        buy_task;
    end
    else if(ract == Check) begin
        check_task;
    end
    else if(ract == Deposit) begin
        deposit_task;
    end
    else begin
        wrong_task;
    end
end
endtask

task buy_task; begin
    n0 = $urandom()%16; // 8 0 1 7
    if(n0 < 8) rerm0 = No_Err;
    else if(n0 < 8) rerm0 = INV_Full;
    else if(n0 < 9) rerm0 = INV_Not_Enough;
    else rerm0 = Out_of_money;
    rd1.randomize();
    rsid = rd1.nsid;
    while (ruid == rsid) begin
        rd1.randomize();
        rsid = rd1.nsid;
    end

    rstk = 0;
    if(rerm0 == No_Err) begin
        if(vu[ruid].si.large_num < 63 && vu[rsid].si.large_num > 0) begin
            vitm[rstk] = Large;
            v0[rstk] = ((63 - vu[ruid].si.large_num) < vu[rsid].si.large_num)?(63 - vu[ruid].si.large_num):(vu[rsid].si.large_num);
            rstk = rstk + 1;
        end
        if(vu[ruid].si.medium_num < 63 && vu[rsid].si.medium_num > 0) begin
            vitm[rstk] = Medium;
            v0[rstk] = ((63 - vu[ruid].si.medium_num) < vu[rsid].si.medium_num)?(63 - vu[ruid].si.medium_num):(vu[rsid].si.medium_num);
            rstk = rstk + 1;
        end
        if(vu[ruid].si.small_num < 63 && vu[rsid].si.small_num > 0) begin
            vitm[rstk] = Small;
            v0[rstk] = ((63 - vu[ruid].si.small_num) < vu[rsid].si.small_num)?(63 - vu[ruid].si.small_num):(vu[rsid].si.small_num);
            rstk = rstk + 1;
        end
        if(rstk == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
            rnum = ($urandom()%63) + 1;
        end
        else begin
            n0 = $urandom()%rstk;
            ritm = vitm[n0];
            rnum = ($urandom()%v0[n0]) + 1;
        end
    end
    else if(rerm0 == INV_Full) begin
        if(vu[ruid].si.large_num > 0) begin
            vitm[rstk] = Large;
            v0[rstk] = 63 - vu[ruid].si.large_num + 1;
            rstk = rstk + 1;
        end
        if(vu[ruid].si.medium_num > 0) begin
            vitm[rstk] = Medium;
            v0[rstk] = 63 - vu[ruid].si.medium_num + 1;
            rstk = rstk + 1;
        end
        if(vu[ruid].si.small_num > 0) begin
            vitm[rstk] = Small;
            v0[rstk] = 63 - vu[ruid].si.small_num + 1;
            rstk = rstk + 1;
        end
        if(rstk == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
            rnum = ($urandom()%63) + 1;
        end
        else begin
            n0 = $urandom()%rstk;
            ritm = vitm[n0];
            rnum = ($urandom()%(63 - v0[n0] + 1)) + v0[n0];
        end
    end
    else if(rerm0 == INV_Not_Enough) begin
        if((63 - vu[ruid].si.large_num) > vu[rsid].si.large_num) begin
            vitm[rstk] = Large;
            v0[rstk] = $urandom()%((63 - vu[ruid].si.large_num) - vu[rsid].si.large_num) + vu[rsid].si.large_num + 1;
            rstk = rstk + 1;
        end
        if((63 - vu[ruid].si.medium_num) > vu[rsid].si.medium_num) begin
            vitm[rstk] = Medium;
            v0[rstk] = $urandom()%((63 - vu[ruid].si.medium_num) - vu[rsid].si.medium_num) + vu[rsid].si.medium_num + 1;
            rstk = rstk + 1;
        end
        if((63 - vu[ruid].si.small_num) > vu[rsid].si.small_num) begin
            vitm[rstk] = Small;
            v0[rstk] = $urandom()%((63 - vu[ruid].si.small_num) - vu[rsid].si.small_num) + vu[rsid].si.small_num + 1;
            rstk = rstk + 1;
        end
        if(rstk == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
            rnum = ($urandom()%63) + 1;
        end
        else begin
            n0 = $urandom()%rstk;
            ritm = vitm[n0];
            rnum = v0[n0];
        end
    end
    else begin
        if(vu[ruid].si.level == Copper) n0 = 70; 
        else if(vu[ruid].si.level == Silver) n0 = 50;
        else if(vu[ruid].si.level == Gold) n0 = 30;
        else n0 = 10;
        if((300 * vu[rsid].si.large_num + n0) > vu[ruid].ui.money) begin
            vitm[rstk] = Large;
            n1 = (vu[ruid].ui.money) / 300 + 1;
            v0[rstk] = ($urandom()%(vu[rsid].si.large_num - n1 + 1)) + n1;
            rstk = rstk + 1;
        end
        if((200 * vu[rsid].si.medium_num + n0) > vu[ruid].ui.money) begin
            vitm[rstk] = Medium;
            n1 = (vu[ruid].ui.money) / 200 + 1;
            v0[rstk] = ($urandom()%(vu[rsid].si.medium_num - n1 + 1)) + n1;
            rstk = rstk + 1;
        end
        if((100 * vu[rsid].si.small_num + n0) > vu[ruid].ui.money) begin
            vitm[rstk] = Small;
            n1 = (vu[ruid].ui.money) / 100 + 1;
            v0[rstk] = ($urandom()%(vu[rsid].si.small_num - n1 + 1)) + n1;
            rstk = rstk + 1;
        end
        if(rstk == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
            rnum = ($urandom()%63) + 1;
        end
        else begin
            n0 = $urandom()%rstk;
            ritm = vitm[n0];
            rnum = v0[n0];
        end
    end

    if($urandom()%8 < 3) insert_task; // 3/8
end
endtask

task check_task; begin
    rcks = $urandom()%2;
    if(rcks == 1'b1) begin
        rd1.randomize();
        rsid = rd1.nsid;
    end
end
endtask

task deposit_task; begin
    n0 = $urandom()%4;
    if(n0 == 0 && vu[ruid].ui.money > 0) begin // wallet is full
        n1 = 16'hffff - vu[ruid].ui.money + 1;
        ramt = ($urandom()%(16'hffff - n1 + 1)) + n1;
    end
    else if(vu[ruid].ui.money < 16'hffff) begin // no error
        ramt = ($urandom()%(16'hffff - vu[ruid].ui.money)) + 1;
    end
    else begin
        ramt = $urandom()%(16'hffff) + 1;
    end
end
endtask

task wrong_task; begin
    rd1.randomize();
    rsid = rd1.nsid;
    rd2.randomize();
    ritm = rd2.nitm;
    rnum = $urandom()%63 + 1;
end
endtask

task return_task; begin
    ract = Return;
    if(ruid != vuid_rt[nirt]) rchu = 1'b1;
    else rchu = 1'b0;
    ruid = vuid_rt[nirt];
    rsid = vsid_rt[nirt];
    ritm = vitm_rt[nirt];
    rnum = vnum_rt[nirt];
    pop_task;
    n0 = $urandom()%4;
    if(n0 == 0) rerm0 = No_Err;
    else if(n0 == 1) rerm0 = Wrong_ID;
    else if(n0 == 2) rerm0 = Wrong_Num;
    else rerm0 = Wrong_Item;

    if(rerm0 == Wrong_ID) begin
        rd1_1.randomize();
        rsid = rd1_1.nsid;
        if($urandom()%2 == 0) rnum = $urandom()%64;
        if($urandom()%2 == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
        end
    end
    else if(rerm0 == Wrong_Num) begin
        rnum = $urandom()%64;
        if($urandom()%2 == 0) begin
            rd2.randomize();
            ritm = rd2.nitm;
        end
    end
    else if(rerm0 == Wrong_Item) begin
        if(ritm == Large) begin
            if($urandom()%2 == 0) ritm = Medium;
            else ritm = Small;
        end
        else if(ritm == Medium) begin
            if($urandom()%2 == 0) ritm = Large;
            else ritm = Small;
        end
        else begin
            if($urandom()%2 == 0) ritm = Large;
            else ritm = Medium;
        end
    end
end
endtask

task insert_task; begin
    if(nfrt < 16) begin
        for(i2 = nfrt; i2 > 0; i2 = i2 - 1) begin
            vuid_rt[i2] = vuid_rt[i2 - 1];
            vsid_rt[i2] = vsid_rt[i2 - 1];
            vitm_rt[i2] = vitm_rt[i2 - 1];
            vnum_rt[i2] = vnum_rt[i2 - 1];
            vdrt[i2] = vdrt[i2 - 1];
        end
        vuid_rt[0] = ruid;
        vsid_rt[0] = rsid;
        vitm_rt[0] = ritm;
        vnum_rt[0] = rnum;
        vdrt[0] = $urandom()%16;
        nfrt = nfrt + 1;
    end
end
endtask

task pop_task; begin
    if(nirt < 15) begin
        for(i3 = nirt; i3 < 15; i3 = i3 + 1) begin
            vuid_rt[i3] = vuid_rt[i3 + 1];
            vsid_rt[i3] = vsid_rt[i3 + 1];
            vitm_rt[i3] = vitm_rt[i3 + 1];
            vnum_rt[i3] = vnum_rt[i3 + 1];
            vdrt[i3] = vdrt[i3 + 1];
        end
    end
    nfrt = nfrt - 1;
end
endtask

task judge_task; begin
    if(ract == Buy) begin
        if(vu[ruid].si.level == Copper) n0 = 70; 
        else if(vu[ruid].si.level == Silver) n0 = 50;
        else if(vu[ruid].si.level == Gold) n0 = 30;
        else n0 = 10;

        if(ritm == Large) begin
            rnum1 = vu[ruid].si.large_num;
            rnum2 = vu[rsid].si.large_num;
            n1 = 300*rnum; // money
            n2 = 60*rnum; // exp
        end
        else if(ritm == Medium) begin
            rnum1 = vu[ruid].si.medium_num;
            rnum2 = vu[rsid].si.medium_num;
            n1 = 200*rnum;
            n2 = 40*rnum;
        end
        else begin
            rnum1 = vu[ruid].si.small_num;
            rnum2 = vu[rsid].si.small_num;
            n1 = 100*rnum;
            n2 = 20*rnum;
        end

        if(rnum1 + rnum > 63) begin
            rerm = INV_Full;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else if(rnum2 < rnum) begin
            rerm = INV_Not_Enough;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else if(n1 + n0 > vu[ruid].ui.money) begin
            rerm = Out_of_money;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else begin
            vu[ruid].si.large_num  = (ritm ==  Large)?(vu[ruid].si.large_num  + rnum):(vu[ruid].si.large_num);
            vu[ruid].si.medium_num = (ritm == Medium)?(vu[ruid].si.medium_num + rnum):(vu[ruid].si.medium_num);
            vu[ruid].si.small_num  = (ritm ==  Small)?(vu[ruid].si.small_num  + rnum):(vu[ruid].si.small_num);
            if(vu[ruid].si.level == Copper && (n2 + vu[ruid].si.exp) > 999) begin
                vu[ruid].si.level = Silver;
                vu[ruid].si.exp = 12'd0;
            end
            else if(vu[ruid].si.level == Silver && (n2 + vu[ruid].si.exp) > 2499) begin
                vu[ruid].si.level = Gold;
                vu[ruid].si.exp = 12'd0;
            end
            else if(vu[ruid].si.level == Gold && (n2 + vu[ruid].si.exp) > 3999) begin
                vu[ruid].si.level = Platinum;
                vu[ruid].si.exp = 12'd0;
            end
            else begin
                vu[ruid].si.exp = (vu[ruid].si.level == Platinum)?(0):(vu[ruid].si.exp + n2);
            end
            vu[ruid].ui.money = vu[ruid].ui.money - (n1 + n0);
            vu[ruid].ui.shop_history.item_ID = ritm;
            vu[ruid].ui.shop_history.item_num = rnum;
            vu[ruid].ui.shop_history.seller_ID = rsid;
            vu[rsid].si.large_num  = (ritm ==  Large)?(vu[rsid].si.large_num  - rnum):(vu[rsid].si.large_num);
            vu[rsid].si.medium_num = (ritm == Medium)?(vu[rsid].si.medium_num - rnum):(vu[rsid].si.medium_num);
            vu[rsid].si.small_num  = (ritm ==  Small)?(vu[rsid].si.small_num  - rnum):(vu[rsid].si.small_num);
            if(n1 + vu[rsid].ui.money > 'hffff) vu[rsid].ui.money = 16'hffff;
            else vu[rsid].ui.money = vu[rsid].ui.money + n1;
            vu[rsid].ui.shop_history.item_ID = ritm;
            vu[rsid].ui.shop_history.item_num = rnum;
            vu[rsid].ui.shop_history.seller_ID = ruid;
            rbuy[ruid] = 1'b1;
            rsel[ruid] = 1'b0;
            rbuy[rsid] = 1'b0;
            rsel[rsid] = 1'b1;
            rerm = No_Err;
            rcmp = 1'b1;
            roif = vu[ruid].ui;
        end
    end
    else if(ract == Check) begin
        if(rcks == 1) begin
            roif = {14'b0, vu[rsid].si.large_num, vu[rsid].si.medium_num, vu[rsid].si.small_num};
            rbuy[rsid] = 1'b0;
            rsel[rsid] = 1'b0;
        end
        else begin
            roif = {16'b0, vu[ruid].ui.money};
        end
        rerm = No_Err;
        rcmp = 1'b1;
        rbuy[ruid] = 1'b0;
        rsel[ruid] = 1'b0;
    end
    else if(ract == Deposit) begin
        if(({16'b0, vu[ruid].ui.money} + ramt) > 'hffff) begin
            rerm = Wallet_is_Full;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else begin
            vu[ruid].ui.money = vu[ruid].ui.money + ramt;
            rerm = No_Err;
            rcmp = 1'b1;
            roif = {16'b0, vu[ruid].ui.money};
            rbuy[ruid] = 1'b0;
            rsel[ruid] = 1'b0;
        end
    end
    else begin
        if(!rbuy[ruid] || !rsel[vu[ruid].ui.shop_history.seller_ID] || vu[vu[ruid].ui.shop_history.seller_ID].ui.shop_history.seller_ID != ruid) begin
            rerm = Wrong_act;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else if(vu[ruid].ui.shop_history.seller_ID != rsid) begin
            rerm = Wrong_ID;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else if(vu[ruid].ui.shop_history.item_num != rnum) begin
            rerm = Wrong_Num;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else if(vu[ruid].ui.shop_history.item_ID != ritm) begin
            rerm = Wrong_Item;
            rcmp = 1'b0;
            roif = 32'b0;
        end
        else begin
            if(ritm == Large) n0 = 300*rnum;
            else if(ritm == Medium) n0 = 200*rnum;
            else n0 = 100*rnum;
            vu[ruid].si.large_num = (ritm == Large)?(vu[ruid].si.large_num - rnum):(vu[ruid].si.large_num);
            vu[ruid].si.medium_num = (ritm == Medium)?(vu[ruid].si.medium_num - rnum):(vu[ruid].si.medium_num);
            vu[ruid].si.small_num = (ritm == Small)?(vu[ruid].si.small_num - rnum):(vu[ruid].si.small_num);
            vu[ruid].ui.money = vu[ruid].ui.money + n0;
            vu[rsid].si.large_num = (ritm == Large)?(vu[rsid].si.large_num + rnum):(vu[rsid].si.large_num);
            vu[rsid].si.medium_num = (ritm == Medium)?(vu[rsid].si.medium_num + rnum):(vu[rsid].si.medium_num);
            vu[rsid].si.small_num = (ritm == Small)?(vu[rsid].si.small_num + rnum):(vu[rsid].si.small_num);
            vu[rsid].ui.money = vu[rsid].ui.money - n0;
            rbuy[ruid] = 1'b0;
            rsel[ruid] = 1'b0;
            rbuy[rsid] = 1'b0;
            rsel[rsid] = 1'b0;
            rerm = No_Err;
            rcmp = 1'b1;
            roif = {14'b0, vu[ruid].si.large_num, vu[ruid].si.medium_num, vu[ruid].si.small_num};
        end
    end
end
endtask

task send_task; begin
    if(rchu) begin
        inf.id_valid = 1'b1;
        inf.D.d_id[1] = 'b0;
        inf.D.d_id[0] = ruid;
        #cycle;
        inf.id_valid = 1'b0;
        inf.D = 'bx;
        n0 = $urandom()%5 + 1;
        #(cycle*n0);
    end
    inf.act_valid = 1'b1;
    inf.D.d_act[3] = No_action;
    inf.D.d_act[2] = No_action;
    inf.D.d_act[1] = No_action;
    inf.D.d_act[0] = ract;
    #cycle;
    inf.act_valid = 1'b0;
    inf.D = 'bx;
    if(ract == Buy || ract == Return) begin
        n0 = $urandom()%5 + 1;
        #(cycle*n0);
        inf.item_valid = 1'b1;
        inf.D.d_item[7] = No_item;
        inf.D.d_item[6] = No_item;
        inf.D.d_item[5] = No_item;
        inf.D.d_item[4] = No_item;
        inf.D.d_item[3] = No_item;
        inf.D.d_item[2] = No_item;
        inf.D.d_item[1] = No_item;
        inf.D.d_item[0] = ritm;
        #cycle;
        inf.item_valid = 1'b0;
        inf.D = 'bx;

        n0 = $urandom()%5 + 1;
        #(cycle*n0);
        inf.num_valid = 1'b1;
        inf.D.d_item_num = {10'b0, rnum};
        #cycle;
        inf.num_valid = 1'b0;
        inf.D = 'bx;

        n0 = $urandom()%5 + 1;
        #(cycle*n0);
        inf.id_valid = 1'b1;
        inf.D.d_id[1] = 'b0;
        inf.D.d_id[0] = rsid;
        #cycle;
        inf.id_valid = 1'b0;
        inf.D = 'bx;
    end
    else if(ract == Check && rcks) begin
        // n0 = $urandom()%5 + 1;
        n0 = $urandom()%4 + 1;
        #(cycle*n0);
        inf.id_valid = 1'b1;
        inf.D.d_id[1] = 'b0;
        inf.D.d_id[0] = rsid;
        #cycle;
        inf.id_valid = 1'b0;
        inf.D = 'bx;
    end
    else if(ract == Deposit) begin
        n0 = $urandom()%5 + 1;
        #(cycle*n0);
        inf.amnt_valid = 1'b1;
        inf.D.d_money = ramt;
        #cycle;
        inf.amnt_valid = 1'b0;
        inf.D = 'bx;
    end
end
endtask

task wait_task; begin
    latency = 0;
    while(inf.out_valid !== 1'b1) begin
        latency = latency + 1;
        // if(latency == 10000) begin
        //     $display("Slimulation time too long > 10000");
        //     $finish; 
        // end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

task output_task; begin
    if(inf.err_msg != rerm || inf.complete != rcmp || inf.out_info != roif) begin
        $display("\033[1;31mdesign result - Complete: %1b, Error_Msg: %14s, Out_info: %8h", inf.complete, inf.err_msg.name(), inf.out_info);
        $display(":( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( FAIL :( ");
        $display("\033[1;34mUser shop_info - Large_num: %2d, Medeium_num %2d, Small_num: %2d, Level: %8s, Exp: %5d", vu[ruid].si.large_num, vu[ruid].si.medium_num, vu[ruid].si.small_num, vu[ruid].si.level.name(), vu[ruid].si.exp);
        $display("\033[1;32mUser user_info - Money: %5d, History_item: %6s, History_num: %2d, History_ID: %3d", vu[ruid].ui.money, vu[ruid].ui.shop_history.item_ID.name(), vu[ruid].ui.shop_history.item_num, vu[ruid].ui.shop_history.seller_ID);
        $display("\033[1;34mSelr shop_info - Large_num: %2d, Medeium_num %2d, Small_num: %2d, Level: %8s, Exp: %5d", vu[rsid].si.large_num, vu[rsid].si.medium_num, vu[rsid].si.small_num, vu[rsid].si.level.name(), vu[rsid].si.exp);
        $display("\033[1;32mSelr user_info - Money: %5d, History_item: %6s, History_num: %2d, History_ID: %3d", vu[rsid].ui.money, vu[rsid].ui.shop_history.item_ID.name(), vu[rsid].ui.shop_history.item_num, vu[rsid].ui.shop_history.seller_ID);
        $display("Wrong Answer");
        $finish;
    end
end
endtask

endprogram
