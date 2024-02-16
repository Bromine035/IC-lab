module OS(input clk, INF.OS_inf inf);
import usertype::*;

stateo cst, nst;
logic rok0;
User_id ruer, rser;
Action ract;
Item_id ritm;
Item_num_ext rnum;
Money ramt;
Shop_Info rusi, rssi; // user shop info, seller shop info
User_Info ruui, rsui; // user user info, seller user info
Item_num wuiv, wsiv;
wire [31:0] wfee, wprc, wexp;
wire wupg; // upgrade
Error_Msg rerm; // error message
logic [255:0] rbuy;
logic [255:0] rsel; // just be a seller
logic [2:0] rck0;

assign wuiv = (ritm == Large)?(rusi.large_num):((ritm == Medium)?(rusi.medium_num):(rusi.small_num));
assign wsiv = (ritm == Large)?(rssi.large_num):((ritm == Medium)?(rssi.medium_num):(rssi.small_num));
assign wfee = (rusi.level[1])?((rusi.level[0])?('d70):('d50)):((rusi.level[0])?('d30):('d10));
assign wprc = (ritm == Large)?('d300):((ritm == Medium)?('d200):('d100));
assign wexp = rusi.exp + ((ritm == Large)?('d60):((ritm == Medium)?('d40):('d20)))*rnum;
assign wupg = (rusi.level[1])?((rusi.level[0])?(wexp > 'd999):(wexp > 'd2499)):((rusi.level[0])?(wexp > 'd3999):(1'b0));
assign inf.err_msg = (inf.out_valid)?(rerm):(No_Err);
assign inf.complete = (inf.out_valid && rerm == No_Err)?(1'b1):(1'b0);

always_ff @(posedge clk, negedge inf.rst_n) begin : block_cst
    if(!inf.rst_n) begin
        cst <= idle;
        rok0 <= 1'b0; // 1 for check user's deposit, 0 for check seller's stocks
        rck0 <= 3'b0;
        inf.out_valid <= 1'b0;
        ruer <= 8'b0;
        rser <= 8'b0;
        ract <= 4'b0;
        ritm <= 2'b0;
        rnum <= 6'b0;
        ramt <= 16'b0;
    end
    else begin
        cst <= nst;
        inf.out_valid <= (cst == oudt)?(1'b1):(1'b0);
        if(cst == idle) begin
            if(inf.id_valid) begin
                if(rok0 == 1'b0) begin
                    ruer <= inf.D.d_id[0];
                    rok0 <= 1'b1;
                end
                else begin
                    rser <= inf.D.d_id[0];
                    rok0 <= 1'b0;
                end
            end
            else if(inf.act_valid) begin
                ract <= inf.D.d_act[0];
                rok0 <= 1'b1;
            end
            else if(inf.item_valid) begin
                ritm <= inf.D.d_item[0];
            end
            else if(inf.num_valid) begin
                rnum <= inf.D.d_item_num;
            end
            else if(inf.amnt_valid) begin
                ramt <= inf.D.d_money;
            end
            else if(rck0 == 3'd5) begin
                rck0 <= 3'd0;
            end
            else begin
                rck0 <= (ract == Check)?(rck0 + 3'd1):(3'd0);
            end
        end
        else if(cst == oudt)begin
            rok0 <= 1'b0;
            ract <= No_action;
            rck0 <= 3'd0;
        end
        else begin
            rok0 <= rok0;
            rck0 <= 3'd0;
        end
    end
end

always_comb begin : block_nst
    if(!inf.rst_n) begin
        nst <= idle;
    end
    else begin
        case(cst)
        idle:
        if(inf.amnt_valid || (inf.id_valid && rok0 && ract != Check) || rck0 == 3'd5) begin
            nst <= redu;
        end
        else if(inf.id_valid && rok0 && ract == Check) begin
            nst <= reds;
        end
        else begin
            nst <= idle;
        end
        redu:
        nst <= (inf.C_out_valid)?((ract == Check || ract == Deposit)?(calc):(reds)):(redu);
        reds:
        nst <= (inf.C_out_valid)?(calc):(reds);
        calc:
        nst <= stal;
        stal:
        nst <= (rerm == No_Err && ract != Check)?(wrtu):(oudt);
        wrtu:
        nst <= (inf.C_out_valid)?((ract == Deposit)?(oudt):(wrts)):(wrtu);
        wrts:
        nst <= (inf.C_out_valid)?(oudt):(wrts);
        oudt:
        nst <= idle;
        default:
        nst <= idle;
        endcase
    end
end

always_ff @(posedge clk, negedge inf.rst_n) begin : block_main
    if(!inf.rst_n) begin
        inf.C_addr <= 8'b0;
        inf.C_data_w <= 64'b0;
        inf.C_in_valid <= 1'b0;
        inf.C_r_wb <= 1'b0; // 1: read, 0: write
        rsel <= 256'b0;
        rbuy <= 256'b0;
        ruui <= 32'b0;
        rusi <= 32'b0;
        rsui <= 32'b0;
        rssi <= 32'b0;
        rerm <= 4'b0;
    end
    else if(cst == redu) begin
        if(inf.C_out_valid) begin
            if(nst == reds) begin
                inf.C_in_valid <= 1'b1;
                inf.C_addr <= (ract == Return)?(inf.C_data_r[63:56]):(rser);
            end
            else begin
                inf.C_in_valid <= 1'b0;
            end
            ruui <= {inf.C_data_r[39:32], inf.C_data_r[47:40], inf.C_data_r[55:48], inf.C_data_r[63:56]};
            rusi <= {inf.C_data_r[7:0], inf.C_data_r[15:8], inf.C_data_r[23:16], inf.C_data_r[31:24]};
        end
        else begin
            inf.C_in_valid <= 1'b0;
        end
        inf.C_r_wb <= 1'b1;
    end
    else if(cst == reds) begin
        if(inf.C_out_valid) begin
            rsui <= {inf.C_data_r[39:32], inf.C_data_r[47:40], inf.C_data_r[55:48], inf.C_data_r[63:56]};
            rssi <= {inf.C_data_r[7:0], inf.C_data_r[15:8], inf.C_data_r[23:16], inf.C_data_r[31:24]};
        end
        inf.C_in_valid <= 1'b0;
        inf.C_r_wb <= 1'b1;
    end
    else if(cst == calc) begin
        case(ract)
        Buy:
        if(({26'b0, wuiv} + rnum) > 32'd63) begin
            rerm <= INV_Full;
        end
        else if(rnum > {10'b0, wsiv}) begin
            rerm <= INV_Not_Enough;
        end
        else if((wfee + wprc*rnum) > ruui.money) begin
            rerm <= Out_of_money;
        end
        else begin
            rerm <= No_Err;
            rusi.large_num  <= (ritm == Large )?(rusi.large_num  + rnum):(rusi.large_num);
            rusi.medium_num <= (ritm == Medium)?(rusi.medium_num + rnum):(rusi.medium_num);
            rusi.small_num  <= (ritm == Small )?(rusi.small_num  + rnum):(rusi.small_num);
            rusi.level <= (wupg)?(rusi.level - 2'b1):(rusi.level);
            rusi.exp <= (wupg || rusi.level == Platinum)?('b0):(wexp);
            ruui.money <= ruui.money - (wfee + wprc*rnum);
            ruui.shop_history.item_ID <= ritm;
            ruui.shop_history.item_num <= rnum;
            ruui.shop_history.seller_ID <= rser;
            rssi.large_num  <= (ritm == Large )?(rssi.large_num  - rnum):(rssi.large_num);
            rssi.medium_num <= (ritm == Medium)?(rssi.medium_num - rnum):(rssi.medium_num);
            rssi.small_num  <= (ritm == Small )?(rssi.small_num  - rnum):(rssi.small_num);
            rssi.level <= rssi.level;
            rssi.exp <= rssi.exp;
            rsui.money <= ((wprc*rnum + rsui.money) > 16'hffff)?(16'hffff):(wprc*rnum + rsui.money);
            rsui.shop_history.item_ID <= ritm;
            rsui.shop_history.item_num <= rnum;
            rsui.shop_history.seller_ID <= ruer;
            rsel[ruer] <= 1'b0;
            rbuy[ruer] <= 1'b1;
            rsel[rser] <= 1'b1;
            rbuy[rser] <= 1'b0;
        end
        Check: begin
            if(!rok0) begin
                rsel[rser] <= 1'b0;
                rbuy[rser] <= 1'b0;
            end
            rsel[ruer] <= 1'b0;
            rbuy[ruer] <= 1'b0;
            rerm <= No_Err;
        end
        Deposit:
        if(({16'b0, ruui.money} + ramt) > 16'hffff) begin
            rerm <= Wallet_is_Full;
        end
        else begin
            rerm <= No_Err;
            ruui.money <= ruui.money + ramt;
            rsel[ruer] <= 1'b0;
            rbuy[ruer] <= 1'b0;
        end
        Return:
        if(!rbuy[ruer] || !rsel[ruui.shop_history.seller_ID] || rsui.shop_history.seller_ID != ruer) begin
            rerm <= Wrong_act;
        end
        else if(ruui.shop_history.seller_ID != rser) begin
            rerm <= Wrong_ID;
        end
        else if(ruui.shop_history.item_num != rnum) begin
            rerm <= Wrong_Num;
        end
        else if(ruui.shop_history.item_ID != ritm) begin
            rerm <= Wrong_Item;
        end
        else begin
            rerm <= No_Err;
            rusi.large_num  <= (ritm == Large )?(rusi.large_num  - rnum):(rusi.large_num);
            rusi.medium_num <= (ritm == Medium)?(rusi.medium_num - rnum):(rusi.medium_num);
            rusi.small_num  <= (ritm == Small )?(rusi.small_num  - rnum):(rusi.small_num);
            rusi.level <= rusi.level;
            rusi.exp <= rusi.exp;
            ruui.money <= ruui.money + wprc*rnum;
            ruui.shop_history <= ruui.shop_history;
            rssi.large_num  <= (ritm == Large )?(rssi.large_num  + rnum):(rssi.large_num);
            rssi.medium_num <= (ritm == Medium)?(rssi.medium_num + rnum):(rssi.medium_num);
            rssi.small_num  <= (ritm == Small )?(rssi.small_num  + rnum):(rssi.small_num);
            rssi.level <= rssi.level;
            rssi.exp <= rssi.exp;
            rsui.money <= rsui.money - wprc*rnum;
            rsui.shop_history <= rsui.shop_history;
            rsel[ruer] <= 1'b0;
            rbuy[ruer] <= 1'b0;
            rsel[rser] <= 1'b0;
            rbuy[rser] <= 1'b0;
        end
        default:
        rerm <= No_Err;
        endcase 
    end
    else if(cst == stal) begin
        if(nst == wrtu) begin
            inf.C_in_valid <= 1'b1;
            inf.C_addr <= ruer;
            inf.C_r_wb <= 1'b0;
            inf.C_data_w <= {ruui[7:0], ruui[15:8], ruui[23:16], ruui[31:24], rusi[7:0], rusi[15:8], rusi[23:16], rusi[31:24]};
        end
        else begin
            inf.C_in_valid <= 1'b0;
            inf.C_r_wb <= 1'b1;
            inf.C_data_w <= 64'b0;
        end
    end
    else if(cst == wrtu) begin
        if(inf.C_out_valid && nst == wrts) begin
            inf.C_in_valid <= 1'b1;
            inf.C_addr <= rser;
            inf.C_r_wb <= 1'b0;
            inf.C_data_w <= {rsui[7:0], rsui[15:8], rsui[23:16], rsui[31:24], rssi[7:0], rssi[15:8], rssi[23:16], rssi[31:24]};
        end
        else begin
            inf.C_in_valid <= 1'b0;
            inf.C_r_wb <= 1'b1;
            inf.C_data_w <= 64'b0;
        end
    end
    else if(cst == wrts) begin
        inf.C_in_valid <= 1'b0;
        inf.C_r_wb <= 1'b1;
        inf.C_data_w <= 64'b0;
    end
    else begin
        if(nst == redu) begin
            inf.C_in_valid <= 1'b1;
            inf.C_addr <= ruer;
            inf.C_r_wb <= 1'b1;
        end
        else if(nst == reds) begin
            inf.C_in_valid <= 1'b1;
            inf.C_addr <= inf.D.d_id[0];
            inf.C_r_wb <= 1'b1;
        end
        else begin
            inf.C_in_valid <= 1'b0;
            inf.C_r_wb <= 1'b0;
        end
    end
end

always_ff @(posedge clk, negedge inf.rst_n) begin : block_out
    if(!inf.rst_n) begin
        inf.out_info <= 32'b0;
    end
    else if(cst == oudt && rerm == No_Err) begin
        case(ract)
        Buy:
        inf.out_info <= ruui;
        Check:
        inf.out_info <= (rok0)?({16'd0, ruui.money}):({14'd0, rssi.large_num, rssi.medium_num, rssi.small_num});
        Deposit:
        inf.out_info <= {16'd0, ruui.money};
        Return:
        inf.out_info <= {14'd0, rusi.large_num, rusi.medium_num, rusi.small_num};
        default:
        inf.out_info <= 32'b0;
        endcase
    end
    else begin
        inf.out_info <= 32'b0;
    end
end
endmodule