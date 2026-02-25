import qtpa_pkg::*;

module qtps_alu (
    // Control
    input  op_t                alu_op, // The decoded operation from the enum

    // Operands
    input  logic [DATA_WIDTH-1:0] op1,    // Usually Ss1
    input  logic [DATA_WIDTH-1:0] op2,    // Ss2 or the Sign-Extended Immediate

    // Result
    output logic [DATA_WIDTH-1:0] result,

    // Hardware flags
    output logic                  flag_zero,
    output logic                  flag_carry,
    output logic                  flag_ovf
);

  always_comb begin : alu_case
    case (alu_op)
      ADD_IMM, ADD_REG: begin
        {flag_carry, result} = op1 + op2; // Capture carry-out
        flag_ovf = ((op1[DATA_WIDTH-1] == op2[DATA_WIDTH-1]) && (result[DATA_WIDTH-1] != op1[DATA_WIDTH-1]));
        flag_zero = (result == 0);
      end

      SUB_IMM, SUB_REG: begin
        {flag_carry, result} = op1 - op2; // Capture borrow as carry-out
        flag_ovf = ((op1[DATA_WIDTH-1] != op2[DATA_WIDTH-1]) && (result[DATA_WIDTH-1] != op1[DATA_WIDTH-1]));
        flag_zero = (result == 0);
      end

      AND_IMM, AND_REG: begin
        result = op1 & op2;
        flag_zero = (result == 0);
        flag_carry = 0; // No carry for AND
        flag_ovf = 0;   // No overflow for AND
      end

      OR_IMM, OR_REG: begin
        result = op1 | op2;
        flag_zero = (result == 0);
        flag_carry = 0; // No carry for OR
        flag_ovf = 0;   // No overflow for OR
      end

      CMP_IMM, CMP_REG: begin
        logic [DATA_WIDTH-1:0] cmp_result;
        {flag_carry, cmp_result} = op1 - op2; // Capture borrow as carry-out
        flag_ovf = ((op1[DATA_WIDTH-1] != op2[DATA_WIDTH-1]) && (cmp_result[DATA_WIDTH-1] != op1[DATA_WIDTH-1]));
        flag_zero = (cmp_result == 0);
        result = 'b0; // CMP does not produce a meaningful result in the register file
      end

      MOV_IMM, MOV_REG: begin
        result = op2; // For MOV, the second operand is the value to move
        flag_zero = (result == 0);
        flag_carry = 0; // No carry for MOV
        flag_ovf = 0;   // No overflow for MOV
      end

      SHL_IMM, SHL_REG: begin
        result = op1 << op2[$clog2(DATA_WIDTH)-1:0]; // Only use the bottom bits of op2 for shift amount
        flag_zero = (result == 0);
        flag_carry = 0;
        flag_ovf = 0;
      end

      SHR_IMM, SHR_REG: begin
        // Use >>> for arithmetic shift right (preserves sign bit)
        // Note: op1 needs to be cast to signed for >>> to work correctly in SV
        result = $signed(op1) >>> op2[$clog2(DATA_WIDTH)-1:0]; 
        flag_zero = (result == 0);
        flag_carry = 0;
        flag_ovf = 0;
      end

      LCSET_IMM, LCSET_REG: begin
        // LCSET doesn't do math, it just passes the value through the ALU 
        // so the Writeback stage can route it to the Elevator.
        result = op1; 
        flag_zero = 0;
        flag_carry = 0;
        flag_ovf = 0;
      end

      default: begin
        result = 'b0;
        flag_zero = 1'b0;
        flag_carry = 1'b0;
        flag_ovf = 1'b0;
      end
    endcase
  end

endmodule
