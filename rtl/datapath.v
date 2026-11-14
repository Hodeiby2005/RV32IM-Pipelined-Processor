
`timescale 1ns / 1ps


module mux2x1(
    input [31:0] in0,
    input [31:0] in1,
    input sel,
    output [31:0] out
);

assign out = sel ? in1 : in0;

endmodule


module mux4x1(
    input [31:0] in0,
    input [31:0] in1,
    input [31:0] in2,
    input [31:0] in3,
    input [1:0] sel,
    output [31:0] out
);

assign out = (sel == 2'd0) ? in0 :
             (sel == 2'd1) ? in1 :
             (sel == 2'd2) ? in2 : in3;

endmodule








module FullDatapath(
    input clk,
    input reset
);

// 1. PROGRAM COUNTER
wire [31:0] PC, next_PC;

pc PCRegister (
    .clk(clk),
    .reset(reset),
    .nextpc(next_PC),
    .pc(PC)
);


// 2. INSTRUCTION MEMORY
wire [31:0] Inst;

InstMem InstructionMemory (
    .addr(PC[9:2]),
    .data_out(Inst)
);


// 3. CONTROL UNIT
wire ebreak, Branch, AUIPC, LUI, JAL, JALR, nop;
wire MemRead, MemWrite, RegWrite;
wire ALUSrc1, ALUSrc2;
wire [1:0] wbSrc;
wire [1:0] ALUOp;

controlunit ControlUnit (
    .opcode(Inst[6:0]),
    .bit20(Inst[20]),
    .ebreak(ebreak),
    .branch(Branch),
    .auipc(AUIPC),
    .lui(LUI),
    .jal(JAL),
    .jalr(JALR),
    .nop(nop),
    .aluop(ALUOp),
    .regwrite(RegWrite),
    .memread(MemRead),
    .memwrite(MemWrite),
    .alusrc1(ALUSrc1),
    .alusrc2(ALUSrc2),
    .wbSrc(wbSrc)
);


// 4. NOP INSTRUCTION MUX
wire [31:0] Instruction;

mux2x1 NOPMux (
    .in0(Inst),
    .in1(32'h00000013),
    .sel(nop),
    .out(Instruction)
);


// 5. IMMEDIATE GENERATOR
wire [31:0] gen_out;

immgen ImmediateGenerator (
    .instruction(Instruction),
    .immediate(gen_out)
);


// 6. REGISTER FILE
wire [31:0] rs1, rs2, rd;

registerfile Registers (
    .clk(clk),
    .reset(reset),
    .rs1(Instruction[19:15]),
    .rs2(Instruction[24:20]),
    .rd(Instruction[11:7]),
    .writedata(rd),
    .regwrite(RegWrite),
    .readdata1(rs1),
    .readdata2(rs2)
);


// 7. ALU FIRST OPERAND MUX
wire [31:0] ALUOperand1;

mux2x1 ALUSrcSelector1 (
    .in0(rs1),
    .in1(PC),
    .sel(ALUSrc1),
    .out(ALUOperand1)
);


// 8. ALU SECOND OPERAND MUX
wire [31:0] ALUOperand2;

mux2x1 ALUSrcSelector2 (
    .in0(rs2),
    .in1(gen_out),
    .sel(ALUSrc2),
    .out(ALUOperand2)
);


// 9. ALU CONTROL
wire [1:0] ALUOp_final;
wire [4:0] ALUSel;

//assign ALUOp_final = (AUIPC || JALR) ? 2'b00 : ALUOp;

alucontrol ALUControl (
    .aluop(ALUOp),
    .func3(Instruction[14:12]),
    .func7(Instruction[31:25]),
    .opcode(Instruction[6:0]),
    .alusel(ALUSel)
);


// 10. ALU
wire [31:0] ALU_out;
wire zeroFlag, overflowFlag, carryFlag, signFlag;

alu myAlu (
    .in1(ALUOperand1),
    .in2(ALUOperand2),
    .alusel(ALUSel),
    .aluresult(ALU_out),
    .zero(zeroFlag),
    .sign(signFlag),
    .overflow(overflowFlag),
    .carry(carryFlag)
);


// 11. BRANCH UNIT
wire branching;

branchunit BranchUnit (
    .func3(Instruction[14:12]),
    .branch(Branch),
    .overflow(overflowFlag),
    .zero(zeroFlag),
    .sign(signFlag),
    .carry(carryFlag),
    .branchresult(branching)
);


// 12. LOAD / STORE UNIT
wire [1:0] size;
wire unsignedload;

loadstoreunit LoadStoreControl (
    .memread(MemRead),
    .memwrite(MemWrite),
    .func3(Instruction[14:12]),
    .size(size),
    .unsignedload(unsignedload)
);


// 13. DATA MEMORY
wire [31:0] MemData_out;

DataMemory DataMem (
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .size(size),
    .unsignedload(unsignedload),
    .addr(ALU_out[9:0]),
    .data_in(rs2),
    .data_out(MemData_out)
);


// 14. PC ADDERS
wire [31:0] PC_normal, PC_branch, PC_JALR;

assign PC_normal = PC + 32'd4;
assign PC_branch = PC + gen_out;
assign PC_JALR = ALU_out & ~(32'd1);


// 15. NEXT PC SELECTOR
wire [1:0] PC_selector;

assign PC_selector = ebreak ? 2'd3 :
                     JALR ? 2'd1 :
                     (branching || JAL) ? 2'd2 :
                     2'd0;

mux4x1 PCMux (
    .in0(PC_normal),
    .in1(PC_JALR),
    .in2(PC_branch),
    .in3(PC),
    .sel(PC_selector),
    .out(next_PC)
);
// assign next_PC = ebreak ? PC : PC_selected;


// 16. REGISTER WRITEBACK
mux4x1 WritebackMux (
    .in0(ALU_out),
    .in1(PC_normal),
    .in2(MemData_out),
    .in3(gen_out),
    .sel(wbSrc),
    .out(rd)
);

endmodule
