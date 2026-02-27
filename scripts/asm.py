import sys
import argparse

# opcodes
OPCODES = {
    # Control Instructions
    'NOP':       0x00,
    'BRANCH':    0x01,
    'LOOP':      0x02,
    'HALT':      0x03,
    'YIELD':     0x04,

    # Scalar Immediate Instructions
    'ADD_IMM':   0x11,
    'SUB_IMM':   0x12,
    'AND_IMM':   0x13,
    'OR_IMM':    0x14,
    'CMP_IMM':   0x15,
    'MOV_IMM':   0x16,

    # Scalar Register Instructions
    'ADD_REG':   0x17,
    'SUB_REG':   0x18,
    'AND_REG':   0x19,
    'OR_REG':    0x1A,
    'CMP_REG':   0x1B,
    'MOV_REG':   0x1C,

    # Shifts
    'SHL_IMM':   0x1D,
    'SHL_REG':   0x1E,
    'SHR_IMM':   0x1F,
    'SHR_REG':   0x20,

    # Loop Counter
    'LCSET_IMM': 0x21,
    'LCSET_REG': 0x22
}

REGS = {f'S{i}': i for i in range(16)}

def assemble_line(line, line_num):
    line = line.split('//')[0].split(';')[0].strip()
    if not line:
        return None
        
    parts = line.replace(',', ' ').split()
    instr = parts[0].upper()
    
    if instr not in OPCODES:
        print(f"Error at line {line_num}: Unknown/illegal instruction {instr}")
        sys.exit(1)
        
    opcode = OPCODES[instr]
    
    try:
        sd = REGS[parts[1].upper()]
        ss1 = REGS[parts[2].upper()]
        
        if instr.endswith('_IMM'):
            # Immediate format: imm18
            imm = int(parts[3].replace('#', ''), 0) & 0x3FFFF
            binary = (opcode << 26) | (sd << 22) | (ss1 << 18) | imm
        else:
            # Register format: ss2
            ss2 = REGS[parts[3].upper()] if len(parts) > 3 else 0
            binary = (opcode << 26) | (sd << 22) | (ss1 << 18) | (ss2 << 14)
            
        return f"{binary:08x}"
    except (IndexError, KeyError, ValueError) as e:
        print(f"Error at line {line_num}: Invalid syntax or register. {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='QSP-A assembler')
    parser.add_argument('input', help='Input assembly file (.asm)')
    parser.add_argument('-o', '--output', default='memory.mem', help='Output hex file (default: memory.mem)')
    
    args = parser.parse_args()

    try:
        with open(args.input, 'r') as f_in, open(args.output, 'w') as f_out:
            for i, line in enumerate(f_in, 1):
                hex_val = assemble_line(line, i)
                if hex_val:
                    f_out.write(hex_val + "\n")
        print(f"Successfully assembled {args.input} -> {args.output}")
    except FileNotFoundError:
        print(f"Error: Could not find file {args.input}")

if __name__ == "__main__":
    main()