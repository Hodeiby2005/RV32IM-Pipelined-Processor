`timescale 1ns / 1ps

module ForwardingUnit(
    input [4:0] EX_Rs1,
    input [4:0] EX_Rs2,
    input [4:0] WB_Rd,
    input WB_RegWrite,
    output ForwardNeeded1,
    output ForwardNeeded2
);

assign ForwardNeeded1 = WB_RegWrite &&
                        (WB_Rd != 5'd0) &&
                        (WB_Rd == EX_Rs1);

assign ForwardNeeded2 = WB_RegWrite &&
                        (WB_Rd != 5'd0) &&
                        (WB_Rd == EX_Rs2);

endmodule
