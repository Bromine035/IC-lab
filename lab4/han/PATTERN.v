`ifdef RTL
	`include "NN.v"  
	`define CYCLE_TIME 50.0
`endif
`ifdef GATE
	`include "NN_SYN.v"
	`define CYCLE_TIME 50.0
`endif

module PATTERN(
	// Output signals
	clk,
	rst_n,
	in_valid,
	data_x,
	data_h,
	weight_u,
	weight_w,
	weight_v,
	// Input signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
	parameter inst_sig_width = 23;
	parameter inst_exp_width = 8;
	parameter inst_ieee_compliance = 0;
	parameter PATNUM = 3000;
	real ERR_VAL = 0.0005;
    integer total_cycles, cycles ,patcount,i,a, i0, i1;
    integer fy,fw,fv,fu,fx,fh;
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
	output reg clk,rst_n,in_valid;
	output reg [inst_sig_width + inst_exp_width: 0] weight_u,weight_w,weight_v,data_x,data_h;
	input	out_valid;
	input	[inst_sig_width + inst_exp_width: 0] out;
	
//================================================================
// parameters & integer
//================================================================
real tmp;
reg [inst_sig_width+inst_exp_width:0] u [8:0];
reg [inst_sig_width+inst_exp_width:0] v [8:0];
reg [inst_sig_width+inst_exp_width:0] w [8:0];
reg [inst_sig_width+inst_exp_width:0] x [8:0];
reg [inst_sig_width+inst_exp_width:0] h [2:0];
real golden_out [8:0];
//================================================================
//  clock
//================================================================
always  #(`CYCLE_TIME/2.0)  clk = ~clk ;
initial clk = 0 ;
//================================================================
// PATTERN
//================================================================
initial begin
	// f_out = $fopen("../00_TESTBED/y.txt", "r");
	// f_w = $fopen("../00_TESTBED/w.txt", "r");
	// f_v = $fopen("../00_TESTBED/v.txt", "r");
	// f_u = $fopen("../00_TESTBED/u.txt", "r");
	// f_x = $fopen("../00_TESTBED/x.txt", "r");
	// f_h = $fopen("../00_TESTBED/h.txt", "r");
	fu = $fopen("../00_TESTBED/lab04_weight_u.txt", "r");
	fw = $fopen("../00_TESTBED/lab04_weight_w.txt", "r");
	fv = $fopen("../00_TESTBED/lab04_weight_v.txt", "r");
	fx = $fopen("../00_TESTBED/lab04_data_x.txt", "r");
	fh = $fopen("../00_TESTBED/lab04_data_h.txt", "r");
	fy = $fopen("../00_TESTBED/lab04_data_y.txt", "r");
	// reset output signals
	rst_n = 1;
	in_valid = 0;	
	data_x = 32'bx;
	data_h = 32'bx;
	weight_u = 32'bx ;
	weight_v = 32'bx ;
	weight_w = 32'bx ;
	// rest
	force clk = 0;
	total_cycles = 0;
	reset_task;
	//pattern body
	@(negedge clk);
	for( patcount=0 ; patcount<PATNUM ; patcount=patcount+1 ) begin
		input_task;
		wait_outvalid_task;
		check_ans;
		// $display("Pass Pattern No %d", patcount);
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end

task input_task ; begin
	for( i=0 ; i<9 ; i=i+1 )begin
		a = $fscanf(fy, "%f\n", golden_out[i]);
		// $display("check y: %.50f", golden_out[i]);
	end
	for( i=0 ; i<9 ; i=i+1 ) begin
		a = $fscanf(fw, "%f\n", tmp);
		w[i] = $shortrealtobits(tmp);
		// $display("check w: %.50f", tmp);
	end
	for( i=0 ; i<9 ; i=i+1 )begin
		a = $fscanf(fv, "%f\n", tmp);
		v[i] = $shortrealtobits(tmp);
		// $display("check v: %.50f", tmp);
	end
	for( i=0 ; i<9 ; i=i+1 )begin
		a = $fscanf(fu, "%f\n", tmp);
		u[i] = $shortrealtobits(tmp);
		// $display("check u: %.50f", tmp);
	end
	for( i=0 ; i<9 ; i=i+1 )begin
		a = $fscanf(fx, "%f\n", tmp);
		x[i] = $shortrealtobits(tmp);
		// $display("check x: %.50f", tmp);
	end
	for(i=0;i<3;i=i+1)begin
		a = $fscanf(fh, "%f\n", tmp);
		h[i] = $shortrealtobits(tmp);
		// $display("check h: %.50f", tmp);
	end
	// in vaild
	in_valid = 1 ;
	for( i=0 ; i<9 ; i=i+1 ) begin
		if(i<3) data_h = h[i];
		else data_h = 32'bx;
		weight_u = u[i];
		weight_v = v[i];
		weight_w = w[i];
		data_x = x[i];
		// $display("check u: %f, v: %f, w: %f, x: %f", u[i], v[i], w[i], x[i]);
		@(negedge clk);
	end
	data_x = 32'bx;
	data_h = 32'bx;
	weight_u = 32'bx ;
	weight_v = 32'bx ;
	weight_w = 32'bx ;
	in_valid = 0 ;

end 
endtask

task check_ans ; 
    real out_real [8:0];
	real error;    
begin
    for (i=0 ; i<9 ; i=i+1)begin
		if(out_valid === 1) begin
			out_real[i] = $bitstoshortreal(out);
			if(golden_out[i] < 1.17549435e-38) begin
				error = (golden_out[i] - out_real[i]);
			end
			else begin
				error = (golden_out[i] - out_real[i])/golden_out[i];
			end
			if(error > ERR_VAL || error < -ERR_VAL)begin
            	$display ("------------------------------------------------------------------------------------------------");
            	$display ("                                           SPEC 2 FAIL!                                         ");
            	$display ("                                           wrong output                                         ");
				$display ("------------------------------------------------------------------------------------------------");
				$display("###: fail at y%-1d%-1d", i/3, i%3);
				for(i0 = 0; i0 < 9; i0 = i0+1) begin
					$display("mine y%-1d%-1d: %.50f", i0/3, i0%3, out_real[i0]);
					$display("gold y%-1d%-1d: %.50f", i0/3, i0%3, golden_out[i0]);
					// for(i1 = 0; i1 < 3; i1 = i1+1) begin
					// $write("%.50f", out_real[i0]);
					// $write(" ");
					// // end
					// $write("\n");
				end
				// for(i0 = 1; i0 < 9; i0 = i0+1) begin
				// 	// $write("gold y%-1d: ", i0);
				// 	// // for(i1 = 0; i1 < 3; i1 = i1+1) begin
				// 	// $write("%.50f", golden_out[i0]);
				// 	// $write(" ");
				// 	// // end
				// 	// $write("\n");
				// end
				repeat(9) @(negedge clk);
				$finish;
        	end 
			@(negedge clk);
		end
		else begin
			$display("output not 9 cycles");
			repeat(3) @(negedge clk);
			$finish;
		end
	end 
end
endtask

task wait_outvalid_task ; 
begin
	cycles = 0 ;
	while( out_valid!==1 ) begin
		cycles = cycles + 1 ;
		if (out!==0) begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                SPEC 4 FAIL!                                                                ");
			$display ("                                                                out should be 0 when out_valid = 0                                          ");
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2) @(negedge clk);
			$finish;
		end
		if (cycles==100) begin
            $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $display ("                                                                SPEC 6 FAIL!                                                                ");
            $display ("                                                                execution cycle over 100                                                    ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
            $finish;
		end
		@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end 
endtask

task reset_task ; begin
	#(1.0);	rst_n = 0 ;
	#(2.0);
	if ((out_valid!==0)||(out!==0)) begin
        $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $display ("                                                                SPEC 3 FAIL!                                                                ");
        $display ("                                                              after reset, out or out_valid is not 0                                        ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
        $finish;
    end
    #(1.0);	rst_n = 1 ;
    #(2.0);	release clk;
end endtask

task YOU_PASS_task;
begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
    $display ("                                                  Congratulations!                						             ");
    $display ("                                           You have passed all patterns!          						             ");
    $display ("                                                                                 						             ");
    $display ("                                        Your execution cycles   = %5d cycles      						             ", total_cycles + PATNUM);
    $display ("                                        Your clock period       = %.1f ns        					                 ", `CYCLE_TIME);
    $display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end 
endtask
endmodule