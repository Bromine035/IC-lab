`include "CC.v"

module test1;

wire signed [8:0] w0, w1, w2, w3;
wire [8:0] w4, w5, w6, w7;

assign w0 = -8'd8;
assign w1 = 8'd3;
assign w2 = w0/w1;
assign w4 = w2;

CC CC0(
    .in_s0( 4'd8),
    .in_s1( 4'd11),
    .in_s2( 4'd8),
    .in_s3( 4'd0),
    .in_s4( 4'd5),
    .in_s5( 4'd14),
    .in_s6( 4'd7),
    .opt(   3'd2),
    .a(     2'd2),
    .b(     3'd6),
    .s_id0(),
    .s_id1(),
    .s_id2(),
    .s_id3(),
    .s_id4(),
    .s_id5(),
    .s_id6(),
    .out()
);

initial begin
    $display("hello world");
    $dumpfile("dump.vcd");
    $dumpvars;
    #10
    $display("###: %d, %d", w2, w4);
    $display("s0: %d, s1: %d, s2: %d, s3: %d, s4: %d, s5: %d, s6: %d, out: %d", CC0.s_id0, CC0.s_id1, CC0.s_id2, CC0.s_id3, CC0.s_id4, CC0.s_id5, CC0.s_id6, CC0.out);
    $finish;
end

endmodule

module tm1(o1, o2, o3);

output wire [3:0] o1;
output wire [3:0] o2;
output wire o3;

wire [3:0] w1;
wire signed [3:0] w2;
wire [3:0] w2_2;
wire w3;
wire [3:0] w4;

assign w1 = ~4'd10;
assign w2 = w1;
assign w2_2 = w2;
assign w3 = w1[3];

assign o1 = w1;
assign o2 = w2_2;
assign o3 = w3;

endmodule
