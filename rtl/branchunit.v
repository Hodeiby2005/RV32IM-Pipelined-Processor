
`timescale 1ns / 1ps

module branchunit(
    input [2:0] func3,
    input branch,
    input overflow,
    input zero,
    input sign,
    input carry,
    output reg branchresult
);

always @(*) begin
    branchresult = 0;

    if (branch) begin
        case (func3)
            3'd0: branchresult = zero;               // BEQ
            3'd1: branchresult = ~zero;              // BNE
            3'd4: branchresult = sign ^ overflow;    // BLT
            3'd5: branchresult = ~(sign ^ overflow); // BGE
            3'd6: branchresult = ~carry;             // BLTU
            3'd7: branchresult = carry;              // BGEU
            default: branchresult = 0;
        endcase
    end
end

endmodule
