//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : EC_TOP.v
//   	Module Name : EC_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "INV_IP.v"
//synopsys translate_on

module EC_TOP(
    // Input signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Output signals
    out_valid, out_Rx, out_Ry
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [6-1:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
output reg out_valid;
output reg [6-1:0] out_Rx, out_Ry;

parameter idle = 1'b0;
parameter calc = 1'b1;

reg cst, nst;
reg [1:0] r0;
reg signed [6:0] rpx, rpy, rqx, rqy, rpm, ra;
wire wpeq;
wire [5:0] mi0o;
wire signed [15:0] wkid, wpy2, wmom, wrrx, wwry, wi0o, wt0o, wd0o, wx0o, wx1o, wx2o;
reg signed [15:0] rxps, rs, rrx;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle;
        rpx <= 7'b0;
        rpy <= 7'b0;
        rqx <= 7'b0;
        rqy <= 7'b0;
        rpm <= 7'b0;
        ra <= 7'b0;
    end
    else begin
        cst <= nst;
        rpx <= (cst == idle && nst == calc)?({1'b0, in_Px}):(rpx);
        rpy <= (cst == idle && nst == calc)?({1'b0, in_Py}):(rpy);
        rqx <= (cst == idle && nst == calc)?({1'b0, in_Qx}):(rqx);
        rqy <= (cst == idle && nst == calc)?({1'b0, in_Qy}):(rqy);
        rpm <= (cst == idle && nst == calc)?({1'b0, in_prime}):(rpm);
        ra  <= (cst == idle && nst == calc)?({1'b0, in_a}):(ra);
    end
end

always @(*) begin
    if(!rst_n) begin
        nst <= idle;
    end
    else begin
        case(cst)
        idle:
        if(in_valid) begin
            nst <= calc;
        end
        else begin
            nst <= idle;
        end

        calc:
        if(r0 == 2'd3) begin
            nst <= idle;
        end
        else begin
            nst <= calc;
        end

        default:
        nst <= idle;
        
        endcase
    end
end

INV_IP #(.IP_WIDTH(6)) mi0(.IN_1(wmom[5:0]), .IN_2(rpm[5:0]), .OUT_INV(mi0o));
mux4 #(.size(16)) mx0(.wi0({9'b0, rpx}), .wi1(wkid), .wi2(rs), .wi3(rs), .slc(r0), .wo0(wx0o));
mux4 #(.size(16)) mx1(.wi0({9'b0, rpx}), .wi1(wi0o), .wi2(rs), .wi3((rpx - rrx)), .slc(r0), .wo0(wx1o));
mux4 #(.size(16)) mx2(.wi0(wt0o), .wi1(wt0o), .wi2((wt0o - rpx - rqx)), .wi3((wt0o - rpy)), .slc(r0), .wo0(wx2o));
mt mt0(.wi0(wx0o), .wi1(wx1o), .wo0(wt0o));
md md0(.wi0(wx2o), .wi1(rpm), .wo0(wd0o));

assign wpeq = (rpx == rqx) && (rpy == rqy); // P equals to Q
assign wkid = ((wpeq)?(3*rxps + ra):(rqy - rpy));
assign wpy2 = {8'b0, rpy, 1'b0};
assign wmom = ((wpeq)?((wpy2 >= rpm)?(wpy2 - rpm):(wpy2)):((rpx > rqx)?((rqx-rpx) + rpm):(rqx - rpx)));
assign wi0o = {{10'b0}, mi0o};
assign wrrx = rrx + rpm;
assign wwry = wd0o + rpm;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 1'b0;
        out_Rx <= 6'b0;
        out_Ry <= 6'b0;
        r0 <= 0;
    end
    else if(cst == calc) begin
        if(r0 == 3) begin
            out_Rx <= (rrx[15])?(wrrx[5:0]):(rrx[5:0]);
            out_Ry <= (wd0o[15])?(wwry[5:0]):(wd0o[5:0]);
            out_valid <= 1'b1;
        end
        else if (r0 == 0) begin
            rxps <= wd0o;
        end
        else if (r0 == 1) begin
            rs <= wd0o;
        end
        else if(r0 == 2) begin
            rrx <= wd0o;
        end
        else ;
        r0 <= r0 + 1;
    end
    else begin
        out_valid <= 1'b0;
        out_Rx <= 6'b0;
        out_Ry <= 6'b0;
        r0 <= 0;
    end
end
endmodule

module mt(wi0, wi1, wo0);
input wire signed [15:0] wi0, wi1;
output wire signed [15:0] wo0;
assign wo0 = wi0 * wi1;
endmodule

module md(wi0, wi1, wo0);
input wire signed [15:0] wi0;
input wire signed [6:0] wi1;
output wire signed [15:0] wo0;
assign wo0 = wi0%wi1;
endmodule

module mux4(wi0, wi1, wi2, wi3, slc, wo0);
parameter size = 0;	
input wire signed [size-1:0] wi0, wi1, wi2, wi3;
input wire [1:0] slc;
output wire signed [size-1:0] wo0;
assign wo0 = (slc[1])?((slc[0])?(wi3):(wi2)):((slc[0])?(wi1):(wi0));
endmodule