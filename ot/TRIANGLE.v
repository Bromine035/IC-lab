//synopsys translate_off
`include "DW_div.v"
`include "DW_div_seq.v"
`include "DW_div_pipe.v"
//synopsys translate_on

module TRIANGLE(
    clk,
    rst_n,
    in_valid,
    in_length,
    out_cos,
    out_valid,
    out_tri
);
input wire clk, rst_n, in_valid;
input wire [7:0] in_length;

output reg out_valid;
output reg [15:0] out_cos;
output reg [1:0] out_tri;

parameter idle = 3'd0;
parameter indt = 3'd1;
parameter calc = 3'd2;
parameter oudt = 3'd3;

reg [2:0] cst, nst;
reg [4:0] r0;
reg [1:0] r1;
reg [1:0] r2;
reg [7:0] rl [2:0];
wire signed [18:0] wl2 [2:0];
wire signed [18:0] wl3 [2:0];
wire [18:0] wll [2:0];
wire [31:0] wq;
wire [1:0] wtri;
reg ren;
reg [15:0] rqu [2:0];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle; // reset everything
        r1 <= 2'b0;
    end
    else begin
        cst <= nst;
        if(in_valid) begin
        	r1 <= r1 + 1;
        	rl[r1] <= in_length;
        end
        else begin
        	r1 <= 2'b0;
        end
    end
end

always @(*) begin
    if(!rst_n) begin
        nst <= idle;
    end
    else begin
        case(cst)
        idle:
        if(in_valid) begin
            nst <= indt;
        end
        else begin
            nst <= idle;
        end
        
        indt:
        if(r1 == 2) begin
        	nst <= calc;
        end
        else begin
        	nst <= indt;
        end

        calc:
        if(r2 == 3) begin
            nst <= oudt;
        end
        else begin
            nst <= calc;
        end
        
        oudt:
        if(r0 == 2) begin
        	nst <= idle;
        end
        else begin
        	nst <= oudt;
        end

        default:
        nst <= idle;
        
        endcase
    end
end

assign wll[0] = 2 * rl[1] * rl[2];
assign wll[1] = 2 * rl[0] * rl[2];
assign wll[2] = 2 * rl[0] * rl[1];
assign wl3[0] = wl2[1] + wl2[2] - wl2[0];
assign wl3[1] = wl2[0] + wl2[2] - wl2[1];
assign wl3[2] = wl2[0] + wl2[1] - wl2[2];
assign wtri = ((wl3[0] == 0) || (wl3[1] == 0) || (wl3[2] == 0))?(2'b11):((wl3[0][18] || wl3[1][18] || wl3[2][18])?(2'b01):(2'b00));

DW_div_pipe #(	.a_width(32), .b_width(32), .tc_mode(1), .rem_mode(1),
				.num_stages(20), .stall_mode(1), .rst_mode(1), .op_iso_mode(0)) md0(
			    .clk(clk), .rst_n(rst_n), .en(ren), .a({wl3[r2], 13'b0}), .b({13'b0, wll[r2]}),
				.quotient(wq), .remainder(), .divide_by_0());


genvar i0;
generate
	for(i0 = 0; i0 < 3; i0 = i0+1) begin
		assign wl2[i0] = rl[i0] * rl[i0];
	end
endgenerate


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
    	out_cos <= 'b0;
    	out_tri <= 'b0;
    	out_valid <= 1'b0;
    	r0 <= 'b0;
    	r2 <= 'b0;
    	ren <= 1'b0;
    end
    // else if(cst == indt) begin
    // 	r0 <= (r0 == 2)?(0):(r0 + 1);
    // end
    else if(cst == calc) begin
    	if(r2 == 3) begin
    		r2 <= 0;
    		r0 <= 0;
    	end
    	else begin
    		r2 <= (r0 == 20)?(r2+1):(r2);
    		r0 <= (r0 == 20)?(0):(r0 + 1);
    	end
    	
    	if(r0 == 20) begin
    		rqu[r2] <= wq[15:0];
    	end
    	ren <= 1'b1;
    end
    else if(cst == oudt) begin
    	r0 <= (r0 == 2)?(0):(r0 + 1);
    	out_cos <= rqu[r0];
    	out_valid <= 1'b1;
    	out_tri <= (r0 == 0)?(wtri):(0);
    end
    else begin
    	out_cos <= 'b0;
    	out_tri <= 'b0;
    	out_valid <= 1'b0;
    	r0 <= 'b0;
    	r2 <= 'b0;
    	ren <= 1'b0;
    end
end



endmodule











































