import qspa_pkg::*;

module qsp_decode (
    // Input from IQ0
    input  logic [INSTRUCTION_WIDTH-1:0] instruction,

    // Register file controls
    output logic [3:0]                   rs1_addr,
    output logic [3:0]                   rs2_addr,
    output logic [3:0]                   rd_addr,
    output logic                         we,       // write enable

    // ALU controls
    output op_t                          alu_op,      // Decoded opcode
    output logic [DATA_WIDTH-1:0]        imm_ext,  // Sign-extended immediate
    output logic                         use_imm,   // 1 if instruction uses immediate, 0 if register
    output logic                         illegal   // Indicates if the instruction is valid (for future use)
);

    // Cast the instruction 
    instr_v_t  instr_v;
    instr_si_t instr_si;
    instr_sr_t instr_sr;
    instr_c_t  instr_c;

    always_comb begin
        instr_v  = instruction;
        instr_si = instruction;
        instr_sr = instruction;
        instr_c  = instruction;

        // The opcode is always in the same place across all formats
        alu_op = op_t'(instruction[31:26]); 

        // Defaults
        rs1_addr = 4'b0;
        rs2_addr = 4'b0;
        rd_addr  = 4'b0;
        imm_ext  = 'b0;
        use_imm  = 1'b0;
        we       = 1'b0;
        illegal  = 1'b0;

        case (alu_op)
            ADD_IMM, SHL_IMM, SHR_IMM, LCSET_IMM, SUB_IMM, CMP_IMM, MOV_IMM: begin
                // route addresses using the SI struct
                rs1_addr = instr_si.ss1;
                rd_addr  = instr_si.sd;
                
                // sign extend the immediate
                imm_ext = $signed(instr_si.imm18);
                
                // control signals
                use_imm = 1'b1;           // This instruction uses an immediate
                we = (alu_op != CMP_IMM) && (alu_op != LCSET_IMM);
            end

            ADD_REG, SHL_REG, SHR_REG, LCSET_REG,  SUB_REG, CMP_REG, MOV_REG: begin
                rs1_addr = instr_sr.ss1;
                rs2_addr = instr_sr.ss2;
                rd_addr  = instr_sr.sd;
                
                use_imm = 1'b0;           // This instruction uses registers, not an immediate
                we = (alu_op != CMP_REG) && (alu_op != LCSET_REG);
            end

            BRANCH, LOOP, HALT, YIELD, NOP: begin
                rs1_addr = instr_c.ss1;
                
                imm_ext = $signed(instr_c.imm18); // Sign-extend the immediate just in case
                use_imm = 1'b1; // Doesn't matter much since ALU output isn't saved, but safely routes imm
                we      = 1'b0; // Control instructions NEVER write to the register file
            end

            default: begin
                // Defaults are already set at the top of the always_comb block.
                illegal = 1'b1; //  for future handling
            end
        endcase
    end

endmodule
