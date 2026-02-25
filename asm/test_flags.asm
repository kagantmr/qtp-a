// Test flag updates to S15
// Test ZERO flag: S0 = 0, comparing zeros should set flag
ADD_IMM S1, S0, #0

// Test CARRY flag by adding large numbers
ADD_IMM S2, S0, #-1
ADD_REG S3, S2, S1

// Test with MOV
MOV_IMM S4, S0, #0

NOP
NOP
NOP
