module test();
// reg [3:0] r0;
// integer seed = 315;

integer sd = 315;
integer i0, i1, i2;
reg [2:0] ne;
reg [1:0] etr;
reg [1:0] pe [3:0];
reg [1:0] rm [3:0][63:0];
// reg [1:0] rm1 [63:0];
// reg [1:0] rm2 [63:0];
// reg [1:0] rm3 [63:0];
// wire [2:0] w0;
// assign w0 = ne + 3'd1;

initial begin
    ne = $random(sd);
    // pe[0] = 2'b0; pe[1] = 2'b0; pe[2] = 2'b0; pe[3] = 2'b0;
    $display("hello world");
    $dumpfile("dump.vcd");
    $dumpvars;

    repeat(10) begin
    gmap;
    getr;
    $write("road 0: ");
    for(i2 = 0; i2 < 64; i2 = i2+1) begin
        $write(" %d", rm[0][i2]);
    end
    $write("\nroad 1: ");
    for(i2 = 0; i2 < 64; i2 = i2+1) begin
        $write(" %d", rm[1][i2]);
    end
    $write("\nroad 2: ");
    for(i2 = 0; i2 < 64; i2 = i2+1) begin
        $write(" %d", rm[2][i2]);
    end
    $write("\nroad 3: ");
    for(i2 = 0; i2 < 64; i2 = i2+1) begin
        $write(" %d", rm[3][i2]);
    end
    $write("\n");
    $display("### entry: %d", etr);
    $display("check ne: %d, check pe: %d %d %d %d\n", ne, pe[0], pe[1], pe[2], pe[3]);
    end
    // r0 <= $random(seed);
    // #10;
    // r0 <= $random%4'd15;
    // $display("##: %d", r0);
    // #10;
    // r0 <= $random%4'd15;
    // $display("##: %d", r0);
    // #10;
    // r0 <= $random%4'd15;
    // $display("##: %d", r0);
    // #10;
    // r0 <= $random%4'd15;
    // $display("##: %d", r0);
    // #10;
    // r0 <= $random%4'd15;
    // $display("##: %d", r0);
    $finish;
end

task gmap; begin
for(i1 = 0; i1 < 64; i1 = i1+1) begin
    if(i1%'d8 == 0) begin
        rm[0][i1] = ($random%'d2)?2'd3:2'd0;
        rm[1][i1] = ($random%'d2)?2'd3:2'd0;
        rm[2][i1] = ($random%'d2)?2'd3:2'd0;
        rm[3][i1] = ($random%'d2)?2'd3:2'd0;
        if(rm[0][i1] + rm[1][i1] + rm[2][i1] + rm[3][i1] == 0) begin
            case($random%'d4)
            0: rm[0][i1] = 2'd3;
            1: rm[1][i1] = 2'd3;
            2: rm[2][i1] = 2'd3;
            3: rm[3][i1] = 2'd3;
            default: rm[0][i1] = 2'd3;
            endcase
        end
        else if(rm[0][i1] + rm[1][i1] + rm[2][i1] + rm[3][i1] == 12) begin
            case($random%'d4)
            0: rm[0][i1] = 2'd0;
            1: rm[1][i1] = 2'd0;
            2: rm[2][i1] = 2'd0;
            3: rm[3][i1] = 2'd0;
            default: rm[0][i1] = 2'd0;
            endcase
        end
        else ;
        rm[0][i1+1] = rm[0][i1]; rm[0][i1+3] = rm[0][i1];
        rm[0][i1+2] = (!rm[0][i1])?($random%'d3):rm[0][i1];
        rm[1][i1+1] = rm[1][i1]; rm[1][i1+3] = rm[1][i1];
        rm[1][i1+2] = (!rm[1][i1])?($random%'d3):rm[1][i1];
        rm[2][i1+1] = rm[2][i1]; rm[2][i1+3] = rm[2][i1];
        rm[2][i1+2] = (!rm[2][i1])?($random%'d3):rm[2][i1];
        rm[3][i1+1] = rm[3][i1]; rm[3][i1+3] = rm[3][i1];
        rm[3][i1+2] = (!rm[3][i1])?($random%'d3):rm[3][i1];
    end
    else if(i1%'d8 == 4 || i1%'d8 == 6) begin
        rm[0][i1] = $random%'d3;
        rm[1][i1] = $random%'d3;
        rm[2][i1] = $random%'d3;
        rm[3][i1] = $random%'d3;
    end
    else if(i1%'d8 == 5 || i1%'d8 == 7) begin
        rm[0][i1] = 2'b0;
        rm[1][i1] = 2'b0;
        rm[2][i1] = 2'b0;
        rm[3][i1] = 2'b0;
    end
    else ;
end
end
endtask

task getr; begin
ne = 0;
for(i2 = 0; i2 < 4; i2 = i2+1) begin
    if(!rm[i2][0]) begin
        pe[ne] = i2;
        ne = ne + 1;
    end
    else ;
end
etr = pe[$random%ne];
end
endtask

endmodule

