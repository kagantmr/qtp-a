import qtpa_pkg::*;

module pipe_reg_iss_ex (
    input  logic                  clk,
    input  logic                  rst,
    
    // Pipeline Control
    input  logic                  stall,
    input  logic                  flush,

    // Inputs from ISSUE stage
    input  op_t                   iss_alu_op,
    input  logic [3:0]            iss_rd_addr,
    input  logic                  iss_we,
    input  logic [DATA_WIDTH-1:0] iss_imm_ext,
    input  logic                  iss_use_imm,
    input  logic [DATA_WIDTH-1:0] iss_rs1_data,
    input  logic [DATA_WIDTH-1:0] iss_rs2_data,
    input  logic [3:0]            iss_rs1_addr,
    input  logic [3:0]            iss_rs2_addr,

    // Outputs to EXECUTE stage (ALU inputs)
    output op_t                   ex_alu_op,
    output logic [3:0]            ex_rd_addr,
    output logic                  ex_we,
    output logic [DATA_WIDTH-1:0] ex_imm_ext,
    output logic                  ex_use_imm,
    output logic [DATA_WIDTH-1:0] ex_rs1_data,
    output logic [DATA_WIDTH-1:0] ex_rs2_data,
    output logic [3:0]            ex_rs1_addr,
    output logic [3:0]            ex_rs2_addr
);

    always @(posedge clk) begin
        if (rst) begin
            ex_alu_op    <= NOP;
            ex_rd_addr   <= 'b0;
            ex_we        <= 1'b0;
            ex_imm_ext   <= 'b0;
            ex_use_imm   <= 1'b0;
            ex_rs1_data  <= 'b0;
            ex_rs2_data  <= 'b0;
            ex_rs1_addr  <= 'b0;
            ex_rs2_addr  <= 'b0;
        end else if (flush) begin
            ex_alu_op    <= NOP;
            ex_rd_addr   <= 'b0;
            ex_we        <= 1'b0;
            ex_imm_ext   <= 'b0;
            ex_use_imm   <= 1'b0;
            ex_rs1_data  <= 'b0;
            ex_rs2_data  <= 'b0;
            ex_rs1_addr  <= 'b0;
            ex_rs2_addr  <= 'b0;
        end else if (stall) begin
            // Hold current values (do nothing)
        end else begin
            ex_alu_op    <= iss_alu_op;
            ex_rd_addr   <= iss_rd_addr;
            ex_we        <= iss_we;
            ex_imm_ext   <= iss_imm_ext;
            ex_use_imm   <= iss_use_imm;
            ex_rs1_data  <= iss_rs1_data;
            ex_rs2_data  <= iss_rs2_data;
            ex_rs1_addr  <= iss_rs1_addr;
            ex_rs2_addr  <= iss_rs2_addr;
        end
    end

endmodule