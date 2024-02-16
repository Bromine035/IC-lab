`ifdef RTL
`define CYCLE_TIME 5.0
`endif
`ifdef GATE
`define CYCLE_TIME 5.0
`endif


`ifdef FUNC
`define PAT_NUM 500
`endif
`ifdef PERF
`define PAT_NUM 500
`endif

`include "../00_TESTBED/MEM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM.v"

module PATTERN #(parameter ID_WIDTH=4, DATA_WIDTH=32, ADDR_WIDTH=32)(
        
				clk,	
			  rst_n,	
	
			in_addr_M,
			in_addr_G,
			in_dir,
			in_dis,
			in_valid,
			out_valid, 
	

         awid_s_inf,
       awaddr_s_inf,
       awsize_s_inf,
      awburst_s_inf,
        awlen_s_inf,
      awvalid_s_inf,
      awready_s_inf,
                    
        wdata_s_inf,
        wlast_s_inf,
       wvalid_s_inf,
       wready_s_inf,
                    
          bid_s_inf,
        bresp_s_inf,
       bvalid_s_inf,
       bready_s_inf,
                    
         arid_s_inf,
       araddr_s_inf,
        arlen_s_inf,
       arsize_s_inf,
      arburst_s_inf,
      arvalid_s_inf,
                    
      arready_s_inf, 
          rid_s_inf,
        rdata_s_inf,
        rresp_s_inf,
        rlast_s_inf,
       rvalid_s_inf,
       rready_s_inf 
             );




//Connection wires
output reg			  clk,rst_n;
        
// -----------------------------
// IO port
output reg [ADDR_WIDTH-1:0]      in_addr_M;
output reg [ADDR_WIDTH-1:0]      in_addr_G;
output reg [1:0]  	  		in_dir;
output reg [3:0]	    	in_dis;
output reg 			    	in_valid;
input	              out_valid;
// -----------------------------

reg [ADDR_WIDTH-1:0]      gold_addr_G;


// axi write address channel 
input wire [ID_WIDTH-1:0]        awid_s_inf;
input wire [ADDR_WIDTH-1:0]    awaddr_s_inf;
input wire [2:0]            awsize_s_inf;
input wire [1:0]           awburst_s_inf;
input wire [3:0]             awlen_s_inf;
input wire                 awvalid_s_inf;
output wire                awready_s_inf;
// axi write data channel 
input wire [DATA_WIDTH-1:0]     wdata_s_inf;
input wire                   wlast_s_inf;
input wire                  wvalid_s_inf;
output wire                 wready_s_inf;
// axi write response channel
output wire [ID_WIDTH-1:0]         bid_s_inf;
output wire [1:0]             bresp_s_inf;
output wire              	  bvalid_s_inf;
input wire                    bready_s_inf;
// -----------------------------
// axi read address channel 
input wire [ID_WIDTH-1:0]       arid_s_inf;
input wire [ADDR_WIDTH-1:0]   araddr_s_inf;
input wire [3:0]            arlen_s_inf;
input wire [2:0]           arsize_s_inf;
input wire [1:0]          arburst_s_inf;
input wire                arvalid_s_inf;
output wire               arready_s_inf;
// -----------------------------
// axi read data channel 
output wire [ID_WIDTH-1:0]         rid_s_inf;
output wire [DATA_WIDTH-1:0]     rdata_s_inf;
output wire [1:0]             rresp_s_inf;
output wire                   rlast_s_inf;
output wire                  rvalid_s_inf;
input wire                   rready_s_inf;
// -----------------------------



//pragma protect begin_protected
//pragma protect encrypt_agent="NCPROTECT"
//pragma protect encrypt_agent_info="Encrypted using API"
//pragma protect key_keyowner=Cadence Design Systems.
//pragma protect key_keyname=prv(CDS_RSA_KEY_VER_1)
//pragma protect key_method=RSA
//pragma protect key_block
D1qHe7o/JJKdBGucvvBvuP2jjBn0SAG6Ht++8FwCLN4KCe2AW6mz48tIblbvFxhf
7/TANDJGa7yKGCMzbO4Q/6HGwR7jYFWvpHRLX88hwcDxlLE02d/v3FgzB0zj/+R2
LhCfKujTbq3mywBpohFjdh8frg0kP3rTkn+lgznjANgVXBDkCzu53pFLKQPFDwKO
MvKAZ2vZcnuJP6Fh95Y56DGDTRKqEMgmExzS7nGmxaOsJ7E7+cTwpiPGp6p7SFoM
lmWW+F+4LPi4rL+Z7m0NsHa1AIDoWPPWA6ih9+udstqLW8xuEfa9mZfms/tSxYyx
k+UFOB0oiLFMxb21SFJPWw==
//pragma protect end_key_block
//pragma protect digest_block
WeSfj88UdPlHycGWSB0ZHXHOoyc=
//pragma protect end_digest_block
//pragma protect data_block
+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
//pragma protect end_data_block
//pragma protect digest_block
EKgpQ7QYkflRA2dH8p2MPr84YLI=
//pragma protect end_digest_block
//pragma protect end_protected

