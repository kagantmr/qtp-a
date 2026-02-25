import qtpa_pkg::*;

module pipe_reg_ex_wb (
    input  logic                  clk,
    input  logic                  rst,
    
    input  logic                  stall,
    input  logic                  flush,

    // Inputs from EXECUTE stage 
    input  logic [DATA_WIDTH-1:0] ex_alu_result,
    input  logic [3:0]            ex_rd_addr,
    input  logic                  ex_we,
    input  logic                  ex_flag_zero,
    input  logic                  ex_flag_carry,
    input  logic                  ex_flag_ovf,

    // Outputs to WRITEBACK stage
    output logic [DATA_WIDTH-1:0] wb_alu_result,
    output logic [3:0]            wb_rd_addr,
    output logic                  wb_we,
    output logic                  wb_flag_zero,
    output logic                  wb_flag_carry,
    output logic                  wb_flag_ovf
);

    always @(posedge clk) begin
        if (rst) begin
            wb_alu_result <= 'b0;
            wb_rd_addr    <= 'b0;
            wb_we         <= 1'b0;
            wb_flag_zero  <= 1'b0;
            wb_flag_carry <= 1'b0;
            wb_flag_ovf   <= 1'b0;
        end else if (flush) begin
            wb_alu_result <= 'b0;
            wb_rd_addr    <= 'b0;
            wb_we         <= 1'b0;
            wb_flag_zero  <= 1'b0;
            wb_flag_carry <= 1'b0;
            wb_flag_ovf   <= 1'b0;
        end else if (stall) begin
            // Hold current values (do nothing)
        end else begin
            wb_alu_result <= ex_alu_result;
            wb_rd_addr    <= ex_rd_addr;
            wb_we         <= ex_we;
            wb_flag_zero  <= ex_flag_zero;
            wb_flag_carry <= ex_flag_carry;
            wb_flag_ovf   <= ex_flag_ovf;
        end
    end

endmodule