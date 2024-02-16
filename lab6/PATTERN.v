//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : PATTERN.v
//   	Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL_TOP
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE_TOP
    `define CYCLE_TIME 60.0
`endif
`define PAT_NUM 100000

module PATTERN (
    // Output signals
    clk, rst_n, in_valid,
    in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a,
    // Input signals
    out_valid, out_Rx, out_Ry
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk, rst_n, in_valid;
output reg [5:0] in_Px, in_Py, in_Qx, in_Qy, in_prime, in_a;
input out_valid;
input [5:0] out_Rx, out_Ry;

integer f0, ltc, i0, i1;
reg [5:0] rpx, rpy, rqx, rqy, rpm, ra, ansx, ansy;
integer pnum = `PAT_NUM;
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

initial begin
    f0 = $fopen("../00_TESTBED/data_ec.txt", "r");
    force clk = 0;
    in_Px = 'bx;
    in_Py = 'bx;
    in_Qx = 'bx;
    in_Qy = 'bx;
    in_prime = 'bx;
    in_a = 'bx;
    in_valid = 'b0;
    rst_n = 1'b1;
    #CYCLE;
    rst_n = 1'b0;
    #CYCLE;
    rst_n = 1'b1;
    if(out_valid !== 1'b0 || out_Rx !== 'b0 || out_Ry !== 'b0) begin
        $display("------ reset fail ------");
        $fclose(f0);
        $finish;
    end
    #CYCLE;
    release clk;
    for(i0 = 0; i0 < 1; i0 = i0 + 1)begin
		@(negedge clk);
	end
    for(i1 = 0; i1 < pnum; i1 = i1+1) begin
        $fscanf(f0, "%d %d %d %d %d %d %d %d\n", rpx, rpy, rqx, rqy, rpm, ra, ansx, ansy);
        in_valid = 1'b1;
        in_Px = rpx;
        in_Py = rpy;
        in_Qx = rqx;
        in_Qy = rqy;
        in_prime = rpm;
        in_a = ra;
        #(CYCLE/2.0);
        if(out_valid !== 1'b0 || out_Rx !== 'b0 || out_Ry !== 'b0) begin
            $display("------ out should be 0 ------");
            $fclose(f0);
            $finish;
        end
        #(CYCLE/2.0);
        if(out_valid !== 1'b0 || out_Rx !== 'b0 || out_Ry !== 'b0) begin
            $display("------ out should be 0 ------");
            $fclose(f0);
            $finish;
        end
        in_valid = 1'b0;
        in_Px = 'bx;
        in_Py = 'bx;
        in_Qx = 'bx;
        in_Qy = 'bx;
        in_prime = 'bx;
        in_a = 'bx;
        ltc = 0;
        while(out_valid === 1'b0) begin
            if(ltc == 1000) begin
                $display("------ over 1000 cycles ------");
                $fclose(f0);
                $finish;
            end
            else begin
                ltc = ltc + 1;
                #CYCLE;
            end
        end

        if(out_Rx == ansx && out_Ry == ansy) begin
            $display("------ pattern%d passed, latency:%d ------", i1, ltc);
        end
        else begin
            $display("------ pattern%d failed, latency:%d ------", i1, ltc);
            $display("px:%d, py:%d, qx:%d, qy:%d, prime:%d, a:%d, rx:%d, ry:%d, out_Rx:%d, out_Ry:%d", 
                rpx, rpy, rqx, rqy, rpm, ra, ansx, ansy, out_Rx, out_Ry);
            $display("-------------------------------------------");
            $fclose(f0);
            $finish;
        end
        #CYCLE;
        if(out_valid !== 1'b0 || out_Rx !== 'b0 || out_Ry !== 'b0) begin
            $display("------ out should be 0 ------");
            $fclose(f0);
            $finish;
        end
        #(CYCLE*2.0);

        @(negedge clk);
    end

    $display("------ all pattern passed because Br35 is handsome ------");
    $fclose(f0);
    $finish;
end

endmodule