`timescale 1ns / 1ps

module DataMemory (
    input clk,
    input MemRead,
    input MemWrite,
    input [1:0] size,
    input unsignedload,
    input [9:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out
);

reg [7:0] mem [0:1023];

integer i;

initial begin
    // Initialize all memory locations
    for (i = 0; i < 1024; i = i + 1)
        mem[i] = 8'd0;

    // Word 0: 17
    mem[0] = 8'd17;

    // Word 1: 9
    mem[4] = 8'd9;

    // Word 2: 25
    mem[8] = 8'd25;
end

initial begin
    mem[64] = 8'h01;
    mem[65] = 8'h7F;
    mem[66] = 8'hFF;
    mem[67] = 8'h80;
end









// Synchronous write
always @(posedge clk) begin
    if (MemWrite) begin
        case (size)
            2'd0: begin // SB
                mem[addr] <= data_in[7:0];
            end

            2'd1: begin // SH
                if (addr <= 10'd1022) begin
                    mem[addr]   <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                end
            end

            2'd2: begin // SW
                if (addr <= 10'd1020) begin
                    mem[addr]   <= data_in[7:0];
                    mem[addr+1] <= data_in[15:8];
                    mem[addr+2] <= data_in[23:16];
                    mem[addr+3] <= data_in[31:24];
                end
            end

            default: ;
        endcase
    end
end

// Combinational read
always @(*) begin
    data_out = 32'd0;

    if (MemRead) begin
        case (size)
            2'd0: begin // LB / LBU
                if (unsignedload)
                    data_out = {24'd0, mem[addr]};
                else
                    data_out = {{24{mem[addr][7]}}, mem[addr]};
            end

            2'd1: begin // LH / LHU
                if (addr <= 10'd1022) begin
                    if (unsignedload)
                        data_out = {16'd0, mem[addr+1], mem[addr]};
                    else
                        data_out = {{16{mem[addr+1][7]}},
                                    mem[addr+1], mem[addr]};
                end
            end

            2'd2: begin // LW
                if (addr <= 10'd1020)
                    data_out = {mem[addr+3], mem[addr+2],
                                mem[addr+1], mem[addr]};
            end

            default: data_out = 32'd0;
        endcase
    end
end

endmodule
