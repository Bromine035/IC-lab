module test1();

wire signed [5:0] w0, w1;

assign w0 = -'d15;
assign w1 = 'd7;

initial begin
    #10
    $display("hello t1");
    $display("###: %d", w0%w1);
    $finish;

end

endmodule