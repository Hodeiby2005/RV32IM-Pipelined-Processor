`timescale 1ns / 1ps

module registerfile(
    input clk,
    input reset,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] writedata,
    input regwrite,
    output [31:0] readdata1,
    output [31:0] readdata2
);

reg [31:0] rf [0:31];
integer i;

// Synchronous write and reset
    always @(negedge clk or posedge reset) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] <= 32'd0;
    end
    else if (regwrite && rd != 5'd0) begin
        rf[rd] <= writedata;
    end
end

// Combinational read
assign readdata1 = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
assign readdata2 = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

endmodule
