`timescale 1ns / 1ps

`timescale 1ns / 1ps

module immgen(
    input [31:0] instruction,
    output reg [31:0] immediate
);

wire [6:0] opcode;
assign opcode = instruction[6:0];

always @(*) begin
    immediate = 32'd0;

    case(opcode)

        // I-type: arithmetic, loads, JALR
        7'd19, 7'd3, 7'd103:
            immediate = {{20{instruction[31]}}, instruction[31:20]};

        // S-type: stores
        7'd35:
            immediate = {{20{instruction[31]}},
                         instruction[31:25],
                         instruction[11:7]};

        // B-type: branches
        7'd99:
            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};

        // U-type: LUI, AUIPC
        7'd55, 7'd23:
            immediate = {instruction[31:12], 12'b0};

        // J-type: JAL
        7'd111:
            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};

        default:
            immediate = 32'd0;

    endcase
end

endmodule
