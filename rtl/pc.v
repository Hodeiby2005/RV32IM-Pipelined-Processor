`timescale 1ns / 1ps

module pc(
    input clk,
    input reset,
    input [31:0] nextpc,
    output reg [31:0] pc
);

reg started;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc <= 32'd0;
        started <= 1'b0;
    end
    else if (!started) begin
        started <= 1'b1;
        pc <= 32'd0;
    end
    else begin
        pc <= nextpc;
    end
end

endmodule
