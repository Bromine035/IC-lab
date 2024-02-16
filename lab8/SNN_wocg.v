module SNN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	img,
	ker,
	weight,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       parameter & integer declaration        //
//==============================================//

parameter idle = 4'd0;
parameter indt = 4'd1;
parameter con0 = 4'd2;
parameter qua0 = 4'd3;
parameter mxp0 = 4'd4;
parameter den0 = 4'd5;
parameter qud0 = 4'd6;
parameter con1 = 4'd7;
parameter qua1 = 4'd8;
parameter mxp1 = 4'd9;
parameter den1 = 4'd10;
parameter qud1 = 4'd11;
parameter lds0 = 4'd12;
parameter act0 = 4'd13;
parameter oudt = 4'd14;
integer i0, i1;
genvar i2, i3;

//==============================================//
//           reg & wire declaration             //
//==============================================//

reg [3:0] cst, nst;
reg [7:0] r0;
reg [7:0] rimg0 [5:0][5:0];
reg [7:0] rimg1 [5:0][5:0];
reg [7:0] rker [2:0][2:0];
reg [7:0] rwet [1:0][1:0];
reg [7:0] rv0 [3:0];

//==============================================//
//                  design                      //
//==============================================//

conv mcon(.clk(clk), .rst_n(rst_n), .img(), .ker(), .wout());
quat mqua(.clk(clk), .rst_n(rst_n), .map(), .wout());
mxpl mmxp(.clk(clk), .rst_n(rst_n), .map(), .wout());
dens mden(.clk(clk), .rst_n(rst_n), .map(), .wet(), .wout());
quad mqud(.clk(clk), .rst_n(rst_n), .vec(), .wout());
ldis mlds(.clk(clk), .rst_n(rst_n), .vec0(), .vec1(), .rout());
acti mact(.clk(clk), .rst_n(rst_n), .rin(mlds.rout), .rout());
generate
    for(i2 = 0; i2 < 6; i2 = i2 + 1) begin
        for(i3 = 0; i3 < 6; i3 = i3 + 1) begin
            assign mcon.img[i2][i3] = (cst > qud0)?(rimg1[i2][i3]):(rimg0[i2][i3]);
        end
    end
    for(i2 = 0; i2 < 4; i2 = i2 + 1) begin
        for(i3 = 0; i3 < 4; i3 = i3 + 1) begin
            assign mqua.map[i2][i3] = mcon.wout[i2][i3];
            assign mmxp.map[i2][i3] = mqua.wout[i2][i3];
        end
        assign mqud.vec[i2] = mden.wout[i2];
        assign mlds.vec0[i2] = rv0[i2];
        assign mlds.vec1[i2] = mqud.wout[i2];
    end
    for(i2 = 0; i2 < 3; i2 = i2 + 1) begin
        for(i3 = 0; i3 < 3; i3 = i3 + 1) begin
            assign mcon.ker[i2][i3] = rker[i2][i3];
        end
    end
    for(i2 = 0; i2 < 2; i2 = i2 + 1) begin
        for(i3 = 0; i3 < 2; i3 = i3 + 1) begin
            assign mden.map[i2][i3] = mmxp.wout[i2][i3];
            assign mden.wet[i2][i3] = rwet[i2][i3];
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle;
        r0 <= 8'b0;
    end
    else begin
        cst <= nst;
        if(cst == indt || nst == indt) begin
            r0 <= (r0 == 8'd71)?(8'b0):(r0 + 8'd1);
        end
        else if(cst == con0 || cst == qua0 || cst == con1 || cst == qua1) begin
            r0 <= (r0 == 8'd15)?(8'd0):(r0 + 8'd1);
        end
        else if(cst == mxp0 || cst == den0 || cst == qud0 || cst == mxp1 || cst == den1 || cst == qud1) begin
            r0 <= (r0 == 8'd3)?(8'd0):(r0 + 8'd1);
        end
        else begin
            r0 <= r0;
        end
    end
end

always @(*) begin
    if(!rst_n) begin
        nst <= idle;
    end
    else begin
        case(cst)
        idle:
        nst <= (in_valid)?(indt):(idle);
        indt:
        nst <= (r0 == 8'd71)?(con0):(indt);
        con0:
        nst <= (r0 == 8'd15)?(qua0):(con0);
        qua0:
        nst <= (r0 == 8'd15)?(mxp0):(qua0);
        mxp0:
        nst <= (r0 == 8'd3)?(den0):(mxp0);
        den0:
        nst <= (r0 == 8'd3)?(qud0):(den0);
        qud0:
        nst <= (r0 == 8'd3)?(con1):(qud0);
        con1:
        nst <= (r0 == 8'd15)?(qua1):(con1);
        qua1:
        nst <= (r0 == 8'd15)?(mxp1):(qua1);
        mxp1:
        nst <= (r0 == 8'd3)?(den1):(mxp1);
        den1:
        nst <= (r0 == 8'd3)?(qud1):(den1);
        qud1:
        nst <= (r0 == 8'd3)?(lds0):(qud1);
        lds0:
        nst <= act0;
        act0:
        nst <= oudt;
        oudt:
        nst <= idle;

        default:
        nst <= idle;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i0 = 0; i0 < 6; i0 = i0 + 1) begin
            for(i1 = 0; i1 < 6; i1 = i1 + 1) begin
                rimg0[i0][i1] <= 8'b0;
                rimg1[i0][i1] <= 8'b0;
            end
        end
        for(i0 = 0; i0 < 3; i0 = i0 + 1) begin
            for(i1 = 0; i1 < 3; i1 = i1 + 1) begin
                rker[i0][i1] <= 8'b0;
            end
        end
        for(i0 = 0; i0 < 2; i0 = i0 + 1) begin
            for(i1 = 0; i1 < 2; i1 = i1 + 1) begin
                rwet[i0][i1] <= 8'b0;
            end
        end
    end
    else if(cst == indt || nst == indt) begin
        rimg0[r0/3'd6][r0%3'd6] <= (r0 > 8'd35)?(rimg0[r0/3'd6][r0%3'd6]):(img);
        rimg1[(r0 - 8'd36)/3'd6][r0%3'd6] <= (r0 > 8'd35)?(img):(rimg1[(r0 - 8'd36)/3'd6][r0%3'd6]);
        rker[r0/3'd3][r0%3'd3] <= (r0 > 8'd8)?(rker[r0/3'd3][r0%3'd3]):(ker);
        rwet[r0/3'd2][r0%3'd2] <= (r0 > 8'd3)?(rwet[r0/3'd2][r0%3'd2]):(weight);
    end
    else begin
        rimg0[0][0] <= rimg0[0][0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rv0[0] <= 8'b0;
        rv0[1] <= 8'b0;
        rv0[2] <= 8'b0;
        rv0[3] <= 8'b0;
    end
    else if(cst == con1 && r0 == 8'b0) begin
        rv0[0] <= mqud.wout[0];
        rv0[1] <= mqud.wout[1];
        rv0[2] <= mqud.wout[2];
        rv0[3] <= mqud.wout[3];
    end
    else begin
        rv0[0] <= rv0[0];
        rv0[1] <= rv0[1];
        rv0[2] <= rv0[2];
        rv0[3] <= rv0[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_data <= 10'b0;
        out_valid <= 1'b0;
    end
    else if(cst == oudt) begin
        out_data <= mact.rout;
        out_valid <= 1'b1;
    end
    else begin
        out_data <= 10'b0;
        out_valid <= 1'b0;
    end
end
endmodule

module conv(clk, rst_n, img, ker, wout); // 16 cycles
input wire clk, rst_n;
input wire [7:0] img [5:0][5:0];
input wire [7:0] ker [2:0][2:0];
output wire [19:0] wout [3:0][3:0];
reg [1:0] r0, r1;
reg [19:0] rout [3:0][3:0];
wire [15:0] wp [2:0][2:0];
integer i0, i1;
genvar i2, i3;

generate
for(i2 = 0; i2 < 3; i2 = i2 + 1) begin
    for(i3 = 0; i3 < 3; i3 = i3 + 1) begin
        assign wp[i2][i3] = img[r1 + i2][r0 + i3] * ker[i2][i3];
    end
end
for(i2 = 0; i2 < 4; i2 = i2 + 1) begin
    for(i3 = 0; i3 < 4; i3 = i3 + 1) begin
        assign wout[i2][i3] = rout[i2][i3];
    end
end
endgenerate
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for (i0 = 0; i0 < 4; i0 = i0 + 1) begin
            for (i1 = 0; i1 < 4; i1 = i1 + 1) begin
                rout[i0][i1] <= 'b0;
            end
        end
        r0 <= 2'b0;
        r1 <= 2'b0;
    end
    else begin
        r0 <= (r0 == 2'd3)?(2'b0):(r0 + 2'd1);
        r1 <= (r1 == 2'd3 && r0 == 2'd3)?(2'b0):((r0 == 2'd3)?(r1 + 2'd1):(r1));
        rout[r1][r0] <= wp[0][0] + wp[0][1] + wp[0][2] + wp[1][0] + wp[1][1] + wp[1][2] + wp[2][0] + wp[2][1] + wp[2][2];
    end
end
endmodule

module quat(clk, rst_n, map, wout); // 16 cycles
input wire clk, rst_n;
input wire [19:0] map [3:0][3:0];
output wire [7:0] wout [3:0][3:0];
reg [1:0] r0, r1;
reg [7:0] rout [3:0][3:0];
integer i0, i1;
genvar i2, i3;

generate
for(i2 = 0; i2 < 4; i2 = i2 + 1) begin
    for(i3 = 0; i3 < 4; i3 = i3 + 1) begin
        assign wout[i2][i3] = rout[i2][i3];
    end
end
endgenerate
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i0 = 0; i0 < 4; i0 = i0 + 1) begin
            for(i1 = 0; i1 < 4; i1 = i1 + 1) begin
                rout[i0][i1] <= 8'b0;
            end
        end
        r0 <= 2'b0;
        r1 <= 2'b0;
    end
    else begin
        r0 <= (r0 == 2'd3)?(2'b0):(r0 + 2'd1);
        r1 <= (r1 == 2'd3 && r0 == 2'd3)?(2'b0):((r0 == 2'd3)?(r1 + 2'd1):(r1));
        rout[r1][r0] <= map[r1][r0]/20'd2295;
    end
end
endmodule

module mxpl(clk, rst_n, map, wout); // 4 cycles
input wire clk, rst_n;
input wire [7:0] map [3:0][3:0];
output wire [7:0] wout [1:0][1:0];
reg r0, r1;
reg [7:0] rout [1:0][1:0];
wire [1:0] wm0, wm1, wcr0, wcr1, wcc0, wcc1;
wire [3:0] wm2;

assign wout[0][0] = rout[0][0];
assign wout[0][1] = rout[0][1];
assign wout[1][0] = rout[1][0];
assign wout[1][1] = rout[1][1];
assign wcr0 = ((r1)?(2'd2):(2'd0)); // choose row
assign wcr1 = ((r1)?(2'd3):(2'd1)); 
assign wcc0 = ((r0)?(2'd2):(2'd0)); // choose column
assign wcc1 = ((r0)?(2'd3):(2'd1));
assign wm0  = (map[wcr0][wcc1] > map[wcr0][wcc0])?(wcc1):(wcc0);
assign wm1  = (map[wcr1][wcc1] > map[wcr1][wcc0])?(wcc1):(wcc0);
assign wm2  = (map[wcr1][wm1]  > map[wcr0][wm0] )?({wcr1, wm1}):({wcr0, wm0});
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r0 <= 1'b0;
        r1 <= 1'b0;
        rout[0][0] <= 8'b0;
        rout[0][1] <= 8'b0;
        rout[1][0] <= 8'b0;
        rout[1][1] <= 8'b0;
    end
    else begin
        r0 <= ~r0;
        r1 <= (r0 == 1'b1)?(~r1):(r1);
        rout[r1][r0] <= map[wm2[3:2]][wm2[1:0]];
    end
end
endmodule

module dens(clk, rst_n, map, wet, wout); // 4 cycles
input wire clk, rst_n;
input wire [7:0] map [1:0][1:0];
input wire [7:0] wet [1:0][1:0];
output wire [16:0] wout [3:0];
reg [16:0] rout [3:0];
reg r0, r1;

assign wout[0] = rout[0];
assign wout[1] = rout[1];
assign wout[2] = rout[2];
assign wout[3] = rout[3];
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r0 <= 1'b0;
        r1 <= 1'b0;
        rout[0] <= 8'b0;
        rout[1] <= 8'b0;
        rout[2] <= 8'b0;
        rout[3] <= 8'b0;
    end
    else begin
        r0 <= ~r0;
        r1 <= (r0 == 1'b1)?(~r1):(r1);
        rout[{r1, r0}] <= map[r1][0]*wet[0][r0] + map[r1][1]*wet[1][r0];
    end
end
endmodule

module quad(clk, rst_n, vec, wout); // quantization of dense // 4 cycles
input wire clk, rst_n;
input wire [16:0] vec [3:0];
output wire [7:0] wout [3:0];
reg [1:0] r0;
reg [7:0] rout [3:0];

assign wout[0] = rout[0];
assign wout[1] = rout[1];
assign wout[2] = rout[2];
assign wout[3] = rout[3];
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r0 <= 1'b0;
        rout[0] <= 8'b0;
        rout[1] <= 8'b0;
        rout[2] <= 8'b0;
        rout[3] <= 8'b0;
    end
    else begin
        r0 <= (r0 == 2'd3)?(2'd0):(r0 + 2'd1);
        rout[r0] <= vec[r0]/17'd510;
    end
end
endmodule

module ldis(clk, rst_n, vec0, vec1, rout);
input wire clk, rst_n;
input wire [7:0] vec0 [3:0];
input wire [7:0] vec1 [3:0];
output reg [9:0] rout;
wire [7:0] was [3:0]; // absolute value subtract

assign was[0] = (vec1[0] > vec0[0])?(vec1[0] - vec0[0]):(vec0[0] - vec1[0]);
assign was[1] = (vec1[1] > vec0[1])?(vec1[1] - vec0[1]):(vec0[1] - vec1[1]);
assign was[2] = (vec1[2] > vec0[2])?(vec1[2] - vec0[2]):(vec0[2] - vec1[2]);
assign was[3] = (vec1[3] > vec0[3])?(vec1[3] - vec0[3]):(vec0[3] - vec1[3]);
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rout <= 10'b0;
    end
    else begin
        rout <= was[0] + was[1] + was[2] + was[3];
    end
end
endmodule

module acti(clk, rst_n, rin, rout);
input wire clk, rst_n;
input wire [9:0] rin;
output reg [9:0] rout;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rout <= 10'b0;
    end
    else begin
        rout <= (rin < 10'd16)?(10'b0):(rin);
    end
end
endmodule

