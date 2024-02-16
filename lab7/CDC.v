`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
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
    //Output Port
	ready,
    out_valid,
	out,
    
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
output reg  [7:0] out;
output reg	out_valid,ready;

input rst_n, clk1, clk2, in_valid;
input  [4:0]doraemon_id;
input  [7:0]size;
input  [7:0]iq_score;
input  [7:0]eq_score;
input [2:0]size_weight,iq_weight,eq_weight;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

parameter pnum = 13'd6000;
parameter ctof = 4'd10; // cut off of fifo access
parameter idle = 3'd0;
parameter indt = 3'd1;
parameter calc = 3'd2;

reg [1:0] cst, nst;
reg [12:0] r0;
reg [3:0] r1;
reg [2:0] r2;
// reg [4:0] rrdn;
// reg [7:0] rrds, rrdi, rrde;
reg [4:0] rdn [4:0];
reg [7:0] rds [4:0];
reg [7:0] rdi [4:0];
reg [7:0] rde [4:0];
reg [2:0] rws, rwi, rwe;
reg rrinc, rwinc;
reg [7:0] rfi;

chos mch(.dn(), .ds(), .di(), .de(), .ws(rws), .wi(rwi), .we(rwe), .wo0());
AFIFO mff(.rst_n(rst_n), .rclk(clk2), .rinc(!mff.rempty), .wclk(clk1), .winc((rwinc || (cst == calc && in_valid))), .wdata((ready)?(mch.wo0):(rfi)),
          .rempty(), .rdata(), .wfull());

assign mch.dn[0] = rdn[0]; assign mch.dn[1] = rdn[1]; assign mch.dn[2] = rdn[2]; assign mch.dn[3] = rdn[3]; assign mch.dn[4] = rdn[4];
assign mch.ds[0] = rds[0]; assign mch.ds[1] = rds[1]; assign mch.ds[2] = rds[2]; assign mch.ds[3] = rds[3]; assign mch.ds[4] = rds[4];
assign mch.di[0] = rdi[0]; assign mch.di[1] = rdi[1]; assign mch.di[2] = rdi[2]; assign mch.di[3] = rdi[3]; assign mch.di[4] = rdi[4];
assign mch.de[0] = rde[0]; assign mch.de[1] = rde[1]; assign mch.de[2] = rde[2]; assign mch.de[3] = rde[3]; assign mch.de[4] = rde[4];

always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle;
        rdn[0] <= 5'b0; rdn[1] <= 5'b0; rdn[2] <= 5'b0; rdn[3] <= 5'b0; rdn[4] <= 5'b0;
        rds[0] <= 8'b0; rds[1] <= 8'b0; rds[2] <= 8'b0; rds[3] <= 8'b0; rds[4] <= 8'b0;
        rdi[0] <= 8'b0; rdi[1] <= 8'b0; rdi[2] <= 8'b0; rdi[3] <= 8'b0; rdi[4] <= 8'b0; 
        rde[0] <= 8'b0; rde[1] <= 8'b0; rde[2] <= 8'b0; rde[3] <= 8'b0; rde[4] <= 8'b0; 
        rws <= 3'b0; rwi <= 3'b0; rwe <= 3'b0;
        r2 <= 3'b0;
    end
    else begin
        cst <= nst;
        if(cst == indt || nst == indt) begin
            rdn[r2] <= doraemon_id;
            rds[r2] <= size;
            rdi[r2] <= iq_score;
            rde[r2] <= eq_score;
            r2 <= r2 + 1;
            rws <= (r2 == 4)?(size_weight):(rws);
            rwi <= (r2 == 4)?(iq_weight):(rwi);
            rwe <= (r2 == 4)?(eq_weight):(rwe);
        end
        else if(cst == calc && in_valid) begin
            rdn[mch.wo0[7:5]] <= doraemon_id;
            rds[mch.wo0[7:5]] <= size;
            rdi[mch.wo0[7:5]] <= iq_score;
            rde[mch.wo0[7:5]] <= eq_score;
            rws <= size_weight;
            rwi <= iq_weight;
            rwe <= eq_weight;
            r2 <= 3'b0;
        end
        else begin
            rws <= rws; rwi <= rwi; rwe <= rwe;
            r2 <= 3'b0;
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
        if(r2 == 4) begin
            nst <= calc;
        end
        else begin
            nst <= indt;
        end

        calc:
        if(r0 == pnum) begin
            nst <= idle;
        end
        else begin
            nst <= calc;
        end

        default:
        nst <= idle;
        endcase
    end
end

always @(posedge clk1 or negedge rst_n) begin
    if(!rst_n) begin
        r0 <= 'b0;
        rfi <= 'b0;
        ready <= 1'b0;
        rwinc <= 1'b0;
    end
    else if(cst == indt) begin
        // r0 <= (r0 == 4)?('b0):(r0 + 1);
        r0 <= 13'd5;
        ready <= 1'b1;
        if(r2 == 4) begin
            // rfi <= mch.wo0;
            rwinc <= 1'b1;
        end
        else begin
            // rfi <= rfi;
            rwinc <= rwinc;
        end
    end
    else if(cst == calc) begin
        if(mff.wfull) begin
            r0 <= r0 + 1;
            ready <= 1'b0;
            rfi <= mch.wo0;
            rwinc <= 1'b1;
        end
        else if(r1 == ctof) begin
            ready <= 1'b1;
        end
        else if(in_valid) begin
            r0 <= r0 + 1;
            // rfi <= mch.wo0;
            rwinc <= 1'b1;
        end
        else begin
            ready <= ready;
            rwinc <= 1'b0;
        end
    end
    else begin
        r0 <= 'b0;
        rfi <= 'b0;
        ready <= 1'b0;
        rwinc <= 1'b0;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 1'b0;
        out <= 8'b0;
        // rrinc <= 1'b0;
        r1 <= 'b0;
    end
    else if(mff.rempty) begin
        out_valid <= 1'b0;
        out <= 8'b0;
        r1 <= 'b0;
        // rrinc <= 1'b0;
    end
    else begin
        out_valid <= 1'b1;
        out <= mff.rdata;
        // rrinc <= 1'b1;
        if(!ready) begin
            r1 <= r1 + 1;
        end
        else begin
            r1 <= 'b0;
        end
    end
end

endmodule

module chos(dn, ds, di, de, ws, wi, we, wo0);
input wire [4:0] dn [4:0];
input wire [7:0] ds [4:0];
input wire [7:0] di [4:0];
input wire [7:0] de [4:0];
input wire [2:0] ws, wi, we;
output wire [7:0] wo0;
wire [2:0] w0, w1, w2;
wire [13:0] wsc [4:0];

assign wsc[0] = (ws*ds[0] + wi*di[0] + we*de[0]);
assign wsc[1] = (ws*ds[1] + wi*di[1] + we*de[1]);
assign wsc[2] = (ws*ds[2] + wi*di[2] + we*de[2]);
assign wsc[3] = (ws*ds[3] + wi*di[3] + we*de[3]);
assign wsc[4] = (ws*ds[4] + wi*di[4] + we*de[4]);

assign w0 = (wsc[0] < wsc[1])?(3'd1):(3'd0);
assign w1 = (wsc[2] < wsc[3])?(3'd3):(3'd2);
assign w2 = (wsc[w0] < wsc[w1])?(w1):(w0);
assign wo0[7:5] = (wsc[w2] < wsc[4])?(3'd4):(w2);
assign wo0[4:0] = dn[wo0[7:5]];
endmodule