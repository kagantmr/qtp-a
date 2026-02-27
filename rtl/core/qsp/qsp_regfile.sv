import qspa_pkg::*;

module qsp_regfile (
    input  logic                  clk,
    input  logic                  rst_n,

    // Read Port 1 (Rs1)
    input  logic [3:0]            rs1_addr,
    output logic [DATA_WIDTH-1:0] rs1_data,

    // Read Port 2 (Rs2)
    input  logic [3:0]            rs2_addr,
    output logic [DATA_WIDTH-1:0] rs2_data,

    // Write Port (Rd)
    input  logic                  we,      // Write Enable
    input  logic [3:0]            rd_addr, // Destination address
    input  logic [DATA_WIDTH-1:0] rd_data, // Data to write

    // Flag inputs to update S15 status register
    input  logic                  flag_zero,
    input  logic                  flag_carry,
    input  logic                  flag_ovf,
    input  logic                  flag_we,  // Flag write enable

    // Status register output
    output logic [DATA_WIDTH-1:0] status_reg_out
);
    logic [DATA_WIDTH-1:0]  regfile [15:0]; // 16 registers, each 32 bits wide

    always_ff @(posedge clk) begin : write
        if (!rst_n) begin
            // Initialize all registers to 0 on reset
            for (int i = 0; i < 16; i++) begin
                regfile[i] <= 'b0;
            end
        end else begin
            // Write to the register file if write enable is high
            if (we && rd_addr != S0_IDX) begin
                regfile[rd_addr] <= rd_data;
            end
            // Update S15 flags independently
            if (flag_we) begin
                regfile[S15_IDX][FLAG_ZERO]  <= flag_zero;
                regfile[S15_IDX][FLAG_OVF]   <= flag_ovf;
                regfile[S15_IDX][FLAG_CARRY] <= flag_carry;
            end
        end
    end

    always_comb begin : read
        status_reg_out = regfile[S15_IDX]; // status register output
        // Read from the register file, ensuring S0_IDX always reads as 0
        rs1_data = (rs1_addr == S0_IDX) ? 'b0 : regfile[rs1_addr];
        rs2_data = (rs2_addr == S0_IDX) ? 'b0 : regfile[rs2_addr];
    end

endmodule
