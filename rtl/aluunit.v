`timescale 1ns / 1ps

module alucontrol(
    input [1:0] aluop,
    input [2:0] func3,
    input [6:0] func7,
    input [6:0] opcode,
    output reg [4:0] alusel
);

always @(*) begin
    alusel = 5'd0; // Default ADD

    case(aluop)
        2'd0: alusel = 5'd0; // ADD
        2'd1: alusel = 5'd1; // SUB

        2'd2: begin
            if(opcode == 7'd51 && func7 == 7'd1) begin
                // RV32M
                case(func3)
                    3'd0: alusel = 5'd10; // MUL
                    3'd1: alusel = 5'd11; // MULH
                    3'd2: alusel = 5'd12; // MULHSU
                    3'd3: alusel = 5'd13; // MULHU
                    3'd4: alusel = 5'd14; // DIV
                    3'd5: alusel = 5'd15; // DIVU
                    3'd6: alusel = 5'd16; // REM
                    3'd7: alusel = 5'd17; // REMU
                endcase
            end
            else begin
                case(func3)
                    3'd0: begin
                        if(opcode == 7'd51 && func7 == 7'd32)
                            alusel = 5'd1; // SUB
                        else
                            alusel = 5'd0; // ADD / ADDI
                    end

                    3'd1: alusel = 5'd2; // SLL / SLLI
                    3'd2: alusel = 5'd3; // SLT / SLTI
                    3'd3: alusel = 5'd4; // SLTU / SLTIU
                    3'd4: alusel = 5'd5; // XOR / XORI

                    3'd5: begin
                        if(func7 == 7'd32)
                            alusel = 5'd7; // SRA / SRAI
                        else
                            alusel = 5'd6; // SRL / SRLI
                    end

                    3'd6: alusel = 5'd8; // OR / ORI
                    3'd7: alusel = 5'd9; // AND / ANDI
                endcase
            end
        end

        default: alusel = 5'd0;
    endcase
end

endmodule
