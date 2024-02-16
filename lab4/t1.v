module test();

integer dp, fu;
real n0, n1;
reg [31:0] r0;
wire signed [31:0] w0;
wire [7:0] w1;
wire signed [7:0] w2;

assign w0 = -32'd150;
assign w1 = w0[7:0];
assign w2 = w1 - 8'd127;

// DW_fp_mult mm0(.a(wm0a), .b(wm0b), .rnd(wrnd), .z(), .status());
// DW_fp_mult mm1(.a(wm1a), .b(wm1b), .rnd(wrnd), .z(), .status());
// DW_fp_mult mm2(.a(wm2a), .b(wm2b), .rnd(wrnd), .z(), .status());

// DW_fp_sum3  ms(.a(mm0.z), .b(mm1.z), .c(mm2.z), .rnd(wrnd), .z(), .status());

initial begin
    // fu = $fopen("t1.txt", "r");
    $display("hello world");
    // repeat(5) begin
    // dp = $fscanf(fu, "%f.10\n", n0);
    // r0 = $shortrealtobits(n0);
    // n1 = $bitstoshortreal(r0);
    // $display("### %f, %b, %f", n0, r0, n1);
    // end
    #10;
    $display("###: %d, %d", w1, w2);
    $finish;
end
endmodule