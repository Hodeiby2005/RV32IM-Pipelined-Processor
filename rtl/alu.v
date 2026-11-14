
`timescale 1ns / 1ps

module alu(
    input [31:0] in1,
    input [31:0] in2,
    input [4:0] alusel,
    output reg [31:0] aluresult,
    output zero,
    output sign,
    output reg overflow,
    output reg carry
);

wire signed [63:0] mul_ss;
wire signed [63:0] mul_su;
wire [63:0] mul_uu;

reg [32:0] temp;

assign mul_ss = $signed(in1) * $signed(in2);
assign mul_su = $signed(in1) * $signed({1'b0, in2});
assign mul_uu = in1 * in2;

// ALU flags
assign zero = (aluresult == 32'd0);
assign sign = aluresult[31];

always @(*) begin
    aluresult = 32'd0;
    overflow = 0;
    carry = 0;
    temp = 33'd0;

    case(alusel)
        5'd0: begin // ADD
            temp = {1'b0, in1} + {1'b0, in2};
            aluresult = temp[31:0];
            carry = temp[32];
            overflow = (~(in1[31] ^ in2[31])) &
                       (in1[31] ^ aluresult[31]);
        end

        5'd1: begin // SUB
            temp = {1'b0, in1} + {1'b0, ~in2} + 33'd1;
            aluresult = temp[31:0];
            carry = temp[32];
            overflow = (in1[31] ^ in2[31]) &
                       (in1[31] ^ aluresult[31]);
        end

        5'd2: aluresult = in1 << in2[4:0]; 
        5'd3: aluresult = ($signed(in1) < $signed(in2));
        5'd4: aluresult = (in1 < in2);
        5'd5: aluresult = in1 ^ in2;
        5'd6: aluresult = in1 >> in2[4:0];
        5'd7: aluresult = $signed(in1) >>> in2[4:0];
        5'd8: aluresult = in1 | in2;
        5'd9: aluresult = in1 & in2;

        // RV32M multiplication
        5'd10: aluresult = mul_ss[31:0];
        5'd11: aluresult = mul_ss[63:32];
        5'd12: aluresult = mul_su[63:32];
        5'd13: aluresult = mul_uu[63:32];

        // RV32M division
        5'd14: begin
            if (in2 == 0)
                aluresult = 32'hFFFFFFFF;
            else if (in1 == 32'h80000000 && in2 == 32'hFFFFFFFF)
                aluresult = 32'h80000000;
            else
                aluresult = $signed(in1) / $signed(in2);
        end

        5'd15: aluresult = (in2 == 0) ?
                           32'hFFFFFFFF : in1 / in2;

        5'd16: begin
            if (in2 == 0)
                aluresult = in1;
            else if (in1 == 32'h80000000 && in2 == 32'hFFFFFFFF)
                aluresult = 32'd0;
            else
                aluresult = $signed(in1) % $signed(in2);
        end

        5'd17: aluresult = (in2 == 0) ?
                           in1 : in1 % in2;

        default: aluresult = 32'd0;
    endcase
end

endmodule
