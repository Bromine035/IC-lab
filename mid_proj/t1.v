module test1();

wire [31:0] w0;

initial begin
    w0 = 'd315;
    #10;
    $display("###: %d", w0);
    w0 = 'd613;
    #10;
    $display("###: %d", w0);
    #10;
    $finish;
end

endmodule