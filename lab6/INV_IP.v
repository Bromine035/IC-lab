//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright Optimum Application-Specific Integrated System Laboratory
//    All Right Reserved
//		Date		: 2023/03
//		Version		: v1.0
//   	File Name   : INV_IP.v
//   	Module Name : INV_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module INV_IP #(parameter IP_WIDTH = 6) (
    // Input signals
    IN_1, IN_2,
    // Output signals
    OUT_INV
);

// ===============================================================
// Declaration
// ===============================================================
input  [IP_WIDTH-1:0] IN_1, IN_2;
output [IP_WIDTH-1:0] OUT_INV;

wire signed [IP_WIDTH:0] wp, wf, wpp;
assign wp = (IN_1 > IN_2)?({1'b0, IN_1}):({1'b0, IN_2});
assign wf = (IN_1 > IN_2)?({1'b0, IN_2}):({1'b0, IN_1});

genvar i0;
generate
    for(i0 = 0; i0 < IP_WIDTH+4; i0 = i0 + 1) begin : fl0
        wire signed [IP_WIDTH:0] wa, wb, wv, wd, ws, wt;
        assign wv = wa/wb;
        if(i0 == 0) begin
            assign wa = wf;
            assign wb = wp;
        end
        else begin
            assign wa = fl0[i0-1].wb;
            assign wb = fl0[i0-1].wa%fl0[i0-1].wb;
        end

        if(i0 == IP_WIDTH+3) begin
            assign wd = wa;
            assign ws = 'b1;
            assign wt = 'b0;
        end
        else begin
            assign wd = (wb == 0)?(wa):(fl0[i0+1].wd);
            assign ws = (wb == 0)?('b1):(fl0[i0+1].wt);
            assign wt = (wb == 0)?('b0):(fl0[i0+1].ws - wv*fl0[i0+1].wt);
        end
    end
endgenerate
assign wpp = (fl0[0].ws + wp);
assign OUT_INV = (fl0[0].ws[IP_WIDTH])?(wpp[IP_WIDTH-1:0]):(fl0[0].ws[IP_WIDTH-1:0]);
endmodule