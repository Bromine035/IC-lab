//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//      (C) Copyright Optimum Application-Specific Integrated System Laboratory
//      All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : PATTERN_IP.v
//   	Module Name : PATTERN_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
`ifdef RTL
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE
    `define CYCLE_TIME 60.0
`endif
`define PAT_NUM 100000

module PATTERN_IP #(parameter IP_WIDTH = 7) (
    // Output signals
    IN_1, IN_2,
    // Input signals
    OUT_INV
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg [IP_WIDTH-1:0] IN_1, IN_2;
input  [IP_WIDTH-1:0] OUT_INV;

integer i0, f0;
reg [IP_WIDTH-1:0] ans;
reg clk;
integer patnum = `PAT_NUM;
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;


INV_IP #(.IP_WIDTH(IP_WIDTH)) mi0(.IN_1(IN_1), .IN_2(IN_2), .OUT_INV(OUT_INV));

initial begin
    f0 = $fopen("../00_TESTBED/data_inv.txt", "r");
    force clk = 0;
    IN_1 = 0;
    IN_2 = 0;
    release clk;

    for(i0 = 0; i0 < patnum; i0 = i0+1) begin
        if(i0 != 0) begin
            if(OUT_INV == ans) begin
                $display("------ pass pattern%d ------", i0-1);
            end
            else begin
                $display("------ fail pattern%d ------", i0-1);
                $display("in1: %d, in2: %d, ans: %d, out: %d", IN_1, IN_2, ans, OUT_INV);
                $display("----------------------------");
                $fclose(f0);
                $finish;
            end
        end
        $fscanf(f0, "%d %d %d\n", IN_1, IN_2, ans);
        @(negedge clk);
    end
    $display("------ all pattern passed because Br35 is handsome ------");
    $fclose(f0);
    $finish;
end


endmodule