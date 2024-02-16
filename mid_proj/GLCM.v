//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NCTU ED415
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 spring
//   Midterm Proejct            : GLCM 
//   Author                     : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : GLCM.v
//   Module Name : GLCM
//   Release version : V1.0 (Release Date: 2023-04)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module GLCM(
				clk,	
			  rst_n,	
	
			in_addr_M,
			in_addr_G,
			in_dir,
			in_dis,
			in_valid,
			out_valid,
	

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 
);
parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 32;
input			  clk,rst_n;



// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
       your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
	   therefore I declared output of AXI as wire in Poly_Ring
*/
   
// -----------------------------
// IO port
input [ADDR_WIDTH-1:0]      in_addr_M;
input [ADDR_WIDTH-1:0]      in_addr_G;
input [1:0]  	  		in_dir;
input [3:0]	    		in_dis;
input 			    	in_valid;
output reg 	              out_valid;
// -----------------------------


// axi write address channel 
output  wire [ID_WIDTH-1:0]        awid_m_inf;
output  wire [ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [2:0]            awsize_m_inf;
output  wire [1:0]           awburst_m_inf;
output  wire [3:0]             awlen_m_inf;
output  wire                 awvalid_m_inf;
input   wire                 awready_m_inf;
// axi write data channel 
output  wire [ DATA_WIDTH-1:0]     wdata_m_inf;
output  wire                   wlast_m_inf;
output  wire                  wvalid_m_inf;
input   wire                  wready_m_inf;
// axi write response channel
input   wire [ID_WIDTH-1:0]         bid_m_inf;
input   wire [1:0]             bresp_m_inf;
input   wire              	   bvalid_m_inf;
output  wire                  bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [ID_WIDTH-1:0]       arid_m_inf;
output  wire [ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [3:0]            arlen_m_inf;
output  wire [2:0]           arsize_m_inf;
output  wire [1:0]          arburst_m_inf;
output  wire                arvalid_m_inf;
input   wire               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [ID_WIDTH-1:0]         rid_m_inf;
input   wire [DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [1:0]             rresp_m_inf;
input   wire                   rlast_m_inf;
input   wire                  rvalid_m_inf;
output  wire                  rready_m_inf;
// -----------------------------

parameter idle = 2'd0;
parameter indt = 2'd1; // dram to sram
parameter calc = 2'd2; // sram to reg // GLCM-sram to reg to calculation to GLCM-sram
parameter oudt = 2'd3; // GLCM-sram to dram

reg [1:0] cst, nst;
reg r2, rawval, rarval, rwen, rrredy, rwval, rwlas, rbredy;
reg [ADDR_WIDTH-1:0] radm, radg;
reg [1:0] rdir;
reg [3:0] rdis;
reg [4:0] r0, r1;
reg [8:0] rsra; // sram address
reg [31:0] rsrd; // sram data
reg [3:0] rcol, rrow;
reg [4:0] rp0, rp1; // point0: original point, row index of GLCM; point1: ref, col
reg [31:0] rcheck [31:0];
reg [1:0] rslc;
wire [31:0] wq0;

assign awid_m_inf = 'b0;
assign awaddr_m_inf = (rawval)?(radg + r1*32'd64):('bx);
assign awsize_m_inf = 3'b010;
assign awburst_m_inf = 2'b01;
assign awlen_m_inf = 4'd15;
assign awvalid_m_inf = rawval;

assign wdata_m_inf = {(rcheck[5'd2*r1 + ((r0 > 5'd8)?(5'b1):(5'b0))][4*((r0 > 5'd8)?(r0 - 5'd9):(r0 - 5'b1)) + 5'd3])?(wq0[31:24]):(8'b0),
                      (rcheck[5'd2*r1 + ((r0 > 5'd8)?(5'b1):(5'b0))][4*((r0 > 5'd8)?(r0 - 5'd9):(r0 - 5'b1)) + 5'd2])?(wq0[23:16]):(8'b0),
                      (rcheck[5'd2*r1 + ((r0 > 5'd8)?(5'b1):(5'b0))][4*((r0 > 5'd8)?(r0 - 5'd9):(r0 - 5'b1)) + 5'd1])?(wq0[15:8]):(8'b0),
                      (rcheck[5'd2*r1 + ((r0 > 5'd8)?(5'b1):(5'b0))][4*((r0 > 5'd8)?(r0 - 5'd9):(r0 - 5'b1))])?(wq0[7:0]):(8'b0)};
assign wvalid_m_inf = rwval;
assign wlast_m_inf = rwlas;

// assign bid_m_inf = 'b0;
assign bready_m_inf = rbredy;

assign arid_m_inf = 'b0;
assign araddr_m_inf = (rarval)?(radm + r1*32'd64):('bx);
assign arlen_m_inf = 4'd15;
assign arsize_m_inf = 3'b010;
assign arburst_m_inf = 2'b01;
assign arvalid_m_inf = rarval;

// assign rid_m_inf = 'b0;
assign rready_m_inf = rrredy;

mm320_32 mm0(.Q(wq0), .CLK(clk), .CEN(1'b0), .WEN(rwen), .A(rsra), .D(rsrd), .OEN(1'b0));
mux4 #(.size(8)) mx0(.wi0(wq0[7:0]), .wi1(wq0[15:8]), .wi2(wq0[23:16]), .wi3(wq0[31:24]), .slc(rslc), .wo0());

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= idle;
        radm <= 'b0;
        radg <= 'b0;
        rdir <= 2'b0;
        rdis <= 4'b0;
    end
    else begin
        cst <= nst;
        radm <= (in_valid)?(in_addr_M):(radm);
        radg <= (in_valid)?(in_addr_G):(radg);
        rdir <= (in_valid)?(in_dir):(rdir);
        rdis <= (in_valid)?(in_dis):(rdis);
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
        if(r1 == 5'd4) begin
            nst <= calc;
        end
        else begin
            nst <= indt;
        end

        calc:
        if(r2) begin
            nst <= oudt;
        end
        else begin
            nst <= calc;
        end

        oudt:
        if(r1 == 5'd16) begin
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

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r0 <= 5'b0;
        r1 <= 5'b0;
        r2 <= 1'b0;
        rarval <= 1'b0;
        rrredy <= 1'b0;
        rwen <= 1'b1;
        rsra <= 9'h1ff;
        rsrd <= 32'b0;
        rcol <= 4'b0;
        rrow <= 4'b0;
        rp0 <= 5'b0;
        rp1 <= 5'b0;
        rslc <= 2'b0;
        rawval <= 1'b0;
        rwval <= 1'b0;
        rwlas <= 1'b0;
        rbredy <= 1'b0;
        rcheck[0]  <= 32'b0; rcheck[1]  <= 32'b0; rcheck[2]  <= 32'b0; rcheck[3]  <= 32'b0; rcheck[4]  <= 32'b0; rcheck[5]  <= 32'b0; rcheck[6]  <= 32'b0; rcheck[7]  <= 32'b0;
        rcheck[8]  <= 32'b0; rcheck[9]  <= 32'b0; rcheck[10] <= 32'b0; rcheck[11] <= 32'b0; rcheck[12] <= 32'b0; rcheck[13] <= 32'b0; rcheck[14] <= 32'b0; rcheck[15] <= 32'b0;
        rcheck[16] <= 32'b0; rcheck[17] <= 32'b0; rcheck[18] <= 32'b0; rcheck[19] <= 32'b0; rcheck[20] <= 32'b0; rcheck[21] <= 32'b0; rcheck[22] <= 32'b0; rcheck[23] <= 32'b0;
        rcheck[24] <= 32'b0; rcheck[25] <= 32'b0; rcheck[26] <= 32'b0; rcheck[27] <= 32'b0; rcheck[28] <= 32'b0; rcheck[29] <= 32'b0; rcheck[30] <= 32'b0; rcheck[31] <= 32'b0;
        out_valid <= 1'b0;
    end
    else if(cst == indt) begin
        if(r1 == 4)begin
            r0 <= 5'b0;
            r1 <= 5'b0;
            rarval <= 1'b0;
            rwen <= 1'b1;
            rsra <= 9'b0;
            rsrd <= 32'b0;
            rrredy <= 1'b0;
        end
        else if(r0 == 0) begin
            rarval <= (arready_m_inf)?(1'b0):(1'b1);
            r0 <= (arready_m_inf)?(r0 + 1):(r0);
            rwen <= 1'b1;
            rrredy <= 1'b0;
        end
        else if(r0 == 5'd16) begin
            if(rrredy) begin
                rrredy <= (rvalid_m_inf)?(1'b0):(rrredy);
                r0     <= (rvalid_m_inf)?(1'b0):(r0);
                r1     <= (rvalid_m_inf)?(r1 + 1):(r1);
                rwen   <= (rvalid_m_inf)?(1'b0):(1'b1);
                rsra   <= (rvalid_m_inf)?(rsra + 1):(rsra);
                rsrd   <= (rvalid_m_inf)?(rdata_m_inf):(rsrd);
            end
            else begin
                rrredy <= 1'b1;
                rwen <= 1'b1;
            end
        end
        else begin
            if(rrredy) begin
                rrredy <= (rvalid_m_inf)?(1'b0):(rrredy);
                r0     <= (rvalid_m_inf)?(r0 + 1):(r0);
                rwen   <= (rvalid_m_inf)?(1'b0):(1'b1);
                rsra   <= (rvalid_m_inf)?(rsra + 1):(rsra);
                rsrd   <= (rvalid_m_inf)?(rdata_m_inf):(rsrd);
            end
            else begin
                rrredy <= 1'b1;
                rwen <= 1'b1;
            end
        end
    end
    else if(cst == calc) begin
        if(r2) begin
            r2 <= 1'b0;
            rsra <= 9'd64;
            rsrd <= 32'b0;
            rcol <= 4'b0;
            rrow <= 4'b0;
            rwen <= 1'b1;
        end
        else if(r0 == 5'd0) begin
            rsra <= (rrow*16 + rcol)/4;
            rwen <= 1'b1;
        end
        else if(r0 == 5'd1) begin
            rsra <= (((rdir[0])?(rrow + rdis):(rrow))*16 + ((rdir[1])?(rcol + rdis):(rcol)))/4;
            rslc <= (rrow*16 + rcol)%4;
        end
        else if(r0 == 5'd2) begin
            rp0 <= mx0.wo0[4:0];
            rslc <= (((rdir[0])?(rrow + rdis):(rrow))*16 + ((rdir[1])?(rcol + rdis):(rcol)))%4;
        end
        else if(r0 == 5'd3) begin
            rp1 <= mx0.wo0[4:0];
            rsra <= ((rp0*32 + mx0.wo0[4:0])/4) + 9'd64;
            rslc <= (rp0*32 + mx0.wo0[4:0])%4;
        end
        else if(r0 == 5'd5) begin
            case(rslc)
            2'd0: rsrd <= {wq0[31:8], ((rcheck[rp0][rp1])?(mx0.wo0 + 8'd1):(8'd1))};
            2'd1: rsrd <= {wq0[31:16], ((rcheck[rp0][rp1])?(mx0.wo0 + 8'd1):(8'd1)), wq0[7:0]};
            2'd2: rsrd <= {wq0[31:24], ((rcheck[rp0][rp1])?(mx0.wo0 + 8'd1):(8'd1)), wq0[15:0]};
            2'd3: rsrd <= {((rcheck[rp0][rp1])?(mx0.wo0 + 8'd1):(8'd1)), wq0[23:0]};
            endcase
            rcheck[rp0][rp1] <= 1'b1;
            rwen <= 1'b0;
            rcol <= (((rdir[1])?(rcol + rdis):(rcol)) == 4'd15)?(4'b0):(rcol + 1);
            rrow <= (((rdir[1])?(rcol + rdis):(rcol)) == 4'd15)?(rrow + 1):(rrow);
            r2   <= ((((rdir[0])?(rrow + rdis):(rrow)) == 4'd15) && (((rdir[1])?(rcol + rdis):(rcol)) == 4'd15));
        end
        else begin
            rwen <= 1'b1;
        end
        r0 <= (r0 == 5'd5 || r2)?(5'b0):(r0 + 1);
    end
    else if(cst == oudt) begin
        if(r1 == 5'd16) begin
            r0 <= 5'b0;
            r1 <= 5'b0;
            rawval <= 1'b0;
            rwval <= 1'b0;
            rwlas <= 1'b0;
            rbredy <= 1'b0;
            out_valid <= 1'b1;
        end
        else if(r0 == 0) begin
            rawval <= (awready_m_inf)?(1'b0):(1'b1);
            r0     <= (awready_m_inf)?(r0 + 1):(r0);
            rbredy <= (awready_m_inf)?(1'b1):(rbredy);
            rwval <= 1'b0;
            rwlas <= 1'b0;
        end
        else if(r0 == 5'd16) begin
            if(rwval) begin
                rwval <= (wready_m_inf)?(1'b0):(rwval);
                rwlas <= (wready_m_inf)?(1'b0):(rwlas);
                rsra  <= (wready_m_inf)?(rsra + 1):(rsra);
                r0    <= (wready_m_inf)?(r0 + 1):(r0);
            end
            else begin
                rwval <= 1'b1;
                rwlas <= 1'b1;
            end
        end
        else if(r0 == 5'd17) begin
            rbredy <= (bvalid_m_inf)?(1'b0):(rbredy);
            r0 <= (bvalid_m_inf)?(5'b0):(r0);
            r1 <= (bvalid_m_inf)?(r1 + 1):(r1);
            rwlas <= 1'b0;
        end
        else begin
            if(rwval) begin
                rwval <= (wready_m_inf)?(1'b0):(rwval);
                rsra  <= (wready_m_inf)?(rsra + 1):(rsra);
                r0    <= (wready_m_inf)?(r0 + 1):(r0);
            end
            else begin
                rwval <= 1'b1;
            end
        end
    end
    else begin
        r0 <= 5'b0;
        r1 <= 5'b0;
        r2 <= 1'b0;
        rarval <= 1'b0;
        rrredy <= 1'b0;
        rwen <= 1'b1;
        rsra <= 9'h1ff;
        rsrd <= 32'b0;
        rcol <= 4'b0;
        rrow <= 4'b0;
        rp0 <= 5'b0;
        rp1 <= 5'b0;
        rslc <= 2'b0;
        rawval <= 1'b0;
        rwval <= 1'b0;
        rwlas <= 1'b0;
        rbredy <= 1'b0;
        rcheck[0]  <= 32'b0; rcheck[1]  <= 32'b0; rcheck[2]  <= 32'b0; rcheck[3]  <= 32'b0; rcheck[4]  <= 32'b0; rcheck[5]  <= 32'b0; rcheck[6]  <= 32'b0; rcheck[7]  <= 32'b0;
        rcheck[8]  <= 32'b0; rcheck[9]  <= 32'b0; rcheck[10] <= 32'b0; rcheck[11] <= 32'b0; rcheck[12] <= 32'b0; rcheck[13] <= 32'b0; rcheck[14] <= 32'b0; rcheck[15] <= 32'b0;
        rcheck[16] <= 32'b0; rcheck[17] <= 32'b0; rcheck[18] <= 32'b0; rcheck[19] <= 32'b0; rcheck[20] <= 32'b0; rcheck[21] <= 32'b0; rcheck[22] <= 32'b0; rcheck[23] <= 32'b0;
        rcheck[24] <= 32'b0; rcheck[25] <= 32'b0; rcheck[26] <= 32'b0; rcheck[27] <= 32'b0; rcheck[28] <= 32'b0; rcheck[29] <= 32'b0; rcheck[30] <= 32'b0; rcheck[31] <= 32'b0;
        out_valid <= 1'b0;
    end
end
endmodule

module mux4(wi0, wi1, wi2, wi3, slc, wo0);
parameter size = 0;	
input wire [size-1:0] wi0, wi1, wi2, wi3;
input wire [1:0] slc;
output wire [size-1:0] wo0;
assign wo0 = (slc[1])?((slc[0])?(wi3):(wi2)):((slc[0])?(wi1):(wi0));
endmodule
