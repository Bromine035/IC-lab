module test1;
wire [3:0] w0 [3:0];
wire [3:0] w1 [3:0];
wire [3:0] w2;
wire w3;

assign w0[0] = 4'd3;
assign w0[1] = 4'd5;
assign w0[2] = 4'd7;
assign w0[3] = 4'd9;

tm tm0(.wi(w0), .wo());
assign w1 = tm0.wo;
assign w2 = tm0.wo[2];
assign w3 = tm0.wo[1][3];

initial begin
    $display("hello world");
    $dumpfile("dump.vcd");
    $dumpvars;
    #10
    $display("### w1: %d, w2: %d, w3: %d", w1, w2, w3);
    $finish;
end
endmodule

module tm(wi, wo);
input wire [3:0] wi [3:0];
output wire [3:0] wo [3:0];

genvar i0;
generate
    for(i0 = 0; i0 < 4; i0 = i0+1) begin
        assign wo[i0] = wi[i0]+4'd2;
    end
endgenerate
endmodule