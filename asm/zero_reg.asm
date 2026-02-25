MOV_IMM S0, S0, #99    // Try to write 99 to S0 (Should fail/ignore)
ADD_IMM S1, S0, #10    // S1 = 0 + 10 = 10
MOV_REG S2, S0, S0     // S2 = 0
SUB_IMM S3, S0, #1     // S3 = 0 - 1 = -1 (0xFFFFFFFF)
NOP S0, S0, S0