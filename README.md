# QTPS Core Testbench & Simulator

## Overview

## Architecture

### Core Components

### Pipeline Stages

### Register File

## Prerequisites

## Project Structure

```
qtp-a/
├── rtl/
│   ├── pkg/           # Package definitions
│   ├── core/
│   │   └── qtps/      # QTPS core modules
│   └── dma/           # DMA controller
├── tb/                # Testbenches
├── scripts/           # Assembly language toolchain
├── asm/               # Assembly program examples
├── sim/               # Simulation outputs (generated)
└── doc/               # Documentation
```

## Installation

### System Requirements

### Dependencies

## Quick Start

### 1. Basic Simulation

To run a simulation with the default memory file:

```bash
make all
```

This will:
1. Create necessary directories
2. Check for memory.mem file (creates sample if missing)
3. Compile with Verilator
4. Run simulation for 1000 cycles
5. Generate FST waveform file

### 2. Run with Assembly Program

Assemble your program and simulate:

```bash
make all ASSEMBLY_FILE=asm/test_flags.asm
```

This compiles the assembly file to hex and runs the full simulation pipeline.

### 3. Assemble Only

Just convert assembly to machine code without simulating:

```bash
make asm ASSEMBLY_FILE=asm/your_program.asm
```

Output: `memory.mem`

### 4. Compile Only

Build the Verilator executable without running simulation:

```bash
make compile
```

Executable: `sim/obj_dir/Vqtps_core_tb`

### 5. View Waveforms

After simulation, open the waveform in Surfer viewer:

```bash
make waveform
```

Or manually:

```bash
surfer sim/waves/scalar_core.fst
```

### 6. Clean

Remove all generated files:

```bash
make clean
```

## Usage Guide

### Assembly Language

#### Syntax

#### Supported Instructions

### Running Tests

#### Test Files

#### Creating New Tests

## Features

## Architecture Details

### Instruction Formats

### Instruction Set

### Execution Pipeline

### Flag Register (S15)

### Register File

## Building from Source

### Compilation Options

### Verilator Configuration

## Testing & Verification

### Built-in Tests

### Custom Test Programs

### Waveform Analysis

## Troubleshooting

### Common Issues

### Debug Tips

## Contributing

## License

## References

## Additional Documentation

- [TESTBENCH_README.md](TESTBENCH_README.md) - Detailed testbench documentation
- [INSTRUCTION_REFERENCE.md](INSTRUCTION_REFERENCE.md) - Complete instruction encoding guide
- [FLAG_REGISTER_UPDATE.md](FLAG_REGISTER_UPDATE.md) - Flag propagation implementation
- [QTPS_RENAME_SUMMARY.md](QTPS_RENAME_SUMMARY.md) - Naming convention changes

## Contact & Support
