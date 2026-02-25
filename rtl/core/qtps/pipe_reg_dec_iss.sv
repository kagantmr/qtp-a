import qtpa_pkg::*;

module pipe_reg_dec_iss (
    input  logic                  clk,
    input  logic                  rst,
    
    input  logic                  stall, // Holds the current values if 1
    input  logic                  flush, // Clears the register (e.g., on branch)

    // Inputs from DECODE stage (and RegFile read ports)
    input  op_t                   dec_alu_op,
    input  logic [3:0]            dec_rd_addr,
    input  logic                  dec_we,
    input  logic [DATA_WIDTH-1:0] dec_imm_ext,
    input  logic                  dec_use_imm,
    input  logic [DATA_WIDTH-1:0] dec_rs1_data,
    input  logic [DATA_WIDTH-1:0] dec_rs2_data,
    input  logic [3:0]            dec_rs1_addr,
    input  logic [3:0]            dec_rs2_addr,

    // Outputs to ISSUE stage
    output op_t                   iss_alu_op,
    output logic [3:0]            iss_rd_addr,
    output logic                  iss_we,
    output logic [DATA_WIDTH-1:0] iss_imm_ext,
    output logic                  iss_use_imm,
    output logic [3:0] iss_rs1_addr,
    output logic [3:0] iss_rs2_addr,
    output logic [DATA_WIDTH-1:0] iss_rs1_data,
    output logic [DATA_WIDTH-1:0] iss_rs2_data
);

    always @(posedge clk) begin
        if (rst) begin
            iss_alu_op    <= NOP;
            iss_rd_addr   <= 'b0;
            iss_we        <= 1'b0;
            iss_imm_ext   <= 'b0;
            iss_use_imm   <= 1'b0;
            iss_rs1_data  <= 'b0;
            iss_rs2_data  <= 'b0;
            iss_rs1_addr  <= 'b0;
            iss_rs2_addr  <= 'b0;
        end else if (flush) begin
            iss_alu_op    <= NOP;
            iss_rd_addr   <= 'b0;
            iss_we        <= 1'b0;
            iss_imm_ext   <= 'b0;
            iss_use_imm   <= 1'b0;
            iss_rs1_data  <= 'b0;
            iss_rs2_data  <= 'b0;
            iss_rs1_addr  <= 'b0;
            iss_rs2_addr  <= 'b0;
        end else if (stall) begin
            // Hold current values (do nothing)
        end else begin
            iss_alu_op    <= dec_alu_op;
            iss_rd_addr   <= dec_rd_addr;
            iss_we        <= dec_we;
            iss_imm_ext   <= dec_imm_ext;
            iss_use_imm   <= dec_use_imm;
            iss_rs1_data  <= dec_rs1_data;
            iss_rs2_data  <= dec_rs2_data;
            iss_rs1_addr  <= dec_rs1_data;
            iss_rs2_addr  <= dec_rs2_data;
        end
    end

endmodule