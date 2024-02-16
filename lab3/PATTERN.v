`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif


module PATTERN(
    // Output Signals
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    // Input Signals
    out_valid,
    out
);


/* Input for design */
output reg       clk, rst_n;
output reg       in_valid;
output reg [1:0] init;
output reg [1:0] in0, in1, in2, in3; 


/* Output for pattern */
input            out_valid;
input      [1:0] out; 

integer sd = 315;
integer pnum = 300;
integer i0, i1, i2, i3, i4, i5, i6, i7, now, latency, total_latency;
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;
reg [2:0] ne;
reg [1:0] etr;
reg [1:0] pe [3:0];
reg [1:0] rm [3:0][63:0];
// reg [1:0] act [62:0];
// reg s7ok;

initial begin
    ne = $random(sd);
    rstt;
    for(i3 = 0; i3 < pnum; i3 = i3+1) begin
        // s7ok = 1'b0;
        gmap;
        getr;
        now = etr;
        for(i7 = 0; i7 < 6; i7 = i7+1) begin
            if(out_valid === 1'b0 && out !== 'b0) begin
                $display("SPEC 4 IS FAIL!"); // ???????
                $finish;
            end
            else if(out_valid !== 1'b0)begin
                $display("SPEC 7 IS FAIL!");
                $finish;
            end
            else ;
            @(posedge clk or negedge clk);
        end
        iptt;
        wovt;
        optt;
        // if(s7ok) begin
        //     $display("SPEC 7 IS FAIL!");
        //     $finish;
        // end
        // else rmap;
        
        @(negedge clk);
    end
    // $display("-------------------------------------------------");
    // $display("-- All pattern passed because Br35 is handsome --");
    // $display("-------------------------------------------------");
    $finish;
end

task gmap; begin // generate map
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

task getr; begin // generate entry
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

task rmap; begin // run map
// now = etr;
// for(i0 = 0; i0 < 63; i0 = i0 + 1) begin
    if(out == 2'd0) begin // forward
        if(rm[now][i4+1] == 2'd1) begin // lower
            $display("SPEC 8-2 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now][i4+1] == 2'd3) begin // train
            $display("SPEC 8-4 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else ;
    end
    else if(out == 2'd1) begin // right
        if(now == 3) begin // outside
            $display("SPEC 8-1 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now+1][i4+1] == 2'd1) begin // lower
            $display("SPEC 8-2 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now+1][i4+1] == 2'd2) begin // higher
            $display("SPEC 8-3 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now+1][i4+1] == 2'd3) begin // train
            $display("SPEC 8-4 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else now = now + 1;
    end
    else if(out == 2'd2) begin // left
        if(now == 0) begin // outside
            $display("SPEC 8-1 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now-1][i4+1] == 2'd1) begin // lower
            $display("SPEC 8-2 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now-1][i4+1] == 2'd2) begin // higher
            $display("SPEC 8-3 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now-1][i4+1] == 2'd3) begin // train
            $display("SPEC 8-4 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else now = now - 1;
    end
    else if(out == 2'd3) begin // jump
        if(rm[now][i4+1] == 2'd2) begin // higher
            $display("SPEC 8-3 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now][i4+1] == 2'd3) begin // train
            $display("SPEC 8-4 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
        else if(rm[now][i4] == 2'd1) begin // lower jump
            $display("SPEC 8-5 IS FAIL!");
            // $display("col: %d, map: %d, act: %d", i0, rm[now][i0+1], act[i0]);
            $finish;
        end
    end
    else begin
        $display("SPEC 7 IS FAIL!");
        $finish;
    end
// end
end
endtask

task iptt; begin
	for(i5 = 0; i5 < 64; i5 = i5 + 1)begin
		in_valid = 1'b1;
		if(i5 === 0)begin
			init = etr;
		end
		else begin	
			init= 'bx;
		end
        in0 = rm[0][i5];
        in1 = rm[1][i5];
        in2 = rm[2][i5];
        in3 = rm[3][i5];
        if(out_valid === 1'b0 && out !== 'b0) begin
            $display("SPEC 4 IS FAIL!");
            $finish;
        end
        else if(out_valid === 1'b1) begin
            $display("SPEC 5 IS FAIL!");
            $finish;
        end
        else ;
	    @(negedge clk);
	end
    if(out_valid === 1'b0 && out !== 'b0) begin
        $display("SPEC 4 IS FAIL!");
        $finish;
    end
    else if(out_valid === 1'b1) begin
        $display("SPEC 5 IS FAIL!");
        $finish;
    end
    else ;
    in_valid = 1'b0;
    in0 = 'bx; in1 = 'bx; in2 = 'bx; in3 = 'bx;
end
endtask

task rstt; begin
    rst_n = 'b1;
    in_valid = 'b0;
    init = 'bx; in0 = 'bx; in1 = 'bx; in2 = 'bx; in3 = 'bx;
    total_latency = 0;
    force clk = 0;
    #CYCLE; rst_n = 0; 
    #CYCLE; rst_n = 1;
    if(out_valid !== 1'b0 || out !=='b0) begin //out!==0
        $display("SPEC 3 IS FAIL!");
        $finish;
    end
	#CYCLE; release clk;
    for(i6 = 0; i6 < 1; i6 = i6 + 1)begin
    	// if(out_valid !== 1'b0 || out !=='b0) begin //out!==0
    	//     $display("SPEC 3 IS FAIL!"); // ?????????
    	//     $finish;
    	// end
		@(negedge clk);
	end
end
endtask

task wovt; begin
    latency = 0;
    while(out_valid !== 1'b1) begin
        latency = latency + 1;
        if(out !== 'b0) begin
            $display("SPEC 4 IS FAIL!");
            $finish;
        end
        else if(latency == 3000) begin
            $display("SPEC 6 IS FAIL!");
            $finish;
        end
        else ;
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

task optt; begin
for(i4 = 0; i4 < 63; i4 = i4+1) begin
    if(out_valid === 1'b0 && out !== 'b0) begin
        $display("SPEC 4 IS FAIL!"); // ???????
        $finish;
    end
    else if (out_valid !== 1'b1) begin
    	// s7ok = 1'b1;
        // $display("here1");
        $display("SPEC 7 IS FAIL!");
        $finish;
    end
    else rmap;
    @(negedge clk);
end
if(out_valid === 1'b0 && out !== 'b0) begin
    $display("SPEC 4 IS FAIL!"); // ???????
    $finish;
end
else if(out_valid !== 1'b0) begin
    // s7ok = 1'b1;
    // $display("here2");
    $display("SPEC 7 IS FAIL!");
    $finish;
end
else ;
end
endtask

endmodule

