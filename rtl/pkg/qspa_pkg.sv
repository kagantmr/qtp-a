package qspa_pkg;
  parameter INSTRUCTION_WIDTH = 32;
  parameter DATA_WIDTH = 32;

  parameter S0_IDX  = 4'd0;  // Hardwired zero
  parameter S13_IDX = 4'd13; // Tile size / loop bound
  parameter S14_IDX = 4'd14; // Scale factor
  parameter S15_IDX = 4'd15; // Status Register (SR)

  // Hardware Flags
  parameter FLAG_ZERO  = 0;
  parameter FLAG_OVF   = 1;
  parameter FLAG_CARRY = 2;

  // Queue/State Flags (Set by Elevator/Issue stage)
  parameter FLAG_IQ_EMPTY    = 3;
  parameter FLAG_DQ_EMPTY    = 4;
  parameter FLAG_SPARSE_MODE = 5;
  parameter FLAG_LOOP_ACTIVE = 6;
  parameter FLAG_STALL       = 7;

  typedef enum logic [5:0] { 
    NOP     = 6'h00,
    BRANCH  = 6'h01,
    LOOP    = 6'h02,
    HALT    = 6'h03,
    YIELD   = 6'h04,

    ADD_IMM     = 6'h11,
    SUB_IMM     = 6'h12,
    AND_IMM     = 6'h13,
    OR_IMM      = 6'h14,
    CMP_IMM     = 6'h15,
    MOV_IMM     = 6'h16,

    ADD_REG     = 6'h17,
    SUB_REG     = 6'h18,
    AND_REG     = 6'h19,
    OR_REG      = 6'h1A,
    CMP_REG     = 6'h1B,
    MOV_REG     = 6'h1C,

    SHL_IMM     = 6'h1D,
    SHL_REG     = 6'h1E,
    SHR_IMM     = 6'h1F,
    SHR_REG     = 6'h20,

    LCSET_IMM   = 6'h21,
    LCSET_REG   = 6'h22

  } op_t;

   // Vector Format (V-Type)
  typedef struct packed {
    logic [5:0]  opcode;
    logic [3:0]  vd;
    logic [3:0]  vs1;
    logic [3:0]  vs2;
    logic [13:0] imm14;
  } instr_v_t;

  // Scalar Register-Immediate Format (SI-Type)
  typedef struct packed {
    logic [5:0]  opcode;
    logic [3:0]  sd;
    logic [3:0]  ss1;
    logic [17:0] imm18;
  } instr_si_t;

  // Scalar Register-Register Format (SR-Type)
  typedef struct packed {
    logic [5:0]  opcode;
    logic [3:0]  sd;
    logic [3:0]  ss1;
    logic [3:0]  ss2;
    logic [13:0] reserved;
  } instr_sr_t;

  // Control Format (C-Type)
  typedef struct packed {
    logic [5:0]  opcode;
    logic [3:0]  reserved_qid;
    logic [3:0]  ss1;
    logic [17:0] imm18;
  } instr_c_t;
endpackage