module bridge(input clk, INF.bridge_inf inf);

// logic [63:0] rd0;

always_ff @(posedge clk, negedge inf.rst_n) begin : blockName
    if(!inf.rst_n) begin
        inf.C_out_valid <= 'b0;
        inf.C_data_r <= 'b0;
        inf.AR_VALID <= 'b0;
        inf.AR_ADDR <= 'b0;
        inf.R_READY <= 'b0;
        inf.AW_VALID <= 'b0;
        inf.AW_ADDR <= 'b0;
        inf.W_VALID <= 'b0;
        inf.W_DATA <= 'b0;
        inf.B_READY <= 'b0;
    end
    else if(inf.C_in_valid) begin
        inf.AR_ADDR <= (17'h10000 + 17'h00008 * inf.C_addr);
        inf.AW_ADDR <= (17'h10000 + 17'h00008 * inf.C_addr);
        inf.W_DATA <= inf.C_data_w;
        inf.AR_VALID <= (inf.C_r_wb);
        inf.AW_VALID <= !(inf.C_r_wb);
    end
    else if(inf.AR_READY) begin
        inf.AR_VALID <= 1'b0;
        inf.R_READY <= 1'b1;
    end
    else if(inf.R_VALID) begin
        inf.R_READY <= 1'b0;
        inf.C_data_r <= inf.R_DATA;
        inf.C_out_valid <= 1'b1;
    end
    else if(inf.AW_READY) begin
        inf.AW_VALID <= 1'b0;
        inf.W_VALID <= 1'b1;
        inf.B_READY <= 1'b1;
    end
    else if(inf.W_READY) begin
        inf.W_VALID <= 1'b0;
    end
    else if(inf.B_VALID) begin
        inf.B_READY <= 1'b0;
        inf.C_out_valid <= 1'b1;
    end
    else begin
        inf.C_out_valid <= 'b0;
        inf.C_data_r <= 'b0;
    end
end
endmodule