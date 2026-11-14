
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

//------------------------------------------------------------------------
`timescale 1ns / 1ps

module ClockDivider(
    input clk,
    input reset,
    output reg slwclk
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            slwclk <= 1'b0;
        else
            slwclk <= ~slwclk;
    end

endmodule
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

module IFID_EXMEM(
    input slwclk,
    input reset,
    input enable,

    input [31:0] PC_in,
    input [31:0] Instruction_in,
    input [31:0] Immediate_in,
    input [31:0] Rs1Data_in,
    input [31:0] Rs2Data_in,

    input [1:0] ALUOp_in,
    input [1:0] wbSrc_in,
    input ALUSrc1_in,
    input ALUSrc2_in,
    input Branch_in,
    input JAL_in,
    input JALR_in,
    input MemRead_in,
    input MemWrite_in,
    input RegWrite_in,

    output reg [31:0] PC_out,
    output reg [31:0] Instruction_out,
    output reg [31:0] Immediate_out,
    output reg [31:0] Rs1Data_out,
    output reg [31:0] Rs2Data_out,

    output reg [1:0] ALUOp_out,
    output reg [1:0] wbSrc_out,
    output reg ALUSrc1_out,
    output reg ALUSrc2_out,
    output reg Branch_out,
    output reg JAL_out,
    output reg JALR_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg RegWrite_out
);

    always @(negedge slwclk or posedge reset) begin
        if (reset) begin
            PC_out <= 0;
            Instruction_out <= 0;
            Immediate_out <= 0;
            Rs1Data_out <= 0;
            Rs2Data_out <= 0;

            ALUOp_out <= 0;
            wbSrc_out <= 0;
            ALUSrc1_out <= 0;
            ALUSrc2_out <= 0;
            Branch_out <= 0;
            JAL_out <= 0;
            JALR_out <= 0;
            MemRead_out <= 0;
            MemWrite_out <= 0;
            RegWrite_out <= 0;
        end
        else if (enable) begin
            PC_out <= PC_in;
            Instruction_out <= Instruction_in;
            Immediate_out <= Immediate_in;
            Rs1Data_out <= Rs1Data_in;
            Rs2Data_out <= Rs2Data_in;

            ALUOp_out <= ALUOp_in;
            wbSrc_out <= wbSrc_in;
            ALUSrc1_out <= ALUSrc1_in;
            ALUSrc2_out <= ALUSrc2_in;
            Branch_out <= Branch_in;
            JAL_out <= JAL_in;
            JALR_out <= JALR_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            RegWrite_out <= RegWrite_in;
        end
    end

endmodule
//----------------------------------------------------------------------------------------------------
`timescale 1ns / 1ps

module EXMEM_WB(
    input slwclk,
    input reset,
    input enable,

    input [31:0] ALUResult_in,
    input [31:0] MemData_in,
    input [31:0] PCPlus4_in,
    input [31:0] Immediate_in,
    input [4:0] Rd_in,
    input [1:0] wbSrc_in,
    input RegWrite_in,

    output reg [31:0] ALUResult_out,
    output reg [31:0] MemData_out,
    output reg [31:0] PCPlus4_out,
    output reg [31:0] Immediate_out,
    output reg [4:0] Rd_out,
    output reg [1:0] wbSrc_out,
    output reg RegWrite_out
);

    always @(posedge slwclk or posedge reset) begin
        if (reset) begin
            ALUResult_out <= 0;
            MemData_out <= 0;
            PCPlus4_out <= 0;
            Immediate_out <= 0;
            Rd_out <= 0;
            wbSrc_out <= 0;
            RegWrite_out <= 0;
        end
        else if (enable) begin
            ALUResult_out <= ALUResult_in;
            MemData_out <= MemData_in;
            PCPlus4_out <= PCPlus4_in;
            Immediate_out <= Immediate_in;
            Rd_out <= Rd_in;
            wbSrc_out <= wbSrc_in;
            RegWrite_out <= RegWrite_in;
        end
    end

endmodule
//---------------------------------------------------------------------------------







`timescale 1ns / 1ps

module FullDatapath(
    input clk,
    input reset
);

// =====================================================
// 0. CLOCK DIVIDER
// =====================================================

wire slwclk;

ClockDivider Divider (
    .clk(clk),
    .reset(reset),
    .slwclk(slwclk)
);


// =====================================================
// STAGE 0: INSTRUCTION FETCH + REGISTER READ
// =====================================================

// 1. PROGRAM COUNTER
wire [31:0] PC, next_PC;

pc PCRegister (
    .clk(slwclk),
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

// Stage 2 writeback signals
wire [4:0] WB_Rd;
wire WB_RegWrite;

registerfile Registers (
    .clk(clk),
    .reset(reset),
    .rs1(Instruction[19:15]),
    .rs2(Instruction[24:20]),
    .rd(WB_Rd),
    .writedata(rd),
    .regwrite(WB_RegWrite),
    .readdata1(rs1),
    .readdata2(rs2)
);


// =====================================================
// PIPELINE REGISTER 1: IFID_EXMEM
// Updates on negative edge of slwclk
// =====================================================

wire [31:0] EX_PC;
wire [31:0] EX_Instruction;
wire [31:0] EX_Immediate;
wire [31:0] EX_Rs1Data;
wire [31:0] EX_Rs2Data;

wire [1:0] EX_ALUOp;
wire [1:0] EX_wbSrc;

wire EX_ALUSrc1;
wire EX_ALUSrc2;
wire EX_Branch;
wire EX_JAL;
wire EX_JALR;
wire EX_MemRead;
wire EX_MemWrite;
wire EX_RegWrite;

IFID_EXMEM PipelineReg1 (
    .slwclk(slwclk),
    .reset(reset),
    .enable(1'b1),

    .PC_in(PC),
    .Instruction_in(Instruction),
    .Immediate_in(gen_out),
    .Rs1Data_in(rs1),
    .Rs2Data_in(rs2),

    .ALUOp_in(ALUOp),
    .wbSrc_in(wbSrc),
    .ALUSrc1_in(ALUSrc1),
    .ALUSrc2_in(ALUSrc2),
    .Branch_in(Branch),
    .JAL_in(JAL),
    .JALR_in(JALR),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .RegWrite_in(RegWrite),

    .PC_out(EX_PC),
    .Instruction_out(EX_Instruction),
    .Immediate_out(EX_Immediate),
    .Rs1Data_out(EX_Rs1Data),
    .Rs2Data_out(EX_Rs2Data),

    .ALUOp_out(EX_ALUOp),
    .wbSrc_out(EX_wbSrc),
    .ALUSrc1_out(EX_ALUSrc1),
    .ALUSrc2_out(EX_ALUSrc2),
    .Branch_out(EX_Branch),
    .JAL_out(EX_JAL),
    .JALR_out(EX_JALR),
    .MemRead_out(EX_MemRead),
    .MemWrite_out(EX_MemWrite),
    .RegWrite_out(EX_RegWrite)
);


// =====================================================
// STAGE 1: EXECUTION + MEMORY ACCESS
// =====================================================

// 7. ALU FIRST OPERAND MUX
wire [31:0] ALUOperand1;

mux2x1 ALUSrcSelector1 (
    .in0(EX_Rs1Data),
    .in1(EX_PC),
    .sel(EX_ALUSrc1),
    .out(ALUOperand1)
);


// 8. ALU SECOND OPERAND MUX
wire [31:0] ALUOperand2;

mux2x1 ALUSrcSelector2 (
    .in0(EX_Rs2Data),
    .in1(EX_Immediate),
    .sel(EX_ALUSrc2),
    .out(ALUOperand2)
);


// 9. ALU CONTROL
wire [4:0] ALUSel;

alucontrol ALUControl (
    .aluop(EX_ALUOp),
    .func3(EX_Instruction[14:12]),
    .func7(EX_Instruction[31:25]),
    .opcode(EX_Instruction[6:0]),
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
    .func3(EX_Instruction[14:12]),
    .branch(EX_Branch),
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
    .memread(EX_MemRead),
    .memwrite(EX_MemWrite),
    .func3(EX_Instruction[14:12]),
    .size(size),
    .unsignedload(unsignedload)
);


// 13. DATA MEMORY
wire [31:0] MemData_out;

DataMemory DataMem (
    .clk(slwclk),
    .MemRead(EX_MemRead),
    .MemWrite(EX_MemWrite),
    .size(size),
    .unsignedload(unsignedload),
    .addr(ALU_out[9:0]),
    .data_in(EX_Rs2Data),
    .data_out(MemData_out)
);


// 14. PC ADDERS
wire [31:0] PC_normal;
wire [31:0] PC_branch;
wire [31:0] PC_JALR;

assign PC_normal = PC + 32'd4;
assign PC_branch = EX_PC + EX_Immediate;
assign PC_JALR = ALU_out & 32'hFFFFFFFE;


// 15. NEXT PC SELECTOR
wire [1:0] PC_selector;

// Detect EBREAK in the execution stage
wire EX_ebreak;

assign EX_ebreak =
    (EX_Instruction[6:0] == 7'd115) &&
    (EX_Instruction[20] == 1'b1);

assign PC_selector = EX_ebreak ? 2'd3 :
                     EX_JALR ? 2'd1 :
                     (branching || EX_JAL) ? 2'd2 :
                     2'd0;

mux4x1 PCMux (
    .in0(PC_normal),
    .in1(PC_JALR),
    .in2(PC_branch),
    .in3(PC),
    .sel(PC_selector),
    .out(next_PC)
);


// =====================================================
// PIPELINE REGISTER 2: EXMEM_WB
// Updates on positive edge of slwclk
// =====================================================

wire [31:0] WB_ALUResult;
wire [31:0] WB_MemData;
wire [31:0] WB_PCPlus4;
wire [31:0] WB_Immediate;

wire [1:0] WB_wbSrc;

wire [31:0] EX_PCPlus4;

assign EX_PCPlus4 = EX_PC + 32'd4;

EXMEM_WB PipelineReg2 (
    .slwclk(slwclk),
    .reset(reset),
    .enable(1'b1),

    .ALUResult_in(ALU_out),
    .MemData_in(MemData_out),
    .PCPlus4_in(EX_PCPlus4),
    .Immediate_in(EX_Immediate),
    .Rd_in(EX_Instruction[11:7]),
    .wbSrc_in(EX_wbSrc),
    .RegWrite_in(EX_RegWrite),

    .ALUResult_out(WB_ALUResult),
    .MemData_out(WB_MemData),
    .PCPlus4_out(WB_PCPlus4),
    .Immediate_out(WB_Immediate),
    .Rd_out(WB_Rd),
    .wbSrc_out(WB_wbSrc),
    .RegWrite_out(WB_RegWrite)
);


// =====================================================
// STAGE 2: REGISTER WRITEBACK
// =====================================================

// 16. REGISTER WRITEBACK MUX
mux4x1 WritebackMux (
    .in0(WB_ALUResult),
    .in1(WB_PCPlus4),
    .in2(WB_MemData),
    .in3(WB_Immediate),
    .sel(WB_wbSrc),
    .out(rd)
);

endmodule
