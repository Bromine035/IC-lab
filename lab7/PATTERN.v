`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 10.0
	`define CYCLE_TIME_clk2 10.0
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 15.5
	`define CYCLE_TIME_clk2 18.3
`endif
`define PNUM 6000
`define INUM 20

module PATTERN #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Output Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	
	doraemon_id,
	size,
	iq_score,
	eq_score,
	size_weight,
	iq_weight,
	eq_weight,

    //Input Port
    ready,
	out_valid,
	out,
	
); 
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg	rst_n, clk1, clk2, in_valid;
output reg [4:0]doraemon_id;
output reg [7:0]size;
output reg [7:0]iq_score;
output reg [7:0]eq_score;
output reg [2:0]size_weight,iq_weight,eq_weight;

input 	ready, out_valid;
input  [7:0] out;

integer pnum = `PNUM;
integer inum = `INUM;
real CYCLE1 = `CYCLE_TIME_clk1;
real CYCLE2 = `CYCLE_TIME_clk2;
always #(CYCLE1/2.0) clk1 = ~clk1;
always #(CYCLE2/2.0) clk2 = ~clk2;
integer sd = 315;
integer i0, i1, i2, lat, n1, n2, fn, fs, fi, fe, fsw, fiw, few, fa;
reg [4:0] rn;
reg [7:0] rs, ri, re, ra;
reg [2:0] rsw, riw, rew;
reg ok150, ok0;
reg [3:0] n0;

initial begin
    rn = $random(sd);
    fn = $fopen("../00_TESTBED/data_n.txt", "r");
    fs = $fopen("../00_TESTBED/data_s.txt", "r");
    fi = $fopen("../00_TESTBED/data_i.txt", "r");
    fe = $fopen("../00_TESTBED/data_e.txt", "r");
    fsw = $fopen("../00_TESTBED/data_sw.txt", "r");
    fiw = $fopen("../00_TESTBED/data_iw.txt", "r");
    few = $fopen("../00_TESTBED/data_ew.txt", "r");
    force clk1 = 0;
    doraemon_id = 'bx;
    size = 'bx;
    iq_score = 'bx;
    eq_score = 'bx;
    size_weight = 'bx;
    iq_weight = 'bx;
    eq_weight = 'bx;
    in_valid = 1'b0;
    rst_n = 1'b1;
    #CYCLE1;
    rst_n = 1'b0;
    #CYCLE1;
    rst_n = 1'b1;
    if(out !== 'b0 || out_valid !== 1'b0 || ready !== 1'b0) begin
        $display("------ reset fail ------");
        $fclose(fn);
        $fclose(fs);
        $fclose(fi);
        $fclose(fe);
        $fclose(fsw);
        $fclose(fiw);
        $fclose(few);
        $finish;
    end
    #CYCLE1;
    release clk1;
    for(i0 = 0; i0 < 1; i0 = i0 + 1)begin
		@(negedge clk1);
	end
    for(i0 = 0; i0 < inum; i0 = i0 + 1) begin
        ok150 = 1;
        ok0 = 0;
        for(i1 = 0; i1 < pnum; i1 = i1 + 1) begin
            while(i1 > 4 && !ready) begin
                in_valid = 1'b0;
                doraemon_id = 'bx;
                size = 'bx;
                iq_score = 'bx;
                eq_score = 'bx;
                size_weight = 'bx;
                iq_weight = 'bx;
                eq_weight = 'bx;
                ok0 = 1;
                // if(lat > 100000) begin
                //     $display("------ over 100000 cycles ------");
                //     $fclose(fn);
                //     $fclose(fs);
                //     $fclose(fi);
                //     $fclose(fe);
                //     $fclose(fsw);
                //     $fclose(fiw);
                //     $fclose(few);
                //     $finish;
                // end
                // else begin
                //     lat = lat + 1;
                #(CYCLE1);
                // end
            end

            if(ok0) begin
                if(ok150) begin
                    if($random%'d4 == 0) begin
                        #(CYCLE1*150);
                        // $display("hi here");
                        ok150 = 0;
                    end
                    else begin
                        n0 = ($random%'d8);
                        // $display("check n0 - 1: %d", n0);
                        #(CYCLE1*n0);
                    end
                end
                else begin
                    n0 = ($random%'d8);
                    // $display("check n0 - 2: %d", n0);
                    #(CYCLE1*n0);
                end
                ok0 = 0;
            end
            // if(lat > 100000) begin
            //     $display("------ over 100000 cycles ------");
            //     $fclose(fn);
            //     $fclose(fs);
            //     $fclose(fi);
            //     $fclose(fe);
            //     $fclose(fsw);
            //     $fclose(fiw);
            //     $fclose(few);
            //     $finish;
            // end
            in_valid = 1'b1;
            $fscanf(fn, "%d\n", rn);
            $fscanf(fs, "%d\n", rs);
            $fscanf(fi, "%d\n", ri);
            $fscanf(fe, "%d\n", re);
            doraemon_id = rn;
            size = rs;
            iq_score = ri;
            eq_score = re;
            // $display("check n: %d, %d", rn, doraemon_id);
            if(i1 > 3) begin
                $fscanf(fsw, "%d\n", rsw);
                $fscanf(fiw, "%d\n", riw);
                $fscanf(few, "%d\n", rew);

                size_weight = rsw;
                iq_weight = riw;
                eq_weight = rew;
            end
            #(CYCLE1);
        end
        in_valid = 0;
        doraemon_id = 'bx;
        size = 'bx;
        iq_score = 'bx;
        eq_score = 'bx;
        size_weight = 'bx;
        iq_weight = 'bx;
        eq_weight = 'bx;
        #(CYCLE2*20);
        @(negedge clk1);
    end

    $fclose(fn);
    $fclose(fs);
    $fclose(fi);
    $fclose(fe);
    $fclose(fsw);
    $fclose(fiw);
    $fclose(few);
end

initial begin
    fa = $fopen("../00_TESTBED/data_ans.txt", "r");
    force clk2 = 0;
    #(CYCLE1*3);
    release clk2;
    for(i2 = 0; i2 < 1; i2 = i2 + 1)begin
		@(negedge clk2);
	end
    n1 = 0;
    n2 = 0;
    lat = 0;
    while(1'b1) begin
        if(n1 == 5996) begin
            if(out !== 'b0 || out_valid !== 1'b0 || ready !== 1'b0) begin
                $display("------ out shouuld be 0 ------");
                $fclose(fa);
                $finish;
            end
            else begin
                if(n2 == inum - 1) begin
                    $display("------ all pattern passed because Br35 is handsome ------");
                    $fclose(fa);
                    $finish;
                end
                else begin
                    n2 = n2 + 1;
                    n1 = 0;
                    lat = 0;
                end
            end
        end
        if(out_valid) begin
            $fscanf(fa, "%d %d\n", ra[7:5], ra[4:0]);
            if(out == ra) begin
                $display("------ pattern%d-%d passed, latency:%d ------", n2, n1, lat);
            end
            else begin
                $display("------ pattern%d-%d failed, latency:%d ------", n2, n1, lat);
                $display("ans: %d-%d, out: %d-%d", ra[7:5], ra[4:0], out[7:5], out[4:0]);
                $display("-------------------------------------------");
                $fclose(fa);
                $finish;
            end
            n1 = n1 + 1;
        end
        lat = lat + 1;
        if(lat > 100000) begin
            $display("------ over 100000 cycles ------");
            $fclose(fa);
            $finish;
        end
        @(negedge clk2);
        // #CYCLE2;
    end
end

endmodule 