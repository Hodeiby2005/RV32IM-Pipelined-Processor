`timescale 1ns / 1ps

module loadstoreunit(
    input memread,
    input memwrite,
    input [2:0] func3,

    output reg [1:0] size,
    output reg unsignedload
);

always @(*) begin
    size = 2'd2;       // Default word
    unsignedload = 0;

    if (memread || memwrite) begin
        case(func3)
            3'd0: size = 2'd0; // LB / SB
            3'd1: size = 2'd1; // LH / SH
            3'd2: size = 2'd2; // LW / SW

            3'd4: begin
                if(memread) begin
                    size = 2'd0;       // LBU
                    unsignedload = 1;
                end
            end

            3'd5: begin
                if(memread) begin
                    size = 2'd1;       // LHU
                    unsignedload = 1;
                end
            end

            default: size = 2'd2;
        endcase
    end
end

endmodule
