module MMT(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid2,
    matrix,
	matrix_size,
    matrix_idx,
    mode,
	
// output signals
    out_valid,
    out_value
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input        clk, rst_n, in_valid, in_valid2;
input [7:0] matrix;
input [1:0]  matrix_size,mode;
input [4:0]  matrix_idx;

output reg       	     out_valid;
output reg signed [49:0] out_value;
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

parameter idle = 3'd0;
parameter idt0 = 3'd1;
parameter idt1 = 3'd2;
parameter rme0 = 3'd3; // read memory
parameter cal0 = 3'd4;
parameter rme1 = 3'd5; // read memory
parameter cal1 = 3'd6;
parameter over = 3'd7;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------

reg [2:0] cst, nst;
reg [3:0] r0, rr0, rrr0, r1, rr1, rrr1;
reg [4:0] r2;
reg [8:0] r00;
reg signed [7:0] rri;
reg [1:0] rms, rrms, rmd, rrmd;
reg [4:0] rmi [2:0];
reg [4:0] rrmi;
reg signed [33:0] rm0 [15:0][15:0];
reg signed [7:0] rm1 [15:0][15:0];
reg signed [33:0] rmm [14:0];
reg gnst;
reg signed [49:0] rro;

wire [7:0] wq [15:0];
wire [4:0] wms0;
wire [3:0] wms1;
wire [15:0] wwen;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

assign wms0 = {md1.wo, 1'b0};
assign wms1 = wms0 - 1;
assign wwen = (cst == idt0)?(~(md0.wo)):(16'hffff);


dec #(.si(4), .so(16)) md0(.wi(r1), .wo());
dec #(.si(2), .so(4)) md1(.wi(rms), .wo());
dp16 #(.ws(34)) mdp(.wi0(), .wi1(), .wo());
genvar i0;
generate
    for(i0 = 0; i0 < 16; i0 = i0+1) begin: fl0
        mm512_8 mm0(.Q(wq[i0]), .CLK(clk), .CEN(1'b0), .WEN(wwen[i0]), .A(r00), .D(rri), .OEN(1'b0));
        assign mdp.wi0[i0] = (wms0 > i0)?(rm0[r1][i0]):(34'b0);
        assign mdp.wi1[i0] = (wms0 > i0)?({{26{rm1[i0][r0][7]}}, rm1[i0][r0]}):(34'b0);
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle;
        rri <= 8'b0;
        rrms <= 2'b0;
        rrmd <= 2'b0;
        rrmi <= 5'b0;
    end
    else begin
        cst <= nst;
        rri <= matrix;
        rrms <= matrix_size;
        rrmd <= mode;
        rrmi <= matrix_idx;
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
            nst <= idt0;
        end
        else if(in_valid2) begin
            nst <= idt1;
        end
        else begin
            nst <= idle;
        end

        idt0:
        if(in_valid) begin
            nst <= idt0;
        end
        else begin
            nst <= idle;
        end

        idt1:
        if(in_valid2) begin
            nst <= idt1;
        end
        else begin
            nst <= rme0;
        end

        rme0:
        if(gnst) begin
            nst <= cal0;
        end
        else begin
            nst <= rme0;
        end

        cal0:
        if(r0 == wms1 && r1 == wms1) begin
            nst <= rme1;
        end
        else begin
            nst <= cal0;
        end

        rme1:
        if(gnst) begin
            nst <= cal1;
        end
        else begin
            nst <= rme1;
        end

        cal1:
        if(r0 == wms1) begin
            nst <= over;
        end
        else begin
            nst <= cal1;
        end

        over:
        nst <= idle;

        default:
        nst <= idle;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 1'b0;
        out_value <= 50'b0;
        rro <= 50'b0;
        rms <= 2'd0;
        rmd <= 2'b0;
        r0 <= 4'b0;
        r1 <= 4'b0;
        r2 <= 5'b0;
        r00 <= 9'b0;
        rr0 <= 4'b0;
        rr1 <= 4'b0;
        rrr0 <= 4'b0;
        rrr1 <= 4'b0;
        gnst <= 1'b0;
    end
    else if(cst == idt0) begin
        if(r0 == 4'b0 && r1 == 4'b0 && r2 == 5'b0) begin
            rms <= rrms;
            r0 <= (r0 == wms1)?(4'b0):(r0 + 1);
            r00 <= (r0 == wms1)?({4'b0, r2}):(r00 + 9'd32);
            r1 <= (r0 == wms1 && r1 == wms1)?(4'b0):((r0 == wms1)?(r1 + 1):r1);
            r2 <= (r0 == wms1 && r1 == wms1)?(r2 + 1):r2;
        end
        else if(r0 == wms1 && r1 == wms1 && r2 == 5'd31) begin
            r0 <= 4'b0;
            r1 <= 4'b0;
            r2 <= 5'b0;
            r00 <= 9'b0;
        end
        else begin
            r0 <= (r0 == wms1)?(4'b0):(r0 + 1);
            r00 <= (r0 == wms1)?((r1 == wms1)?({4'b0, r2+1}):({4'b0, r2})):(r00 + 9'd32);
            r1 <= (r0 == wms1 && r1 == wms1)?(4'b0):((r0 == wms1)?(r1 + 1):r1);
            r2 <= (r0 == wms1 && r1 == wms1)?(r2 + 1):r2;
        end
    end
    else if(cst == idt1) begin
        if(r0 == 0) begin
            rmd <= rrmd;
        end
        else ;
        r0 <= (r0 == 4'd2)?(4'b0):(r0 + 1);
        rmi[r0] <= rrmi;
    end
    else if(cst == rme0) begin
        if(gnst) begin
            r0 <= 4'b0;
            r1 <= 4'b0;
            r00 <= 9'b0;
            rr0 <= 4'b0;
            rr1 <= 4'b0;
            rrr0 <= 4'b0;
            rrr1 <= 4'b0;
            gnst <= 1'b0;
        end
        else begin
            r0 <= (r0 == wms1)?(4'b0):(r0 + 1);
            r1 <= (r0 == wms1)?(r1 + 1):r1;
            r00 <= (r0 == 0)?(rmi[r1]):(r00 + 9'd32);
            rr0 <= r0;
            rr1 <= r1;
            rrr0 <= rr0;
            rrr1 <= rr1;
            gnst <= (r1 == 2);
        end
        if(rrr1 == 4'd1) begin
            rm1[(rmd == 2'b10)?(rrr0):(0)][(rmd == 2'b10)?(0):(rrr0)] <= wq[0];
            rm1[(rmd == 2'b10)?(rrr0):(1)][(rmd == 2'b10)?(1):(rrr0)] <= wq[1];
            rm1[(rmd == 2'b10)?(rrr0):(2)][(rmd == 2'b10)?(2):(rrr0)] <= wq[2];
            rm1[(rmd == 2'b10)?(rrr0):(3)][(rmd == 2'b10)?(3):(rrr0)] <= wq[3];
            rm1[(rmd == 2'b10)?(rrr0):(4)][(rmd == 2'b10)?(4):(rrr0)] <= wq[4];
            rm1[(rmd == 2'b10)?(rrr0):(5)][(rmd == 2'b10)?(5):(rrr0)] <= wq[5];
            rm1[(rmd == 2'b10)?(rrr0):(6)][(rmd == 2'b10)?(6):(rrr0)] <= wq[6];
            rm1[(rmd == 2'b10)?(rrr0):(7)][(rmd == 2'b10)?(7):(rrr0)] <= wq[7];
            rm1[(rmd == 2'b10)?(rrr0):(8)][(rmd == 2'b10)?(8):(rrr0)] <= wq[8];
            rm1[(rmd == 2'b10)?(rrr0):(9)][(rmd == 2'b10)?(9):(rrr0)] <= wq[9];
            rm1[(rmd == 2'b10)?(rrr0):(10)][(rmd == 2'b10)?(10):(rrr0)] <= wq[10];
            rm1[(rmd == 2'b10)?(rrr0):(11)][(rmd == 2'b10)?(11):(rrr0)] <= wq[11];
            rm1[(rmd == 2'b10)?(rrr0):(12)][(rmd == 2'b10)?(12):(rrr0)] <= wq[12];
            rm1[(rmd == 2'b10)?(rrr0):(13)][(rmd == 2'b10)?(13):(rrr0)] <= wq[13];
            rm1[(rmd == 2'b10)?(rrr0):(14)][(rmd == 2'b10)?(14):(rrr0)] <= wq[14];
            rm1[(rmd == 2'b10)?(rrr0):(15)][(rmd == 2'b10)?(15):(rrr0)] <= wq[15];
        end
        else if(rrr1 == 4'd0)begin
            rm0[(rmd == 2'b01)?(rrr0):(0)][(rmd == 2'b01)?(0):(rrr0)] <= {{26{wq[0][7]}}, wq[0]};
            rm0[(rmd == 2'b01)?(rrr0):(1)][(rmd == 2'b01)?(1):(rrr0)] <= {{26{wq[1][7]}}, wq[1]};
            rm0[(rmd == 2'b01)?(rrr0):(2)][(rmd == 2'b01)?(2):(rrr0)] <= {{26{wq[2][7]}}, wq[2]};
            rm0[(rmd == 2'b01)?(rrr0):(3)][(rmd == 2'b01)?(3):(rrr0)] <= {{26{wq[3][7]}}, wq[3]};
            rm0[(rmd == 2'b01)?(rrr0):(4)][(rmd == 2'b01)?(4):(rrr0)] <= {{26{wq[4][7]}}, wq[4]};
            rm0[(rmd == 2'b01)?(rrr0):(5)][(rmd == 2'b01)?(5):(rrr0)] <= {{26{wq[5][7]}}, wq[5]};
            rm0[(rmd == 2'b01)?(rrr0):(6)][(rmd == 2'b01)?(6):(rrr0)] <= {{26{wq[6][7]}}, wq[6]};
            rm0[(rmd == 2'b01)?(rrr0):(7)][(rmd == 2'b01)?(7):(rrr0)] <= {{26{wq[7][7]}}, wq[7]};
            rm0[(rmd == 2'b01)?(rrr0):(8)][(rmd == 2'b01)?(8):(rrr0)] <= {{26{wq[8][7]}}, wq[8]};
            rm0[(rmd == 2'b01)?(rrr0):(9)][(rmd == 2'b01)?(9):(rrr0)] <= {{26{wq[9][7]}}, wq[9]};
            rm0[(rmd == 2'b01)?(rrr0):(10)][(rmd == 2'b01)?(10):(rrr0)] <= {{26{wq[10][7]}}, wq[10]};
            rm0[(rmd == 2'b01)?(rrr0):(11)][(rmd == 2'b01)?(11):(rrr0)] <= {{26{wq[11][7]}}, wq[11]};
            rm0[(rmd == 2'b01)?(rrr0):(12)][(rmd == 2'b01)?(12):(rrr0)] <= {{26{wq[12][7]}}, wq[12]};
            rm0[(rmd == 2'b01)?(rrr0):(13)][(rmd == 2'b01)?(13):(rrr0)] <= {{26{wq[13][7]}}, wq[13]};
            rm0[(rmd == 2'b01)?(rrr0):(14)][(rmd == 2'b01)?(14):(rrr0)] <= {{26{wq[14][7]}}, wq[14]};
            rm0[(rmd == 2'b01)?(rrr0):(15)][(rmd == 2'b01)?(15):(rrr0)] <= {{26{wq[15][7]}}, wq[15]};
        end
        else ;
    end
    else if(cst == cal0) begin
        if(r0 == wms1 && r1 == wms1) begin
            r0 <= 4'b0;
            r1 <= 4'b0;
        end
        else begin
            r0 <= (r0 == wms1)?(4'b0):(r0+1);
            r1 <= (r0 == wms1)?(r1+1):r1;
        end
        rmm[r0] <= mdp.wo;
        rm0[r1][0] <= (r0 == wms1)?(rmm[0]):(rm0[r1][0]);
        rm0[r1][1] <= (r0 == wms1)?((rms == 0)?(mdp.wo):(rmm[1])):(rm0[r1][1]);
        rm0[r1][2] <= (r0 == wms1)?(rmm[2]):(rm0[r1][2]);
        rm0[r1][3] <= (r0 == wms1)?((rms == 1)?(mdp.wo):(rmm[3])):(rm0[r1][3]);
        rm0[r1][4] <= (r0 == wms1)?(rmm[4]):(rm0[r1][4]);
        rm0[r1][5] <= (r0 == wms1)?(rmm[5]):(rm0[r1][5]);
        rm0[r1][6] <= (r0 == wms1)?(rmm[6]):(rm0[r1][6]);
        rm0[r1][7] <= (r0 == wms1)?((rms == 2)?(mdp.wo):(rmm[7])):(rm0[r1][7]);
        rm0[r1][8] <= (r0 == wms1)?(rmm[8]):(rm0[r1][8]);
        rm0[r1][9] <= (r0 == wms1)?(rmm[9]):(rm0[r1][9]);
        rm0[r1][10] <= (r0 == wms1)?(rmm[10]):(rm0[r1][10]);
        rm0[r1][11] <= (r0 == wms1)?(rmm[11]):(rm0[r1][11]);
        rm0[r1][12] <= (r0 == wms1)?(rmm[12]):(rm0[r1][12]);
        rm0[r1][13] <= (r0 == wms1)?(rmm[13]):(rm0[r1][13]);
        rm0[r1][14] <= (r0 == wms1)?(rmm[14]):(rm0[r1][14]);
        rm0[r1][15] <= (r0 == wms1)?(mdp.wo):(rm0[r1][15]);
    end
    else if(cst == rme1) begin
        if(gnst) begin
            gnst <= 1'b0;
            r0 <= 4'b0;
            r1 <= 4'b0;
            r00 <= 9'b0;
            rr0 <= 4'b0;
            rrr0 <= 4'b0;
        end
        else begin
            gnst <= (r1 == 1);
            r0 <= (r0 == wms1)?(4'b0):(r0+1);
            r1 <= (r0 == wms1)?(r1 + 1):r1;
            r00 <= (r0 == 0 && r1 == 0)?(rmi[2]):(r00 + 9'd32);
            rr0 <= r0;
            rrr0 <= rr0;
        end
        rm1[(rmd == 2'b11)?(rrr0):(0)][(rmd == 2'b11)?(0):(rrr0)] <= wq[0];
        rm1[(rmd == 2'b11)?(rrr0):(1)][(rmd == 2'b11)?(1):(rrr0)] <= wq[1];
        rm1[(rmd == 2'b11)?(rrr0):(2)][(rmd == 2'b11)?(2):(rrr0)] <= wq[2];
        rm1[(rmd == 2'b11)?(rrr0):(3)][(rmd == 2'b11)?(3):(rrr0)] <= wq[3];
        rm1[(rmd == 2'b11)?(rrr0):(4)][(rmd == 2'b11)?(4):(rrr0)] <= wq[4];
        rm1[(rmd == 2'b11)?(rrr0):(5)][(rmd == 2'b11)?(5):(rrr0)] <= wq[5];
        rm1[(rmd == 2'b11)?(rrr0):(6)][(rmd == 2'b11)?(6):(rrr0)] <= wq[6];
        rm1[(rmd == 2'b11)?(rrr0):(7)][(rmd == 2'b11)?(7):(rrr0)] <= wq[7];
        rm1[(rmd == 2'b11)?(rrr0):(8)][(rmd == 2'b11)?(8):(rrr0)] <= wq[8];
        rm1[(rmd == 2'b11)?(rrr0):(9)][(rmd == 2'b11)?(9):(rrr0)] <= wq[9];
        rm1[(rmd == 2'b11)?(rrr0):(10)][(rmd == 2'b11)?(10):(rrr0)] <= wq[10];
        rm1[(rmd == 2'b11)?(rrr0):(11)][(rmd == 2'b11)?(11):(rrr0)] <= wq[11];
        rm1[(rmd == 2'b11)?(rrr0):(12)][(rmd == 2'b11)?(12):(rrr0)] <= wq[12];
        rm1[(rmd == 2'b11)?(rrr0):(13)][(rmd == 2'b11)?(13):(rrr0)] <= wq[13];
        rm1[(rmd == 2'b11)?(rrr0):(14)][(rmd == 2'b11)?(14):(rrr0)] <= wq[14];
        rm1[(rmd == 2'b11)?(rrr0):(15)][(rmd == 2'b11)?(15):(rrr0)] <= wq[15];
    end
    else if(cst == cal1) begin
        if(r0 == wms1) begin
            r0 <= 4'b0;
            r1 <= 4'b0;
        end
        else begin
            r0 <= r0 + 1;
            r1 <= r1 + 1;
        end
        rro <= rro + {{16{mdp.wo[33]}}, mdp.wo};
    end
    else if(cst == over) begin
        out_valid <= 1'b1;
        out_value <= rro;
    end
    else begin
        out_valid <= 1'b0;
        out_value <= 50'b0;
        rro <= 50'b0;
        r0 <= 4'b0;
        r1 <= 4'b0;
        r2 <= 5'b0;
        r00 <= 9'b0;
        rr0 <= 4'b0;
        rr1 <= 4'b0;
        rrr0 <= 4'b0;
        rrr1 <= 4'b0;
        gnst <= 1'b0;
    end
end
endmodule

module dec(wi, wo);
parameter si = 0;
parameter so = 0;

input wire [si-1:0] wi;
output wire [so-1:0] wo;
wire [so-1:0] wone;
assign wone = 'b1;
assign wo = (wone << wi);
endmodule

module dp16(wi0, wi1, wo);
parameter ws = 0;
input wire signed [ws-1:0] wi0 [15:0];
input wire signed [ws-1:0] wi1 [15:0];
output wire signed [ws-1:0] wo;
wire signed [ws-1:0] wm [15:0];

genvar i0;
generate
    for(i0 = 0; i0 < 16; i0 = i0+1) begin
        assign wm[i0] = wi0[i0]*wi1[i0];
    end
endgenerate
assign wo = wm[0]+wm[1]+wm[2]+wm[3]+wm[4]+wm[5]+wm[6]+wm[7]+wm[8]+wm[9]+wm[10]+wm[11]+wm[12]+wm[13]+wm[14]+wm[15];
endmodule