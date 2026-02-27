import qspa_pkg::*;

module qsp_core_tb (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [31:0]  instruction,
    output logic [31:0]  status_out,
    output logic         illegal
);

    // Instantiate QSP core
    qsp_core dut (
        .clk           (clk),
        .rst_n         (rst_n),
        .instruction   (instruction),
        .status_out    (status_out),
        .illegal       (illegal)
    );

endmodule
