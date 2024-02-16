module SUBWAY(
    //Input Port
    clk,
    rst_n,
    in_valid,
    init,
    in0,
    in1,
    in2,
    in3,
    //Output Port
    out_valid,
    out
);


input clk, rst_n;
input in_valid;
input [1:0] init;
input [1:0] in0, in1, in2, in3; 
output reg       out_valid;
output reg [1:0] out;


//==============================================//
//       parameter & integer declaration        //
//==============================================//

parameter idle = 3'd0;
parameter indt = 3'd1;
parameter comb = 3'd2;
parameter over = 3'd3;

//==============================================//
//           reg & wire declaration             //
//==============================================//

reg [2:0] cst, nst;
reg [1:0] rri [3:0];
reg [1:0] ri [3:0][63:0];
reg [1:0] rro;
wire [1:0] ro [62:0];
reg [1:0] rrn; // init
reg [1:0] rn;
reg roval;
reg [31:0] r0;
wire [1:0] wfz [6:0];

//==============================================//
//                  design                      //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle; // reset everything
        rrn <= 2'b0;
        rri [0] <= 2'b0; rri [1] <= 2'b0; rri [2] <= 2'b0; rri [3] <= 2'b0;
        out_valid <= 1'b0;
        out <= 2'b0;
    end
    else begin
        cst <= nst;
        rrn <= init;
        rri[0] <= in0;
        rri[1] <= in1;
        rri[2] <= in2;
        rri[3] <= in3;
        out_valid <= roval;
        out <= rro;
    end
end

always @(*) begin
    case(cst)
    idle:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(in_valid) begin
        nst <= indt;
    end
    else begin
        nst <= idle;
    end

    indt:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(in_valid) begin
        nst <= indt;
    end
    else begin
        nst <= comb;
    end

    comb:
    if(!rst_n) begin
        nst <= idle;
    end
    else begin
        nst <= over;
    end

    over:
    if(!rst_n) begin
        nst <= idle;
    end
    else if(r0 == 6'd62) begin
        nst <= idle;
    end
    else begin
        nst <= over;
    end

    default:
    nst <= idle;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rn <= 2'b0;
        ri[0][0] <= 2'b0;  ri[0][1] <= 2'b0;  ri[0][2] <= 2'b0;  ri[0][3] <= 2'b0;  ri[0][4] <= 2'b0;  ri[0][5] <= 2'b0;  ri[0][6] <= 2'b0;  ri[0][7] <= 2'b0;
        ri[0][8] <= 2'b0;  ri[0][9] <= 2'b0;  ri[0][10] <= 2'b0; ri[0][11] <= 2'b0; ri[0][12] <= 2'b0; ri[0][13] <= 2'b0; ri[0][14] <= 2'b0; ri[0][15] <= 2'b0;
        ri[0][16] <= 2'b0; ri[0][17] <= 2'b0; ri[0][18] <= 2'b0; ri[0][19] <= 2'b0; ri[0][20] <= 2'b0; ri[0][21] <= 2'b0; ri[0][22] <= 2'b0; ri[0][23] <= 2'b0;
        ri[0][24] <= 2'b0; ri[0][25] <= 2'b0; ri[0][26] <= 2'b0; ri[0][27] <= 2'b0; ri[0][28] <= 2'b0; ri[0][29] <= 2'b0; ri[0][30] <= 2'b0; ri[0][31] <= 2'b0;
        ri[0][32] <= 2'b0; ri[0][33] <= 2'b0; ri[0][34] <= 2'b0; ri[0][35] <= 2'b0; ri[0][36] <= 2'b0; ri[0][37] <= 2'b0; ri[0][38] <= 2'b0; ri[0][39] <= 2'b0;
        ri[0][40] <= 2'b0; ri[0][41] <= 2'b0; ri[0][42] <= 2'b0; ri[0][43] <= 2'b0; ri[0][44] <= 2'b0; ri[0][45] <= 2'b0; ri[0][46] <= 2'b0; ri[0][47] <= 2'b0;
        ri[0][48] <= 2'b0; ri[0][49] <= 2'b0; ri[0][50] <= 2'b0; ri[0][51] <= 2'b0; ri[0][52] <= 2'b0; ri[0][53] <= 2'b0; ri[0][54] <= 2'b0; ri[0][55] <= 2'b0;
        ri[0][56] <= 2'b0; ri[0][57] <= 2'b0; ri[0][58] <= 2'b0; ri[0][59] <= 2'b0; ri[0][60] <= 2'b0; ri[0][61] <= 2'b0; ri[0][62] <= 2'b0; ri[0][63] <= 2'b0;

        ri[1][0] <= 2'b0;  ri[1][1] <= 2'b0;  ri[1][2] <= 2'b0;  ri[1][3] <= 2'b0;  ri[1][4] <= 2'b0;  ri[1][5] <= 2'b0;  ri[1][6] <= 2'b0;  ri[1][7] <= 2'b0;
        ri[1][8] <= 2'b0;  ri[1][9] <= 2'b0;  ri[1][10] <= 2'b0; ri[1][11] <= 2'b0; ri[1][12] <= 2'b0; ri[1][13] <= 2'b0; ri[1][14] <= 2'b0; ri[1][15] <= 2'b0;
        ri[1][16] <= 2'b0; ri[1][17] <= 2'b0; ri[1][18] <= 2'b0; ri[1][19] <= 2'b0; ri[1][20] <= 2'b0; ri[1][21] <= 2'b0; ri[1][22] <= 2'b0; ri[1][23] <= 2'b0;
        ri[1][24] <= 2'b0; ri[1][25] <= 2'b0; ri[1][26] <= 2'b0; ri[1][27] <= 2'b0; ri[1][28] <= 2'b0; ri[1][29] <= 2'b0; ri[1][30] <= 2'b0; ri[1][31] <= 2'b0;
        ri[1][32] <= 2'b0; ri[1][33] <= 2'b0; ri[1][34] <= 2'b0; ri[1][35] <= 2'b0; ri[1][36] <= 2'b0; ri[1][37] <= 2'b0; ri[1][38] <= 2'b0; ri[1][39] <= 2'b0;
        ri[1][40] <= 2'b0; ri[1][41] <= 2'b0; ri[1][42] <= 2'b0; ri[1][43] <= 2'b0; ri[1][44] <= 2'b0; ri[1][45] <= 2'b0; ri[1][46] <= 2'b0; ri[1][47] <= 2'b0;
        ri[1][48] <= 2'b0; ri[1][49] <= 2'b0; ri[1][50] <= 2'b0; ri[1][51] <= 2'b0; ri[1][52] <= 2'b0; ri[1][53] <= 2'b0; ri[1][54] <= 2'b0; ri[1][55] <= 2'b0;
        ri[1][56] <= 2'b0; ri[1][57] <= 2'b0; ri[1][58] <= 2'b0; ri[1][59] <= 2'b0; ri[1][60] <= 2'b0; ri[1][61] <= 2'b0; ri[1][62] <= 2'b0; ri[1][63] <= 2'b0;

        ri[2][0] <= 2'b0;  ri[2][1] <= 2'b0;  ri[2][2] <= 2'b0;  ri[2][3] <= 2'b0;  ri[2][4] <= 2'b0;  ri[2][5] <= 2'b0;  ri[2][6] <= 2'b0;  ri[2][7] <= 2'b0;
        ri[2][8] <= 2'b0;  ri[2][9] <= 2'b0;  ri[2][10] <= 2'b0; ri[2][11] <= 2'b0; ri[2][12] <= 2'b0; ri[2][13] <= 2'b0; ri[2][14] <= 2'b0; ri[2][15] <= 2'b0;
        ri[2][16] <= 2'b0; ri[2][17] <= 2'b0; ri[2][18] <= 2'b0; ri[2][19] <= 2'b0; ri[2][20] <= 2'b0; ri[2][21] <= 2'b0; ri[2][22] <= 2'b0; ri[2][23] <= 2'b0;
        ri[2][24] <= 2'b0; ri[2][25] <= 2'b0; ri[2][26] <= 2'b0; ri[2][27] <= 2'b0; ri[2][28] <= 2'b0; ri[2][29] <= 2'b0; ri[2][30] <= 2'b0; ri[2][31] <= 2'b0;
        ri[2][32] <= 2'b0; ri[2][33] <= 2'b0; ri[2][34] <= 2'b0; ri[2][35] <= 2'b0; ri[2][36] <= 2'b0; ri[2][37] <= 2'b0; ri[2][38] <= 2'b0; ri[2][39] <= 2'b0;
        ri[2][40] <= 2'b0; ri[2][41] <= 2'b0; ri[2][42] <= 2'b0; ri[2][43] <= 2'b0; ri[2][44] <= 2'b0; ri[2][45] <= 2'b0; ri[2][46] <= 2'b0; ri[2][47] <= 2'b0;
        ri[2][48] <= 2'b0; ri[2][49] <= 2'b0; ri[2][50] <= 2'b0; ri[2][51] <= 2'b0; ri[2][52] <= 2'b0; ri[2][53] <= 2'b0; ri[2][54] <= 2'b0; ri[2][55] <= 2'b0;
        ri[2][56] <= 2'b0; ri[2][57] <= 2'b0; ri[2][58] <= 2'b0; ri[2][59] <= 2'b0; ri[2][60] <= 2'b0; ri[2][61] <= 2'b0; ri[2][62] <= 2'b0; ri[2][63] <= 2'b0;

        ri[3][0] <= 2'b0;  ri[3][1] <= 2'b0;  ri[3][2] <= 2'b0;  ri[3][3] <= 2'b0;  ri[3][4] <= 2'b0;  ri[3][5] <= 2'b0;  ri[3][6] <= 2'b0;  ri[3][7] <= 2'b0;
        ri[3][8] <= 2'b0;  ri[3][9] <= 2'b0;  ri[3][10] <= 2'b0; ri[3][11] <= 2'b0; ri[3][12] <= 2'b0; ri[3][13] <= 2'b0; ri[3][14] <= 2'b0; ri[3][15] <= 2'b0;
        ri[3][16] <= 2'b0; ri[3][17] <= 2'b0; ri[3][18] <= 2'b0; ri[3][19] <= 2'b0; ri[3][20] <= 2'b0; ri[3][21] <= 2'b0; ri[3][22] <= 2'b0; ri[3][23] <= 2'b0;
        ri[3][24] <= 2'b0; ri[3][25] <= 2'b0; ri[3][26] <= 2'b0; ri[3][27] <= 2'b0; ri[3][28] <= 2'b0; ri[3][29] <= 2'b0; ri[3][30] <= 2'b0; ri[3][31] <= 2'b0;
        ri[3][32] <= 2'b0; ri[3][33] <= 2'b0; ri[3][34] <= 2'b0; ri[3][35] <= 2'b0; ri[3][36] <= 2'b0; ri[3][37] <= 2'b0; ri[3][38] <= 2'b0; ri[3][39] <= 2'b0;
        ri[3][40] <= 2'b0; ri[3][41] <= 2'b0; ri[3][42] <= 2'b0; ri[3][43] <= 2'b0; ri[3][44] <= 2'b0; ri[3][45] <= 2'b0; ri[3][46] <= 2'b0; ri[3][47] <= 2'b0;
        ri[3][48] <= 2'b0; ri[3][49] <= 2'b0; ri[3][50] <= 2'b0; ri[3][51] <= 2'b0; ri[3][52] <= 2'b0; ri[3][53] <= 2'b0; ri[3][54] <= 2'b0; ri[3][55] <= 2'b0;
        ri[3][56] <= 2'b0; ri[3][57] <= 2'b0; ri[3][58] <= 2'b0; ri[3][59] <= 2'b0; ri[3][60] <= 2'b0; ri[3][61] <= 2'b0; ri[3][62] <= 2'b0; ri[3][63] <= 2'b0;
        // ro <= 'b0;
        r0 <= 32'b0;
        rro <= 2'b0;
        roval <= 1'b0;
    end
    else if(cst == indt) begin
        if(r0 == 32'b0) begin
            rn <= rrn;
        end
        ri[0][r0] <= rri[0];
        ri[1][r0] <= rri[1];
        ri[2][r0] <= rri[2];
        ri[3][r0] <= rri[3];
        r0 <= r0 + 32'b1;
    end
    else if(cst == comb) begin
        // ...;
        r0 <= 32'b0;
    end
    else if(cst == over) begin
        roval <= 1'b1;
        r0 <= r0 + 32'b1;
        rro <= ro[r0];
    end
    else begin
        rn <= 2'b0;
        ri[0][0] <= 2'b0;  ri[0][1] <= 2'b0;  ri[0][2] <= 2'b0;  ri[0][3] <= 2'b0;  ri[0][4] <= 2'b0;  ri[0][5] <= 2'b0;  ri[0][6] <= 2'b0;  ri[0][7] <= 2'b0;
        ri[0][8] <= 2'b0;  ri[0][9] <= 2'b0;  ri[0][10] <= 2'b0; ri[0][11] <= 2'b0; ri[0][12] <= 2'b0; ri[0][13] <= 2'b0; ri[0][14] <= 2'b0; ri[0][15] <= 2'b0;
        ri[0][16] <= 2'b0; ri[0][17] <= 2'b0; ri[0][18] <= 2'b0; ri[0][19] <= 2'b0; ri[0][20] <= 2'b0; ri[0][21] <= 2'b0; ri[0][22] <= 2'b0; ri[0][23] <= 2'b0;
        ri[0][24] <= 2'b0; ri[0][25] <= 2'b0; ri[0][26] <= 2'b0; ri[0][27] <= 2'b0; ri[0][28] <= 2'b0; ri[0][29] <= 2'b0; ri[0][30] <= 2'b0; ri[0][31] <= 2'b0;
        ri[0][32] <= 2'b0; ri[0][33] <= 2'b0; ri[0][34] <= 2'b0; ri[0][35] <= 2'b0; ri[0][36] <= 2'b0; ri[0][37] <= 2'b0; ri[0][38] <= 2'b0; ri[0][39] <= 2'b0;
        ri[0][40] <= 2'b0; ri[0][41] <= 2'b0; ri[0][42] <= 2'b0; ri[0][43] <= 2'b0; ri[0][44] <= 2'b0; ri[0][45] <= 2'b0; ri[0][46] <= 2'b0; ri[0][47] <= 2'b0;
        ri[0][48] <= 2'b0; ri[0][49] <= 2'b0; ri[0][50] <= 2'b0; ri[0][51] <= 2'b0; ri[0][52] <= 2'b0; ri[0][53] <= 2'b0; ri[0][54] <= 2'b0; ri[0][55] <= 2'b0;
        ri[0][56] <= 2'b0; ri[0][57] <= 2'b0; ri[0][58] <= 2'b0; ri[0][59] <= 2'b0; ri[0][60] <= 2'b0; ri[0][61] <= 2'b0; ri[0][62] <= 2'b0; ri[0][63] <= 2'b0;
        
        ri[1][0] <= 2'b0;  ri[1][1] <= 2'b0;  ri[1][2] <= 2'b0;  ri[1][3] <= 2'b0;  ri[1][4] <= 2'b0;  ri[1][5] <= 2'b0;  ri[1][6] <= 2'b0;  ri[1][7] <= 2'b0;
        ri[1][8] <= 2'b0;  ri[1][9] <= 2'b0;  ri[1][10] <= 2'b0; ri[1][11] <= 2'b0; ri[1][12] <= 2'b0; ri[1][13] <= 2'b0; ri[1][14] <= 2'b0; ri[1][15] <= 2'b0;
        ri[1][16] <= 2'b0; ri[1][17] <= 2'b0; ri[1][18] <= 2'b0; ri[1][19] <= 2'b0; ri[1][20] <= 2'b0; ri[1][21] <= 2'b0; ri[1][22] <= 2'b0; ri[1][23] <= 2'b0;
        ri[1][24] <= 2'b0; ri[1][25] <= 2'b0; ri[1][26] <= 2'b0; ri[1][27] <= 2'b0; ri[1][28] <= 2'b0; ri[1][29] <= 2'b0; ri[1][30] <= 2'b0; ri[1][31] <= 2'b0;
        ri[1][32] <= 2'b0; ri[1][33] <= 2'b0; ri[1][34] <= 2'b0; ri[1][35] <= 2'b0; ri[1][36] <= 2'b0; ri[1][37] <= 2'b0; ri[1][38] <= 2'b0; ri[1][39] <= 2'b0;
        ri[1][40] <= 2'b0; ri[1][41] <= 2'b0; ri[1][42] <= 2'b0; ri[1][43] <= 2'b0; ri[1][44] <= 2'b0; ri[1][45] <= 2'b0; ri[1][46] <= 2'b0; ri[1][47] <= 2'b0;
        ri[1][48] <= 2'b0; ri[1][49] <= 2'b0; ri[1][50] <= 2'b0; ri[1][51] <= 2'b0; ri[1][52] <= 2'b0; ri[1][53] <= 2'b0; ri[1][54] <= 2'b0; ri[1][55] <= 2'b0;
        ri[1][56] <= 2'b0; ri[1][57] <= 2'b0; ri[1][58] <= 2'b0; ri[1][59] <= 2'b0; ri[1][60] <= 2'b0; ri[1][61] <= 2'b0; ri[1][62] <= 2'b0; ri[1][63] <= 2'b0;

        ri[2][0] <= 2'b0;  ri[2][1] <= 2'b0;  ri[2][2] <= 2'b0;  ri[2][3] <= 2'b0;  ri[2][4] <= 2'b0;  ri[2][5] <= 2'b0;  ri[2][6] <= 2'b0;  ri[2][7] <= 2'b0;
        ri[2][8] <= 2'b0;  ri[2][9] <= 2'b0;  ri[2][10] <= 2'b0; ri[2][11] <= 2'b0; ri[2][12] <= 2'b0; ri[2][13] <= 2'b0; ri[2][14] <= 2'b0; ri[2][15] <= 2'b0;
        ri[2][16] <= 2'b0; ri[2][17] <= 2'b0; ri[2][18] <= 2'b0; ri[2][19] <= 2'b0; ri[2][20] <= 2'b0; ri[2][21] <= 2'b0; ri[2][22] <= 2'b0; ri[2][23] <= 2'b0;
        ri[2][24] <= 2'b0; ri[2][25] <= 2'b0; ri[2][26] <= 2'b0; ri[2][27] <= 2'b0; ri[2][28] <= 2'b0; ri[2][29] <= 2'b0; ri[2][30] <= 2'b0; ri[2][31] <= 2'b0;
        ri[2][32] <= 2'b0; ri[2][33] <= 2'b0; ri[2][34] <= 2'b0; ri[2][35] <= 2'b0; ri[2][36] <= 2'b0; ri[2][37] <= 2'b0; ri[2][38] <= 2'b0; ri[2][39] <= 2'b0;
        ri[2][40] <= 2'b0; ri[2][41] <= 2'b0; ri[2][42] <= 2'b0; ri[2][43] <= 2'b0; ri[2][44] <= 2'b0; ri[2][45] <= 2'b0; ri[2][46] <= 2'b0; ri[2][47] <= 2'b0;
        ri[2][48] <= 2'b0; ri[2][49] <= 2'b0; ri[2][50] <= 2'b0; ri[2][51] <= 2'b0; ri[2][52] <= 2'b0; ri[2][53] <= 2'b0; ri[2][54] <= 2'b0; ri[2][55] <= 2'b0;
        ri[2][56] <= 2'b0; ri[2][57] <= 2'b0; ri[2][58] <= 2'b0; ri[2][59] <= 2'b0; ri[2][60] <= 2'b0; ri[2][61] <= 2'b0; ri[2][62] <= 2'b0; ri[2][63] <= 2'b0;

        ri[3][0] <= 2'b0;  ri[3][1] <= 2'b0;  ri[3][2] <= 2'b0;  ri[3][3] <= 2'b0;  ri[3][4] <= 2'b0;  ri[3][5] <= 2'b0;  ri[3][6] <= 2'b0;  ri[3][7] <= 2'b0;
        ri[3][8] <= 2'b0;  ri[3][9] <= 2'b0;  ri[3][10] <= 2'b0; ri[3][11] <= 2'b0; ri[3][12] <= 2'b0; ri[3][13] <= 2'b0; ri[3][14] <= 2'b0; ri[3][15] <= 2'b0;
        ri[3][16] <= 2'b0; ri[3][17] <= 2'b0; ri[3][18] <= 2'b0; ri[3][19] <= 2'b0; ri[3][20] <= 2'b0; ri[3][21] <= 2'b0; ri[3][22] <= 2'b0; ri[3][23] <= 2'b0;
        ri[3][24] <= 2'b0; ri[3][25] <= 2'b0; ri[3][26] <= 2'b0; ri[3][27] <= 2'b0; ri[3][28] <= 2'b0; ri[3][29] <= 2'b0; ri[3][30] <= 2'b0; ri[3][31] <= 2'b0;
        ri[3][32] <= 2'b0; ri[3][33] <= 2'b0; ri[3][34] <= 2'b0; ri[3][35] <= 2'b0; ri[3][36] <= 2'b0; ri[3][37] <= 2'b0; ri[3][38] <= 2'b0; ri[3][39] <= 2'b0;
        ri[3][40] <= 2'b0; ri[3][41] <= 2'b0; ri[3][42] <= 2'b0; ri[3][43] <= 2'b0; ri[3][44] <= 2'b0; ri[3][45] <= 2'b0; ri[3][46] <= 2'b0; ri[3][47] <= 2'b0;
        ri[3][48] <= 2'b0; ri[3][49] <= 2'b0; ri[3][50] <= 2'b0; ri[3][51] <= 2'b0; ri[3][52] <= 2'b0; ri[3][53] <= 2'b0; ri[3][54] <= 2'b0; ri[3][55] <= 2'b0;
        ri[3][56] <= 2'b0; ri[3][57] <= 2'b0; ri[3][58] <= 2'b0; ri[3][59] <= 2'b0; ri[3][60] <= 2'b0; ri[3][61] <= 2'b0; ri[3][62] <= 2'b0; ri[3][63] <= 2'b0;
        // ro <= 'b0;
        r0 <= 32'b0;
        rro <= 2'b0;
        roval <= 1'b0;
    end
end

genvar i0, i1;
generate
    mtrn mt0(.wi(), .pt(rn), .wo());
    mitv mi0(.wi(), .pti(rn), .pto(wfz[0]), .wo());
    assign mt0.wi[0] = ri[0][2]; assign mt0.wi[1] = ri[1][2];
    assign mt0.wi[2] = ri[2][2]; assign mt0.wi[3] = ri[3][2];
    assign mi0.wi[0][0] = ri[0][4]; assign mi0.wi[0][1] = ri[1][4];
    assign mi0.wi[0][2] = ri[2][4]; assign mi0.wi[0][3] = ri[3][4];
    assign mi0.wi[1][0] = ri[0][6]; assign mi0.wi[1][1] = ri[1][6];
    assign mi0.wi[1][2] = ri[2][6]; assign mi0.wi[1][3] = ri[3][6];
    assign ro[0] = mt0.wo[0];
    assign ro[1] = mt0.wo[1];
    assign ro[2] = mt0.wo[2];
    assign ro[3] = mi0.wo[0];
    assign ro[4] = mi0.wo[1];
    assign ro[5] = mi0.wo[2];
    assign ro[6] = mi0.wo[3];
    assign ro[7] = mi0.wo[4];
    for(i0 = 0; i0 < 7; i0 = i0+1) begin
        fz fz1(.rc(), .n0());
        assign fz1.rc[0] = ri[0][8+i0*8]; assign fz1.rc[1] = ri[1][8+i0*8];
        assign fz1.rc[2] = ri[2][8+i0*8]; assign fz1.rc[3] = ri[3][8+i0*8];
        assign wfz[i0] = fz1.n0;
        mtrn mt1(.wi(), .pt(fz1.n0), .wo());
        assign mt1.wi[0] = ri[0][10+i0*8]; assign mt1.wi[1] = ri[1][10+i0*8];
        assign mt1.wi[2] = ri[2][10+i0*8]; assign mt1.wi[3] = ri[3][10+i0*8];
        assign ro[(8+i0*8)] = mt1.wo[0];
        assign ro[(9+i0*8)] = mt1.wo[1];
        assign ro[(10+i0*8)] = mt1.wo[2];
    end
    for(i1 = 0; i1 < 6; i1 = i1+1) begin
        mitv mi1(.wi(), .pti(wfz[i1]), .pto(wfz[i1+1]), .wo());
        assign mi1.wi[0][0] = ri[0][12+i1*8]; assign mi1.wi[0][1] = ri[1][12+i1*8];
        assign mi1.wi[0][2] = ri[2][12+i1*8]; assign mi1.wi[0][3] = ri[3][12+i1*8];
        assign mi1.wi[1][0] = ri[0][14+i1*8]; assign mi1.wi[1][1] = ri[1][14+i1*8];
        assign mi1.wi[1][2] = ri[2][14+i1*8]; assign mi1.wi[1][3] = ri[3][14+i1*8];
        assign ro[(11+i1*8)] = mi1.wo[0];
        assign ro[(12+i1*8)] = mi1.wo[1];
        assign ro[(13+i1*8)] = mi1.wo[2];
        assign ro[(14+i1*8)] = mi1.wo[3];
        assign ro[(15+i1*8)] = mi1.wo[4];
    end
    assign ro[59] = (ri[wfz[6]][60] == 2'd1)?2'd3:2'd0;
    assign ro[60] = 2'd0;
    assign ro[61] = (ri[wfz[6]][62] == 2'd1)?2'd3:2'd0;
    assign ro[62] = 2'd0;
endgenerate

endmodule

module fz(rc, n0);
input wire [1:0] rc [3:0];
output reg [1:0] n0;

always @(*) begin
if(!rc[0])      n0 <= 2'd0;
else if(!rc[1]) n0 <= 2'd1;
else if(!rc[2]) n0 <= 2'd2;
else if(!rc[3]) n0 <= 2'd3;
else            n0 <= 2'dx;
end
endmodule

module abs3(wi, wo);
input wire [2:0] wi;
output wire [2:0] wo;
assign wo = (wi[2])?((~wi)+1):wi;
endmodule

module mtrn(wi, pt, wo); // train
input wire [1:0] wi [3:0];
input wire [1:0] pt;
output wire [1:0] wo [2:0];

assign wo[0] = 2'b0;
assign wo[1] = (wi[pt] == 2'b1)?2'd3:2'b0;
assign wo[2] = 2'b0;
endmodule

module mitv(wi, pti, pto, wo);
input wire [1:0] wi [1:0][3:0];
input wire [1:0] pti, pto;
output wire [1:0] wo [4:0];

wire [2:0] w0;
wire [1:0] w1;
wire [1:0] wp1;
wire [1:0] wp3;
wire [1:0] wp4;
wire [1:0] wud; // unit distance
assign w0 = {1'b0, pti} - {1'b0, pto};
abs3 abs0(.wi(w0), .wo());
assign wud = w0[2]?2'b1:2'd3; // +1:-1
assign w1 = w0[2]?2'd2:2'd2; // right:left
assign wo[0] = (wi[0][pti] == 2'b1)?2'd3:2'b0;
assign wo[1] = (!abs0.wo)?2'd0:w1;
assign wo[2] = (!abs0.wo)?((wi[1][pti] == 2'b1)?2'd3:2'd0):((wi[1][pti+wud] == 2'b1)?2'd3:2'd0);
assign wo[3] = (abs0.wo[1] == 1'b1)?w1:2'd0;
assign wo[4] = (abs0.wo == 3'd3)?w1:2'b0;
endmodule
