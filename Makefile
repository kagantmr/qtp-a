# ============================================================================
# Makefile for QSP Core Testbench
# ============================================================================
# Supports Verilator simulator with FST waveform tracing
# ============================================================================

# Project structure
ROOT_DIR     := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
RTL_DIR      := $(ROOT_DIR)rtl
TB_DIR       := $(ROOT_DIR)tb
PKG_DIR      := $(RTL_DIR)/pkg
CORE_DIR     := $(RTL_DIR)/core/qsp
SIM_DIR      := $(ROOT_DIR)sim
WAVES_DIR    := $(SIM_DIR)/waves
SCRIPTS_DIR  := $(ROOT_DIR)scripts

# Assembly and Memory files
ASSEMBLY_FILE ?= 
MEMORY_FILE   ?= memory.mem
MEMORY_PATH   := $(ROOT_DIR)$(MEMORY_FILE)

# Assembler
ASSEMBLER     := python3 $(SCRIPTS_DIR)/asm.py

# Simulator selection (VERILATOR)
SIMULATOR    ?= VERILATOR
VERBOSE      ?= 0

# Common source files
SV_FILES     := $(PKG_DIR)/qspa_pkg.sv \
                $(CORE_DIR)/qsp_alu.sv \
                $(CORE_DIR)/qsp_regfile.sv \
                $(CORE_DIR)/qsp_decode_unit.sv \
                $(CORE_DIR)/pipe_reg_dec_iss.sv \
                $(CORE_DIR)/pipe_reg_iss_ex.sv \
                $(CORE_DIR)/pipe_reg_ex_wb.sv \
                $(CORE_DIR)/qsp_core.sv \
                $(TB_DIR)/qsp_core_tb.sv

# Verilator options
VERILATOR_OPTS := --cc \
                  --no-timing \
                  --trace \
                  --trace-fst \
                  -Wno-CASEINCOMPLETE \
                  -Wno-UNUSEDSIGNAL \
                  -Wno-UNUSEDPARAM \
                  -Wno-WIDTHTRUNC \
                  -Wno-WIDTHEXPAND \
                  -Wno-LATCH \
                  --top-module qsp_core_tb \
                  --timescale 1ns/1ps

# Simulation time (can be overridden)
SIM_TIME     ?= 100us

# ============================================================================
# Targets
# ============================================================================

.PHONY: all compile simulate clean help create-dirs waveform check-memory asm

all: clean create-dirs asm check-memory compile simulate

help:
	@echo "=========================================="
	@echo "QSP Core Testbench Makefile"
	@echo "=========================================="
	@echo "Usage: make [target] [ASSEMBLY_FILE=file.asm] [MEMORY_FILE=file.mem]"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Clean, assemble, compile, and simulate (default)"
	@echo "  asm          - Assemble .asm file to memory.mem"
	@echo "  compile      - Compile design only"
	@echo "  simulate     - Run simulation"
	@echo "  waveform     - Open waveform in Surfer"
	@echo "  clean        - Remove generated files"
	@echo "  check-memory - Verify memory file exists"
	@echo ""
	@echo "Options:"
	@echo "  ASSEMBLY_FILE - Assembly file to compile (e.g., test.asm)"
	@echo "  MEMORY_FILE   - Memory file path (default: memory.mem)"
	@echo ""
	@echo "Examples:"
	@echo "  make                                 # Use existing memory.mem"
	@echo "  make ASSEMBLY_FILE=test.asm          # Compile test.asm to memory.mem"
	@echo "  make ASSEMBLY_FILE=test.asm MEMORY_FILE=custom.mem"
	@echo "  make asm ASSEMBLY_FILE=program.asm   # Assemble only"
	@echo "==========================================\""

check-memory:
	@if [ ! -f "$(MEMORY_PATH)" ]; then \
		echo ""; \
		echo "ERROR: Memory file not found: $(MEMORY_PATH)"; \
		echo ""; \
		echo "Creating sample memory.mem file..."; \
		echo "00000000" > $(MEMORY_PATH); \
		echo "00000000" >> $(MEMORY_PATH); \
		echo "00000000" >> $(MEMORY_PATH); \
		echo "00000000" >> $(MEMORY_PATH); \
		echo ""; \
		echo "Sample memory.mem created with 4 NOP instructions."; \
		echo "Please update it with your actual instructions (hex format, one per line)."; \
		echo "Alternatively, create an assembly file (.asm) and use: make asm ASSEMBLY_FILE=your_file.asm"; \
		echo ""; \
	else \
		echo "[OK] Memory file found: $(MEMORY_PATH)"; \
	fi

asm:
	@if [ -z "$(ASSEMBLY_FILE)" ]; then \
		echo "No assembly file specified. Use: make asm ASSEMBLY_FILE=your_file.asm"; \
		exit 0; \
	fi
	@echo ""
	@echo "========== Assembling $(ASSEMBLY_FILE) ==========="
	@if [ ! -f "$(ASSEMBLY_FILE)" ]; then \
		echo "ERROR: Assembly file not found: $(ASSEMBLY_FILE)"; \
		exit 1; \
	fi
	@$(ASSEMBLER) $(ASSEMBLY_FILE) -o $(MEMORY_FILE)
	@echo "[OK] Assembly complete: $(MEMORY_FILE)"

create-dirs:
	@mkdir -p $(SIM_DIR)
	@mkdir -p $(WAVES_DIR)
	@echo "[OK] Directory structure created"

compile: check-memory
	@echo ""
	@echo "========== Compiling with Verilator =========="
	@echo "RTL files:"
	@for file in $(SV_FILES); do echo "  - $$file"; done
	@echo ""
	@cp tb/qsp_core_tb.cpp sim/
	@cd $(SIM_DIR) && verilator $(VERILATOR_OPTS) $(SV_FILES) --exe qsp_core_tb.cpp && make -C obj_dir -f Vqsp_core_tb.mk
	@echo "[OK] Compilation complete"
	@ls -lh $(SIM_DIR)/obj_dir/Vqsp_core_tb 2>/dev/null || echo "  (executable built in sim/obj_dir/)"

simulate: 
	@echo ""
	@echo "========== Running Simulation with Verilator =========="
	@echo "Memory file: $(MEMORY_PATH)"
	@echo "Waveform output: $(WAVES_DIR)/scalar_core.fst"
	@echo ""
	@cd $(SIM_DIR) && ./obj_dir/Vqsp_core_tb +verilator+rand_reset+2 || true
	@echo "[OK] Simulation complete"
	@echo "Waveform file generated: $(WAVES_DIR)/scalar_core.fst"

waveform:
	@echo "Opening waveform in Surfer..."
	@if [ -f "$(WAVES_DIR)/scalar_core.fst" ]; then \
		surfer $(WAVES_DIR)/scalar_core.fst & \
	else \
		echo "ERROR: Waveform file not found: $(WAVES_DIR)/scalar_core.fst"; \
		echo "Run 'make simulate' first to generate waveforms"; \
		exit 1; \
	fi

clean:
	@echo "Cleaning simulation files..."
	@rm -rf $(SIM_DIR)
	@echo "[OK] Clean complete"

# ============================================================================
# Verbose target for debugging makefile
# ============================================================================

print-vars:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "RTL_DIR: $(RTL_DIR)"
	@echo "TB_DIR: $(TB_DIR)"
	@echo "SIM_DIR: $(SIM_DIR)"
	@echo "MEMORY_FILE: $(MEMORY_FILE)"
	@echo "MEMORY_PATH: $(MEMORY_PATH)"
	@echo "ASSEMBLY_FILE: $(ASSEMBLY_FILE)"
	@echo "ASSEMBLER: $(ASSEMBLER)"
	@echo "SV_FILES: $(SV_FILES)"

# ============================================================================
# Assembly build rules (generic .asm to .mem)
# ============================================================================

%.mem: %.asm
	@echo "Assembling $< -> $@"
	@$(ASSEMBLER) $< -o $@
	@echo "[OK] $@ assembled"
