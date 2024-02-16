//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2023-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//###########################################
//
// Wrtie down your design below
//
//###########################################

parameter chki = 3'd0;
parameter redi = 3'd1;
parameter ifid = 3'd2;
parameter exec = 3'd3;
parameter memo = 3'd4;
parameter over = 3'd5;

//####################################################
//               reg & wire
//####################################################

reg signed [15:0] wrs, wrt, wrd;
reg signed [15:0] walu;
wire [15:0] wi;
wire signed [15:0] w0 = wrs + {{11{wi[4]}}, wi[4:0]};
wire signed [31:0] wrsi = ({{15{w0[15]}}, w0, 1'b0}) + 32'h00001000;
reg [2:0] cst, nst;
reg [7:0] r0;
reg [11:0] pc;
reg [15:0] rchk;
reg [1:0] rarval, rrredy;
reg rawval, rwlas, rwval, rbredy, rwen;
reg [15:0] rsrd;

mm2048_16 mm0(.Q(wi), .CLK(clk), .CEN(1'b0), .WEN(rwen), .A((cst == redi && nst != exec)?({pc[10:7], r0[6:0]}):(pc[10:0])), .D(rsrd), .OEN(1'b0));

assign awid_m_inf = 'b0;
assign awaddr_m_inf = wrsi;
assign awsize_m_inf = 3'b001;
assign awburst_m_inf = 2'b01;
assign awlen_m_inf = 7'd0;
assign awvalid_m_inf = rawval;

assign wdata_m_inf = wrt;
assign wlast_m_inf = rwlas;
assign wvalid_m_inf = rwval;

assign bready_m_inf = rbredy;

assign arid_m_inf = 'b0;
assign araddr_m_inf = {20'b1, pc[10:7], 8'b0, wrsi};
assign arlen_m_inf = {7'd127, 7'b0};
assign arsize_m_inf = {3'b001, 3'b001};
assign arburst_m_inf = {2'b01, 2'b01};
assign arvalid_m_inf = rarval;
assign rready_m_inf = rrredy;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cst <= chki;
    end
    else begin
        cst <= nst;
    end
end

always @(*) begin
    if(!rst_n) begin
        nst <= chki;
    end
    else begin
        case(cst)
        chki:
        nst <= (pc > 12'd02047)?(over):((!rchk[pc[10:7]])?(redi):(exec));

        redi:
        if(r0 == 8'd127) begin
            nst <= ifid;
        end
        else begin
            nst <= redi;
        end

        ifid:
        nst <= exec;

        exec:
        nst <= (wi[14])?(memo):(chki);

        memo:
        nst <= ((rrredy[0] && rvalid_m_inf[0]) || (r0 == 8'd1 && bvalid_m_inf))?(chki):(memo);

        over:
        nst <= over;

        default:
        nst <= chki;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        core_r0 <= 16'b0;  core_r1 <= 16'b0;  core_r2 <= 16'b0;  core_r3 <= 16'b0;
        core_r4 <= 16'b0;  core_r5 <= 16'b0;  core_r6 <= 16'b0;  core_r7 <= 16'b0;
        core_r8 <= 16'b0;  core_r9 <= 16'b0;  core_r10 <= 16'b0; core_r11 <= 16'b0;
        core_r12 <= 16'b0; core_r13 <= 16'b0; core_r14 <= 16'b0; core_r15 <= 16'b0;
        r0 <= 8'd128;
        pc <= 12'b0;
        rchk <= 32'b0;
        rarval <= 2'b0; rrredy <= 2'b0;
        rawval <= 1'b0; rwlas  <= 1'b0; rwval <= 1'b0; rbredy <= 1'b0; rwen <= 1'b1;
        IO_stall <= 1'b1;
    end
    else if(cst == redi) begin
        if(r0 == 8'd128) begin
            rarval[1] <= (arready_m_inf[1])?(1'b0):(1'b1);
            r0        <= (arready_m_inf[1])?(8'd255):(r0);
            rwen      <= 1'b1;
            rrredy[1] <= 1'b0;
        end
        else if(r0 == 8'd127) begin
            r0             <= 8'd128;
            rarval[1]      <= 1'b0;
            rwen           <= 1'b1;
            rrredy[1]      <= 1'b0;
            rchk[pc[10:7]] <= 1'b1;
        end
        else begin
            if(rrredy[1]) begin
                rrredy[1] <= (rvalid_m_inf[1])?(1'b0):(rrredy[1]);
                r0        <= (rvalid_m_inf[1])?(r0 +1):(r0);
                rwen      <= (rvalid_m_inf[1])?(1'b0):(1'b1);
                rsrd      <= (rvalid_m_inf[1])?(rdata_m_inf[31:16]):(rsrd);
            end
            else begin
                rrredy[1] <= 1'b1;
                rwen      <= 1'b1;
            end
        end
    end
    else if(cst == exec) begin
        if(wi[15]) begin
            if(wi[13]) begin
                // beq
                pc <= (wrs == wrt)?(pc + 12'd01 + {{7{wi[4]}}, wi[4:0]}):(pc + 12'd01);
            end
            else begin
                // jump
                pc <= {(!wi[12] || wi[12:0] == 13'h1fff), wi[11:1]};
            end
            IO_stall <= 1'b0;
        end
        else begin
            if(wi[14]) begin
                // load store
                r0 <= r0;
            end
            else begin
                case(wi[4:1])
                4'd0:
                core_r0 <= walu;
                4'd1:
                core_r1 <= walu;
                4'd2:
                core_r2 <= walu;
                4'd3:
                core_r3 <= walu;
                4'd4:
                core_r4 <= walu;
                4'd5:
                core_r5 <= walu;
                4'd6:
                core_r6 <= walu;
                4'd7:
                core_r7 <= walu;
                4'd8:
                core_r8 <= walu;
                4'd9:
                core_r9 <= walu;
                4'd10:
                core_r10 <= walu;
                4'd11:
                core_r11 <= walu;
                4'd12:
                core_r12 <= walu;
                4'd13:
                core_r13 <= walu;
                4'd14:
                core_r14 <= walu;
                4'd15:
                core_r15 <= walu;
                default:
                core_r0 <= core_r0;
                endcase
                pc <= pc + 12'd01;
                IO_stall <= 1'b0;
            end
        end
    end
    else if(cst == memo) begin
        if(wi[13]) begin
            // load
            if(r0 == 8'd128) begin
                rarval[0] <= (arready_m_inf[0])?(1'b0):(1'b1);
                r0        <= (arready_m_inf[0])?(8'd0):(r0);
                rwen      <= 1'b1;
                rrredy[0] <= 1'b0;
            end
            else if(rrredy[0] && rvalid_m_inf[0]) begin
                rarval[0] <= 1'b0;
                rrredy[0] <= 1'b0;
                r0        <= 8'd128;
                case(wi[8:5])
                4'd0:
                core_r0  <= rdata_m_inf[15:0];
                4'd1:
                core_r1  <= rdata_m_inf[15:0];
                4'd2:
                core_r2  <= rdata_m_inf[15:0];
                4'd3:
                core_r3  <= rdata_m_inf[15:0];
                4'd4:
                core_r4  <= rdata_m_inf[15:0];
                4'd5:
                core_r5  <= rdata_m_inf[15:0];
                4'd6:
                core_r6  <= rdata_m_inf[15:0];
                4'd7:
                core_r7  <= rdata_m_inf[15:0];
                4'd8:
                core_r8  <= rdata_m_inf[15:0];
                4'd9:
                core_r9  <= rdata_m_inf[15:0];
                4'd10:
                core_r10 <= rdata_m_inf[15:0];
                4'd11:
                core_r11 <= rdata_m_inf[15:0];
                4'd12:
                core_r12 <= rdata_m_inf[15:0];
                4'd13:
                core_r13 <= rdata_m_inf[15:0];
                4'd14:
                core_r14 <= rdata_m_inf[15:0];
                4'd15:
                core_r15 <= rdata_m_inf[15:0];
                endcase
                pc <= pc + 12'd01;
                IO_stall <= 1'b0;
            end
            else begin
                rrredy[0] <= 1'b1;
                r0 <= r0;
            end
        end
        else begin
            // store
            if(r0 == 8'd128) begin
                rawval <= (awready_m_inf)?(1'b0):(1'b1);
                r0     <= (awready_m_inf)?(8'd0):(r0);
                rbredy <= (awready_m_inf)?(1'b1):(rbredy);
                rwval  <= 1'b0;
                rwlas  <= 1'b0;
            end
            else if(r0 == 8'd0) begin
                if(rwval) begin
                    rwval <= (wready_m_inf)?(1'b0):(rwval);
                    rwlas <= (wready_m_inf)?(1'b0):(rwlas);
                    r0    <= (wready_m_inf)?(8'd1):(r0);
                end
                else begin
                    rwval <= 1'b1;
                    rwlas <= 1'b1;
                end
            end
            else if(r0 == 8'd1) begin
                rbredy   <= (bvalid_m_inf)?(1'b0):(rbredy);
                r0       <= (bvalid_m_inf)?(8'd128):(r0);
                pc       <= (bvalid_m_inf)?(pc + 12'd01):(pc);
                IO_stall <= (bvalid_m_inf)?(1'b0):(IO_stall);
                rwval    <= 1'b0;
                rwlas    <= 1'b0;
            end
            else begin
                r0 <= r0;
            end
        end
    end
    else begin
        IO_stall <= 1'b1;
    end
end

always @(*) begin
    if(!rst_n) begin
        walu <= wrd;
    end
    else begin
        case({wi[13], wi[0]})
        2'b01:
        walu <= wrs + wrt;
        2'b00:
        walu <= wrs - wrt;
        2'b11:
        walu <= (wrs < wrt)?(16'd1):(16'd0);
        2'b10:
        walu <= wrs * wrt;
        default:
        walu <= wrd;
        endcase
    end
end

always @(*) begin
    if(!rst_n) begin
        wrs <= 16'b0;
    end
    else begin
        case(wi[12:9])
        4'd0:
        wrs <= core_r0;
        4'd1:
        wrs <= core_r1;
        4'd2:
        wrs <= core_r2;
        4'd3:
        wrs <= core_r3;
        4'd4:
        wrs <= core_r4;
        4'd5:
        wrs <= core_r5;
        4'd6:
        wrs <= core_r6;
        4'd7:
        wrs <= core_r7;
        4'd8:
        wrs <= core_r8;
        4'd9:
        wrs <= core_r9;
        4'd10:
        wrs <= core_r10;
        4'd11:
        wrs <= core_r11;
        4'd12:
        wrs <= core_r12;
        4'd13:
        wrs <= core_r13;
        4'd14:
        wrs <= core_r14;
        4'd15:
        wrs <= core_r15;
        default:
        wrs <= 16'b0;
        endcase
    end
end

always @(*) begin
    if(!rst_n) begin
        wrt <= 16'b0;
    end
    else begin
        case(wi[8:5])
        4'd0:
        wrt <= core_r0;
        4'd1:
        wrt <= core_r1;
        4'd2:
        wrt <= core_r2;
        4'd3:
        wrt <= core_r3;
        4'd4:
        wrt <= core_r4;
        4'd5:
        wrt <= core_r5;
        4'd6:
        wrt <= core_r6;
        4'd7:
        wrt <= core_r7;
        4'd8:
        wrt <= core_r8;
        4'd9:
        wrt <= core_r9;
        4'd10:
        wrt <= core_r10;
        4'd11:
        wrt <= core_r11;
        4'd12:
        wrt <= core_r12;
        4'd13:
        wrt <= core_r13;
        4'd14:
        wrt <= core_r14;
        4'd15:
        wrt <= core_r15;
        default:
        wrt <= 16'b0;
        endcase
    end
end

always @(*) begin
    if(!rst_n) begin
        wrd <= 16'b0;
    end
    else begin
        case(wi[4:1])
        4'd0:
        wrd <= core_r0;
        4'd1:
        wrd <= core_r1;
        4'd2:
        wrd <= core_r2;
        4'd3:
        wrd <= core_r3;
        4'd4:
        wrd <= core_r4;
        4'd5:
        wrd <= core_r5;
        4'd6:
        wrd <= core_r6;
        4'd7:
        wrd <= core_r7;
        4'd8:
        wrd <= core_r8;
        4'd9:
        wrd <= core_r9;
        4'd10:
        wrd <= core_r10;
        4'd11:
        wrd <= core_r11;
        4'd12:
        wrd <= core_r12;
        4'd13:
        wrd <= core_r13;
        4'd14:
        wrd <= core_r14;
        4'd15:
        wrd <= core_r15;
        default:
        wrd <= 16'b0;
        endcase
    end
end
endmodule
