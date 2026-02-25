#include <verilated.h>
#include "Vqtps_core_tb.h"
#include <fstream>
#include <vector>
#include <iomanip>
#include <iostream>
#include <sstream>

// For FST tracing
#include <verilated_fst_c.h>

Vqtps_core_tb* top = NULL;
VerilatedFstC* tfp = NULL;
uint64_t sim_time = 0;

// Global variables for tracking
std::vector<uint32_t> instruction_mem;
int cycle_count = 0;
int max_cycles = 1000;

// Function to load memory file
bool load_memory_file(const char* filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cerr << "ERROR: Cannot open file '" << filename << "'" << std::endl;
        return false;
    }
    
    std::string line;
    int addr = 0;
    while (std::getline(file, line)) {
        // Skip empty lines and comments
        if (line.empty() || line[0] == '#') continue;
        
        // Parse hex value
        uint32_t instr;
        std::istringstream iss(line);
        iss >> std::hex >> instr;
        
        instruction_mem.push_back(instr);
        if (addr < 10 || addr % 10 == 0) {
            std::cout << "Loaded Instruction[" << std::setw(3) << std::setfill('0') << addr 
                      << "]: 0x" << std::hex << std::setw(8) << std::setfill('0') 
                      << instr << std::dec << std::endl;
        }
        addr++;
        
        if (addr >= 256) {
            std::cerr << "WARNING: Instruction memory full (256 max), stopping load" << std::endl;
            break;
        }
    }
    
    file.close();
    std::cout << "File '" << filename << "' loaded successfully with " << addr 
              << " instructions\n" << std::endl;
    return true;
}

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::traceEverOn(true);
    
    // Create top module instance
    top = new Vqtps_core_tb;
    
    // Open FST trace file
    tfp = new VerilatedFstC;
    top->trace(tfp, 99);
    tfp->open("waves/scalar_core.fst");
    
    // Load memory from file
    if (!load_memory_file("../memory.mem")) {
        std::cerr << "Failed to load memory file" << std::endl;
        return 1;
    }
    
    // Reset sequence
    std::cout << "Starting QTPS core simulation" << std::endl;
    std::cout << "Total instructions loaded: " << instruction_mem.size() << std::endl;
    std::cout << std::endl;
    
    top->clk = 0;
    top->rst_n = 0;
    top->instruction = 0;
    
    // Run reset for 5 cycles
    for (int i = 0; i < 5; i++) {
        // Positive edge
        top->clk = 1;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
        
        // Negative edge
        top->clk = 0;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
    }
    
    // Release reset
    top->rst_n = 1;
    top->clk = 0;
    top->eval();
    tfp->dump(sim_time);
    sim_time += 5;
    
    // Main simulation loop
    cycle_count = 0;
    while (cycle_count < max_cycles && instruction_mem.size() > 0) {
        // Feed instruction from memory
        top->instruction = instruction_mem[cycle_count % instruction_mem.size()];
        
        // Positive edge
        top->clk = 1;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
        
        // Negative edge
        top->clk = 0;
        top->eval();
        tfp->dump(sim_time);
        sim_time += 5;
        
        // Print status every 10 cycles
        if (cycle_count % 10 == 0) {
            std::cout << "[Cycle " << std::setw(4) << std::setfill(' ') << cycle_count 
                      << "] PC=" << std::setw(3) << (cycle_count % instruction_mem.size())
                      << " Instr=0x" << std::hex << std::setw(8) << std::setfill('0') 
                      << top->instruction 
                      << " Status=0x" << std::setw(8) << top->status_out
                      << " Illegal=" << (int)top->illegal
                      << std::dec << std::endl;
        }
        
        cycle_count++;
    }
    
    // Final stats
    std::cout << std::endl;
    std::cout << "Simulation complete after " << cycle_count << " cycles" << std::endl;
    
    tfp->close();
    delete tfp;
    delete top;
    
    return 0;
}
