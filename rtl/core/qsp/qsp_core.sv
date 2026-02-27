import qspa_pkg::*;

module qsp_core (
    input  logic         clk,
    input  logic         rst_n,

    // Instruction Input (from IQ0)
    input  logic [31:0]  instruction,

    // Status Output
    output logic [31:0]  status_out,
    output logic         illegal // Optional for now, can be used to indicate illegal instructions
);

    // --------- internal signals ---------

    // decode stage
    op_t                   dec_alu_op;
    logic [3:0]            dec_rs1_addr, dec_rs2_addr, dec_rd_addr;
    logic [DATA_WIDTH-1:0] dec_imm_ext;
    logic                  dec_we, dec_use_imm;
    logic [DATA_WIDTH-1:0] reg_rs1_data, reg_rs2_data; // regfile

    // issue stage
    op_t                   iss_alu_op;
    logic [3:0]            iss_rs1_addr, iss_rs2_addr, iss_rd_addr;
    logic [DATA_WIDTH-1:0] iss_imm_ext;
    logic                  iss_we, iss_use_imm;
    logic [DATA_WIDTH-1:0] iss_rs1_data, iss_rs2_data;

    // execute stage
    op_t                   ex_alu_op;
    logic [3:0]            ex_rs1_addr, ex_rs2_addr, ex_rd_addr;
    logic [DATA_WIDTH-1:0] ex_imm_ext;
    logic                  ex_we, ex_use_imm;
    logic [DATA_WIDTH-1:0] ex_rs1_data, ex_rs2_data;
    
    // alu wires
    logic [DATA_WIDTH-1:0] alu_result;
    logic [DATA_WIDTH-1:0] alu_op2_final;
    logic                  f_zero, f_carry, f_ovf;

    // wb wires
    logic [DATA_WIDTH-1:0] wb_alu_result;
    logic [3:0]            wb_rd_addr;
    logic                  wb_we;
    logic                  wb_flag_zero, wb_flag_carry, wb_flag_ovf;

    // execute stage flag wires
    logic                  ex_flag_zero, ex_flag_carry, ex_flag_ovf;

    // forwarding wires
    logic [DATA_WIDTH-1:0] fwd_rs1_data;
    logic [DATA_WIDTH-1:0] fwd_rs2_data;

    // alu op2 selection
    assign alu_op2_final = ex_use_imm ? ex_imm_ext : fwd_rs2_data;


    // QSP REGISTER FILE
    qsp_regfile regfile_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .rs1_addr       (dec_rs1_addr),
        .rs2_addr       (dec_rs2_addr),
        .rs1_data       (reg_rs1_data),
        .rs2_data       (reg_rs2_data),
        .we             (wb_we),
        .rd_addr        (wb_rd_addr),
        .rd_data        (wb_alu_result),
        .flag_zero      (wb_flag_zero),
        .flag_carry     (wb_flag_carry),
        .flag_ovf       (wb_flag_ovf),
        .flag_we        (wb_we),  // Update flags whenever we write to register
        .status_reg_out (status_out)
    );

    // QSP DECODE
    qsp_decode decode_inst (
        .instruction (instruction),
        .rs1_addr    (dec_rs1_addr),
        .rs2_addr    (dec_rs2_addr),
        .rd_addr     (dec_rd_addr),
        .we          (dec_we),
        .alu_op      (dec_alu_op),
        .imm_ext     (dec_imm_ext),
        .use_imm     (dec_use_imm),
        .illegal     (illegal) // Unused
    );

    //
    pipe_reg_dec_iss pr_dec_iss (
        .clk          (clk),
        .rst          (!rst_n),
        .stall        (1'b0), // Fixed for Phase 1
        .flush        (1'b0), // Fixed for Phase 1
        .dec_alu_op   (dec_alu_op),
        .dec_rd_addr  (dec_rd_addr),
        .dec_we       (dec_we),
        .dec_imm_ext  (dec_imm_ext),
        .dec_use_imm  (dec_use_imm),
        .dec_rs1_data (reg_rs1_data),
        .dec_rs2_data (reg_rs2_data),
        .dec_rs1_addr (dec_rs1_addr),
        .dec_rs2_addr (dec_rs2_addr),
        .iss_alu_op   (iss_alu_op),
        .iss_rd_addr  (iss_rd_addr),
        .iss_we       (iss_we),
        .iss_imm_ext  (iss_imm_ext),
        .iss_use_imm  (iss_use_imm),
        .iss_rs1_data (iss_rs1_data),
        .iss_rs2_data (iss_rs2_data),
        .iss_rs1_addr (iss_rs1_addr),
        .iss_rs2_addr (iss_rs2_addr)
    );

    // TODO: Instantiate pipe_reg_iss_ex
    pipe_reg_iss_ex pr_iss_ex (
        .clk          (clk),
        .rst          (!rst_n),
        .stall        (1'b0), // Fixed for Phase 1
        .flush        (1'b0), // Fixed for Phase 1
        .iss_alu_op   (iss_alu_op),
        .iss_rd_addr  (iss_rd_addr),
        .iss_we       (iss_we),
        .iss_imm_ext  (iss_imm_ext),
        .iss_use_imm  (iss_use_imm),
        .iss_rs1_data (iss_rs1_data),
        .iss_rs2_data (iss_rs2_data),
        .iss_rs1_addr (iss_rs1_addr),
        .iss_rs2_addr (iss_rs2_addr),
        .ex_alu_op    (ex_alu_op),
        .ex_rd_addr   (ex_rd_addr),
        .ex_we        (ex_we),
        .ex_imm_ext   (ex_imm_ext),
        .ex_use_imm   (ex_use_imm),
        .ex_rs1_data  (ex_rs1_data),
        .ex_rs2_data  (ex_rs2_data),
        .ex_rs1_addr  (ex_rs1_addr),
        .ex_rs2_addr  (ex_rs2_addr)
    );

    qsp_alu alu_inst (
        .alu_op       (ex_alu_op),
        .op1      (fwd_rs1_data),
        .op2      (alu_op2_final),
        .result   (alu_result),
        .flag_zero   (f_zero),
        .flag_carry  (f_carry),
        .flag_ovf    (f_ovf)
    );

    pipe_reg_ex_wb pr_ex_wb (
        .clk             (clk),
        .rst             (!rst_n),
        .stall           (1'b0), // Fixed for Phase 1
        .flush           (1'b0), // Fixed for Phase 1
        .ex_alu_result   (alu_result),
        .ex_rd_addr      (ex_rd_addr),
        .ex_we           (ex_we),
        .ex_flag_zero    (f_zero),
        .ex_flag_carry   (f_carry),
        .ex_flag_ovf     (f_ovf),
        .wb_alu_result   (wb_alu_result),
        .wb_rd_addr      (wb_rd_addr),
        .wb_we           (wb_we),
        .wb_flag_zero    (wb_flag_zero),
        .wb_flag_carry   (wb_flag_carry),
        .wb_flag_ovf     (wb_flag_ovf)
    );

    always_comb begin : forwarding_logic
        // use data from EX stage by default
        fwd_rs1_data = ex_rs1_data;
        fwd_rs2_data = ex_rs2_data;

        // forwarding for Operand 1
        if (wb_we && (wb_rd_addr != S0_IDX) && (wb_rd_addr == ex_rs1_addr)) begin
            fwd_rs1_data = wb_alu_result;
        end

        // forwarding for Operand 2
        if (wb_we && (wb_rd_addr != S0_IDX) && (wb_rd_addr == ex_rs2_addr)) begin
            fwd_rs2_data = wb_alu_result;
        end
    end

endmodule
