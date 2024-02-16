module QUEEN(
    //Input Port
    clk,
    rst_n,

    in_valid,
    col,
    row,

    in_valid_num,
    in_num,

    out_valid,
    out,

    );

input               clk, rst_n, in_valid,in_valid_num;
input       [3:0]   col,row;
input       [2:0]   in_num;

output reg          out_valid;
output reg  [3:0]   out;

//==============================================//
//             Parameter and Integer            //
//==============================================//

parameter idle = 3'd0;
parameter init = 3'd1;
parameter dots = 3'd2;
parameter find = 3'd3;
parameter over = 3'd5;

//==============================================//
//                 reg declaration              //
//==============================================//

reg [2:0] cst, nst;
reg [11:0] mdot [11:0]; // dot map
reg rfok; // state find ok 1: go dots, 2: go back, 3: go over;
reg rinok; // if input number is fix
reg bakf;
reg [31:0] r0;
reg [3:0] ricol;
reg [3:0] rirow;
reg [2:0] rinum;
reg roval;
reg [3:0] roout;
reg [3:0] icol [5:0]; // input data
reg [3:0] irow [5:0];
reg [2:0] inum; // input number
reg [3:0] pcol [10:0]; // position
reg [3:0] prow [10:0];
reg [3:0] pnum; // position counter
reg [3:0] rdot [11:0]; // additional dots 
wire [3:0] w0 [11:0];
wire [3:0] wfz;
wire [23:0] wicol;
wire [23:0] wirow;
wire [43:0] wpcol;
wire [43:0] wprow;
wire [47:0] wrdot;
wire [3:0] wrtoo [11:0];
wire [3:0] wover;
wire [3:0] wpnso;

//==============================================//
//            FSM State Declaration             //
//==============================================//
//current_state

//next_state

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle; // reset everything
        ricol <= 4'b0;
        rirow <= 4'b0;
        rinum <= 3'b0;
        out_valid <= 1'b0;
        out <= 4'b0;
    end
    else begin
        cst <= nst;
        ricol <= col;
        rirow <= row;
        rinum <= in_num;
        out_valid <= roval;
        out <= roout;
    end
end

always @(*) begin
    case(cst)
    idle:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(in_valid) begin
        nst <= init;
    end
    else begin
        nst <= idle;
    end

    init:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(in_valid) begin
        nst <= init;
    end
    else begin
        nst <= dots;
    end

    dots:
    if(!rst_n) begin
        nst <= idle;
    end
    else begin
        nst <= find;
    end

    find:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(rfok) begin 
        nst <= over;
    end
    else begin
        nst <= dots;
    end

    over:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(r0 == 4'd11) begin
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
        mdot[0] <= 12'b0; mdot[1] <= 12'b0; mdot[2] <= 12'b0; mdot[3] <= 12'b0;
        mdot[4] <= 12'b0; mdot[5] <= 12'b0; mdot[6] <= 12'b0; mdot[7] <= 12'b0;
        mdot[8] <= 12'b0; mdot[9] <= 12'b0; mdot[10] <= 12'b0; mdot[11] <= 12'b0;
        rfok <= 1'b0;
        rinok <= 1'b0;
        bakf <= 1'b0;
        r0 <= 32'b0;
        icol[0] <= 4'd15; icol[1] <= 4'd15; icol[2] <= 4'd15;
        icol[3] <= 4'd15; icol[4] <= 4'd15; icol[5] <= 4'd15;
        irow[0] <= 4'd15; irow[1] <= 4'd15; irow[2] <= 4'd15;
        irow[3] <= 4'd15; irow[4] <= 4'd15; irow[5] <= 4'd15;
        inum <= 3'b0;
        pcol[0] <= 4'd15; pcol[1] <= 4'd15; pcol[2] <= 4'd15; pcol[3] <= 4'd15;
        pcol[4] <= 4'd15; pcol[5] <= 4'd15; pcol[6] <= 4'd15; pcol[7] <= 4'd15;
        pcol[8] <= 4'd15; pcol[9] <= 4'd15; pcol[10] <= 4'd15;
        prow[0] <= 4'd15; prow[1] <= 4'd15; prow[2] <= 4'd15; prow[3] <= 4'd15;
        prow[4] <= 4'd15; prow[5] <= 4'd15; prow[6] <= 4'd15; prow[7] <= 4'd15;
        prow[8] <= 4'd15; prow[9] <= 4'd15; prow[10] <= 4'd15;
        pnum <= 4'b0;
        rdot[0] <= 4'b0; rdot[1] <= 4'b0; rdot[2] <= 4'b0; rdot[3] <= 4'b0;
        rdot[4] <= 4'b0; rdot[5] <= 4'b0; rdot[6] <= 4'b0; rdot[7] <= 4'b0;
        rdot[8] <= 4'b0; rdot[9] <= 4'b0; rdot[10] <= 4'b0; rdot[11] <= 4'b0;
        roval <= 1'b0;
        roout <= 4'b0;
    end
    else if(cst == init) begin
        if(rinok) ;
        else begin
            inum <= rinum;
            r0 <= 32'd0;
            rinok <= 1'b1;
        end
        icol[r0] <= ricol;
        irow[r0] <= rirow;
        r0 <= r0 + 32'd1;
    end
    else if(cst == dots) begin
        mdot[0] <= rtom0.wout[11:0];
        mdot[1] <= rtom0.wout[23:12];
        mdot[2] <= rtom0.wout[35:24];
        mdot[3] <= rtom0.wout[47:36];
        mdot[4] <= rtom0.wout[59:48];
        mdot[5] <= rtom0.wout[71:60];
        mdot[6] <= rtom0.wout[83:72];
        mdot[7] <= rtom0.wout[95:84];
        mdot[8] <= rtom0.wout[107:96];
        mdot[9] <= rtom0.wout[119:108];
        mdot[10] <= rtom0.wout[131:120];
        mdot[11] <= rtom0.wout[143:132];
    end
    else if(cst == find) begin
        if(wover == 4'd12) begin
                r0 <= 32'd0;
                rfok <= 1'b1;
        end
        else if(wfz == 4'd15) begin
            rdot[pcol[wpnso]] <= (rdot[pcol[wpnso]] + 4'b1);
            rdot[pcol[pnum]] <= (bakf)?4'b0:rdot[pcol[pnum]];
            pnum <= wpnso;
            bakf <= 1'b1;
            rfok <= 1'b0;
        end
        else begin
            pcol[pnum] <= fz0.n0;
            prow[pnum] <= wfz;
            pnum <= pnum + 1;
            rfok <= 1'b0;
            bakf <= 1'b0;
        end
    end
    else if (cst == over) begin
        roval <= 1'b1;
        r0 <= r0 + 32'b1;
        roout <= wrtoo[r0];
    end
    else begin
        rfok <= 1'b0;
        rinok <= 1'b0;
        bakf <= 1'b0;
        r0 <= 32'b0;
        icol[0] <= 4'd15; icol[1] <= 4'd15; icol[2] <= 4'd15;
        icol[3] <= 4'd15; icol[4] <= 4'd15; icol[5] <= 4'd15;
        irow[0] <= 4'd15; irow[1] <= 4'd15; irow[2] <= 4'd15;
        irow[3] <= 4'd15; irow[4] <= 4'd15; irow[5] <= 4'd15;
        inum <= 3'b0;
        pcol[0] <= 4'd15; pcol[1] <= 4'd15; pcol[2] <= 4'd15; pcol[3] <= 4'd15;
        pcol[4] <= 4'd15; pcol[5] <= 4'd15; pcol[6] <= 4'd15; pcol[7] <= 4'd15;
        pcol[8] <= 4'd15; pcol[9] <= 4'd15; pcol[10] <= 4'd15;
        prow[0] <= 4'd15; prow[1] <= 4'd15; prow[2] <= 4'd15; prow[3] <= 4'd15;
        prow[4] <= 4'd15; prow[5] <= 4'd15; prow[6] <= 4'd15; prow[7] <= 4'd15;
        prow[8] <= 4'd15; prow[9] <= 4'd15; prow[10] <= 4'd15;
        pnum <= 4'b0;
        rdot[0] <= 4'b0; rdot[1] <= 4'b0; rdot[2] <= 4'b0; rdot[3] <= 4'b0;
        rdot[4] <= 4'b0; rdot[5] <= 4'b0; rdot[6] <= 4'b0; rdot[7] <= 4'b0;
        rdot[8] <= 4'b0; rdot[9] <= 4'b0; rdot[10] <= 4'b0; rdot[11] <= 4'b0;
        roval <= 1'b0;
        roout <= 4'b0;
    end
end

//==============================================//
//                  Input Block                 //
//==============================================//

ptom rtom0(.wicol(wicol), .wirow(wirow), .inum(inum), .wpcol(wpcol), .wprow(wprow), .pnum(pnum), .wrdot(wrdot), .wout());
ptor ptor0(.wicol(wicol), .inum(inum), .wpcol(wpcol), .pnum(pnum), .rcol());
fz fz0(.rc(ptor0.rcol), .n0());
genvar i10;
generate
    for(i10 = 0; i10 < 12; i10 = i10+1) begin: fl10
        fz fz1(.rc(mdot[i10]), .n0());
        assign w0[i10] = fz1.n0;
    end
endgenerate
assign wfz = w0[fz0.n0];
ptoo rtoo0(.wicol(wicol), .wirow(wirow), .inum(inum), .wpcol(wpcol), .wprow(wprow), .pnum(pnum), .wout());
assign wicol[3:0]   = icol[0]; assign wicol[7:4]   = icol[1]; assign wicol[11:8]  = icol[2];
assign wicol[15:12] = icol[3]; assign wicol[19:16] = icol[4]; assign wicol[23:20] = icol[5];
assign wirow[3:0]   = irow[0]; assign wirow[7:4]   = irow[1]; assign wirow[11:8]  = irow[2];
assign wirow[15:12] = irow[3]; assign wirow[19:16] = irow[4]; assign wirow[23:20] = irow[5];
assign wpcol[3:0]   = pcol[0]; assign wpcol[7:4]   = pcol[1]; assign wpcol[11:8]  = pcol[2]; assign wpcol[15:12] = pcol[3];
assign wpcol[19:16] = pcol[4]; assign wpcol[23:20] = pcol[5]; assign wpcol[27:24] = pcol[6]; assign wpcol[31:28] = pcol[7];
assign wpcol[35:32] = pcol[8]; assign wpcol[39:36] = pcol[9]; assign wpcol[43:40] = pcol[10];
assign wprow[3:0]   = prow[0]; assign wprow[7:4]   = prow[1]; assign wprow[11:8]  = prow[2]; assign wprow[15:12] = prow[3];
assign wprow[19:16] = prow[4]; assign wprow[23:20] = prow[5]; assign wprow[27:24] = prow[6]; assign wprow[31:28] = prow[7];
assign wprow[35:32] = prow[8]; assign wprow[39:36] = prow[9]; assign wprow[43:40] = prow[10];
assign wrdot[3:0]   = rdot[0]; assign wrdot[7:4]   = rdot[1]; assign wrdot[11:8]  = rdot[2]; assign wrdot[15:12] = rdot[3];
assign wrdot[19:16] = rdot[4]; assign wrdot[23:20] = rdot[5]; assign wrdot[27:24] = rdot[6]; assign wrdot[31:28] = rdot[7];
assign wrdot[35:32] = rdot[8]; assign wrdot[39:36] = rdot[9]; assign wrdot[43:40] = rdot[10]; assign wrdot[47:44] = rdot[11];
assign wrtoo[0] = rtoo0.wout[3:0]; assign wrtoo[1] =   rtoo0.wout[7:4]; assign wrtoo[2] =  rtoo0.wout[11:8]; assign wrtoo[3] = rtoo0.wout[15:12];
assign wrtoo[4] = rtoo0.wout[19:16]; assign wrtoo[5] = rtoo0.wout[23:20]; assign wrtoo[6] = rtoo0.wout[27:24]; assign wrtoo[7] = rtoo0.wout[31:28];
assign wrtoo[8] = rtoo0.wout[35:32]; assign wrtoo[9] = rtoo0.wout[39:36]; assign wrtoo[10] = rtoo0.wout[43:40]; assign wrtoo[11] = rtoo0.wout[47:44];
assign wover = {1'b0, inum} + pnum;
assign wpnso = pnum - 4'b1;
//GOOD LUCKY

endmodule 

module fz(rc, n0);
input wire [11:0] rc;
output reg [3:0] n0;

always @(*) begin
if(!rc[0])      n0 <= 4'd0;
else if(!rc[1]) n0 <= 4'd1;
else if(!rc[2]) n0 <= 4'd2;
else if(!rc[3]) n0 <= 4'd3;
else if(!rc[4]) n0 <= 4'd4;
else if(!rc[5]) n0 <= 4'd5;
else if(!rc[6]) n0 <= 4'd6;
else if(!rc[7]) n0 <= 4'd7;
else if(!rc[8]) n0 <= 4'd8;
else if(!rc[9]) n0 <= 4'd9;
else if(!rc[10]) n0 <= 4'd10;
else if(!rc[11]) n0 <= 4'd11;
else            n0 <= 4'd15;
end
endmodule

module ptor(wicol, inum, wpcol, pnum, rcol);
input wire [23:0] wicol;
input wire [43:0] wpcol;
input wire [2:0] inum;
input wire [3:0] pnum;
output wire [11:0] rcol;

wire [6:0] w0;
wire [11:0] w1;
wire [3:0] icol [5:0];
wire [3:0] pcol [10:0];
assign w0 = (7'b1 << inum) - 1; // decode
assign w1 = (11'b1 << pnum) - 1;
assign icol[0] =   wicol[3:0]; assign icol[1] =   wicol[7:4]; assign icol[2] =  wicol[11:8];
assign icol[3] = wicol[15:12]; assign icol[4] = wicol[19:16]; assign icol[5] = wicol[23:20];
assign pcol[0] =   wpcol[3:0]; assign pcol[1] =   wpcol[7:4]; assign pcol[2] =  wpcol[11:8]; assign pcol[3] = wpcol[15:12];
assign pcol[4] = wpcol[19:16]; assign pcol[5] = wpcol[23:20]; assign pcol[6] = wpcol[27:24]; assign pcol[7] = wpcol[31:28];
assign pcol[8] = wpcol[35:32]; assign pcol[9] = wpcol[39:36]; assign pcol[10] = wpcol[43:40];
genvar i0, i1, i2;
generate
    for(i0 = 0; i0 < 12; i0 = i0+1) begin: ptor_fl0
        wire [5:0] w2;
        wire [10:0] w3;
        for(i1 = 0; i1 < 6; i1 = i1+1) begin: ptor_fl1
            assign w2[i1] = (icol[i1] == i0) && w0[i1];
        end
        for(i2 = 0; i2 < 11; i2 = i2+1) begin: ptor_fl2
            assign w3[i2] = (pcol[i2] == i0) && w1[i2];
        end
        assign rcol[i0] = w2[0]||w2[1]||w2[2]||w2[3]||w2[4]||w2[5]||w3[0]||w3[1]||w3[2]||w3[3]||w3[4]||w3[5]||w3[6]||w3[7]||w3[8]||w3[9]||w3[10];
    end
endgenerate
endmodule

module ptoo(wicol, wirow, inum, wpcol, wprow, pnum, wout);
input wire [23:0] wirow, wicol;
input wire [43:0] wprow, wpcol;
input wire [2:0] inum;
input wire [3:0] pnum;
output wire [47:0] wout;

wire [3:0] icol [5:0];
wire [3:0] irow [5:0];
wire [3:0] pcol [10:0];
wire [3:0] prow [10:0];
wire [3:0] rout [11:0];
assign icol[0] =   wicol[3:0]; assign icol[1] =   wicol[7:4]; assign icol[2] =  wicol[11:8];
assign icol[3] = wicol[15:12]; assign icol[4] = wicol[19:16]; assign icol[5] = wicol[23:20];
assign irow[0] =   wirow[3:0]; assign irow[1] =   wirow[7:4]; assign irow[2] =  wirow[11:8];
assign irow[3] = wirow[15:12]; assign irow[4] = wirow[19:16]; assign irow[5] = wirow[23:20];
assign pcol[0] =   wpcol[3:0]; assign pcol[1] =   wpcol[7:4]; assign pcol[2] =  wpcol[11:8]; assign pcol[3] = wpcol[15:12];
assign pcol[4] = wpcol[19:16]; assign pcol[5] = wpcol[23:20]; assign pcol[6] = wpcol[27:24]; assign pcol[7] = wpcol[31:28];
assign pcol[8] = wpcol[35:32]; assign pcol[9] = wpcol[39:36]; assign pcol[10] = wpcol[43:40];
assign prow[0] =   wprow[3:0]; assign prow[1] =   wprow[7:4]; assign prow[2] =  wprow[11:8]; assign prow[3] = wprow[15:12];
assign prow[4] = wprow[19:16]; assign prow[5] = wprow[23:20]; assign prow[6] = wprow[27:24]; assign prow[7] = wprow[31:28];
assign prow[8] = wprow[35:32]; assign prow[9] = wprow[39:36]; assign prow[10] = wprow[43:40];
assign wout[3:0]   = rout[0]; assign wout[7:4]   = rout[1]; assign wout[11:8]  = rout[2]; assign wout[15:12] = rout[3];
assign wout[19:16] = rout[4]; assign wout[23:20] = rout[5]; assign wout[27:24] = rout[6]; assign wout[31:28] = rout[7];
assign wout[35:32] = rout[8]; assign wout[39:36] = rout[9]; assign wout[43:40] = rout[10]; assign wout[47:44] = rout[11];
wire [6:0] w0;
wire [11:0] w1;
reg [11:0] m0 [11:0];
assign w0 = (7'b1 << inum) - 1; // decode
assign w1 = (11'b1 << pnum) - 1;
genvar i3, i4;
generate
    for(i3 = 0; i3 < 12; i3 = i3+1) begin: rtoo_fl3
        wire [3:0] wm [11:0];
        for(i4 = 0; i4 < 12; i4 = i4+1) begin: rtoo_fl4
            always @(*) begin
            if     (i3 == icol[0] && i4 == irow[0] && w0[0]) m0[i3][i4] <= 1'b1;
            else if(i3 == icol[1] && i4 == irow[1] && w0[1]) m0[i3][i4] <= 1'b1;
            else if(i3 == icol[2] && i4 == irow[2] && w0[2]) m0[i3][i4] <= 1'b1;
            else if(i3 == icol[3] && i4 == irow[3] && w0[3]) m0[i3][i4] <= 1'b1;
            else if(i3 == icol[4] && i4 == irow[4] && w0[4]) m0[i3][i4] <= 1'b1;
            else if(i3 == icol[5] && i4 == irow[5] && w0[5]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[0] && i4 == prow[0] && w1[0]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[1] && i4 == prow[1] && w1[1]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[2] && i4 == prow[2] && w1[2]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[3] && i4 == prow[3] && w1[3]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[4] && i4 == prow[4] && w1[4]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[5] && i4 == prow[5] && w1[5]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[6] && i4 == prow[6] && w1[6]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[7] && i4 == prow[7] && w1[7]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[8] && i4 == prow[8] && w1[8]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[9] && i4 == prow[9] && w1[9]) m0[i3][i4] <= 1'b1;
            else if(i3 == pcol[10] && i4 == prow[10] && w1[10]) m0[i3][i4] <= 1'b1;
            else m0[i3][i4] <= 1'b0;
            end
            assign wm[i4] = (m0[i3][i4])?i4:4'b0; // encode
        end
        assign rout[i3] = wm[0]|wm[1]|wm[2]|wm[3]|wm[4]|wm[5]|wm[6]|wm[7]|wm[8]|wm[9]|wm[10]|wm[11];
    end
endgenerate
endmodule

module ptom(wicol, wirow, inum, wpcol, wprow, pnum, wrdot, wout);
input wire [23:0] wirow, wicol;
input wire [43:0] wprow, wpcol;
input wire [2:0] inum;
input wire [3:0] pnum;
input wire [47:0] wrdot;
output wire [143:0] wout;

wire [3:0] icol [5:0];
wire [3:0] irow [5:0];
wire [3:0] pcol [10:0];
wire [3:0] prow [10:0];
wire [3:0] rdot [11:0];
wire [11:0] rout [11:0];
assign icol[0] =   wicol[3:0]; assign icol[1] =   wicol[7:4]; assign icol[2] =  wicol[11:8];
assign icol[3] = wicol[15:12]; assign icol[4] = wicol[19:16]; assign icol[5] = wicol[23:20];
assign irow[0] =   wirow[3:0]; assign irow[1] =   wirow[7:4]; assign irow[2] =  wirow[11:8];
assign irow[3] = wirow[15:12]; assign irow[4] = wirow[19:16]; assign irow[5] = wirow[23:20];
assign pcol[0] =   wpcol[3:0]; assign pcol[1] =   wpcol[7:4]; assign pcol[2] =  wpcol[11:8]; assign pcol[3] = wpcol[15:12];
assign pcol[4] = wpcol[19:16]; assign pcol[5] = wpcol[23:20]; assign pcol[6] = wpcol[27:24]; assign pcol[7] = wpcol[31:28];
assign pcol[8] = wpcol[35:32]; assign pcol[9] = wpcol[39:36]; assign pcol[10] = wpcol[43:40];
assign prow[0] =   wprow[3:0]; assign prow[1] =   wprow[7:4]; assign prow[2] =  wprow[11:8]; assign prow[3] = wprow[15:12];
assign prow[4] = wprow[19:16]; assign prow[5] = wprow[23:20]; assign prow[6] = wprow[27:24]; assign prow[7] = wprow[31:28];
assign prow[8] = wprow[35:32]; assign prow[9] = wprow[39:36]; assign prow[10] = wprow[43:40];
assign rdot[0] =   wrdot[3:0]; assign rdot[1] =   wrdot[7:4]; assign rdot[2] =  wrdot[11:8]; assign rdot[3] = wrdot[15:12];
assign rdot[4] = wrdot[19:16]; assign rdot[5] = wrdot[23:20]; assign rdot[6] = wrdot[27:24]; assign rdot[7] = wrdot[31:28];
assign rdot[8] = wrdot[35:32]; assign rdot[9] = wrdot[39:36]; assign rdot[10] = wrdot[43:40]; assign rdot[11] = wrdot[47:44];
assign wout[11:0]   = rout[0]; assign wout[23:12]   = rout[1]; assign wout[35:24]   = rout[2]; assign wout[47:36]    = rout[3];
assign wout[59:48]  = rout[4]; assign wout[71:60]   = rout[5]; assign wout[83:72]   = rout[6]; assign wout[95:84]    = rout[7];
assign wout[107:96] = rout[8]; assign wout[119:108] = rout[9]; assign wout[131:120] = rout[10]; assign wout[143:132] = rout[11];
wire [6:0] w0;
wire [11:0] w1;
assign w0 = (7'b1 << inum) - 1; // decode
assign w1 = (11'b1 << pnum) - 1;
genvar i5, i6, i7, i8, i9;
generate
    for(i5 = 0; i5 < 12; i5 = i5+1) begin: rtom_fl5
        wire [11:0] mw [11:0];
        for(i6 = 0; i6 < 12; i6 = i6+1) begin: rtom_fl6
            wire [5:0] w2;
            wire [10:0] w3;
            for(i7 = 0; i7 < 6; i7 = i7+1) begin: rtom_fl7
                wire [4:0] w4;
                wire [4:0] w5;
                assign w4 = {1'b0, icol[i7]} - i5;
                assign w5 = {1'b0, irow[i7]} - i6;
                abs5 ac(.wi(w4), .wo());
                abs5 ar(.wi(w5), .wo());
                assign w2[i7] = ((i5 == icol[i7])||(i6 == irow[i7])||(ac.wo == ar.wo))&&w0[i7];
            end
            for(i8 = 0; i8 < 11; i8 = i8+1) begin: rtom_fl8
                wire [4:0] w6;
                wire [4:0] w7;
                assign w6 = {1'b0, pcol[i8]} - i5;
                assign w7 = {1'b0, prow[i8]} - i6;
                abs5 ac(.wi(w6), .wo());
                abs5 ar(.wi(w7), .wo());
                assign w3[i8] = ((i5 == pcol[i8])||(i6 == prow[i8])||(ac.wo == ar.wo))&&w1[i8];
            end
            assign mw[0][i6] = w2[0]||w2[1]||w2[2]||w2[3]||w2[4]||w2[5]||w3[0]||w3[1]||w3[2]||w3[3]||w3[4]||w3[5]||w3[6]||w3[7]||w3[8]||w3[9]||w3[10];
        end
        for(i9 = 0; i9 < 11; i9 = i9+1) begin: rtom_fl9
            filz filz0(.vi(mw[i9]), .vo());
            assign mw[i9+1] = filz0.vo;
        end
        assign rout[i5] = mw[rdot[i5]];
    end
endgenerate
endmodule

module abs5(wi, wo);
input wire [4:0] wi;
output wire [4:0] wo;
assign wo = (wi[4])?((~wi)+1):wi;
endmodule

module filz(vi, vo); // fill a zero
input wire [11:0] vi;
output wire [11:0] vo;
fz fz0(.rc(vi), .n0());
assign vo = (fz0.n0 == 4'd15)?(12'd4095):(vi | (12'b1 << fz0.n0));
endmodule
