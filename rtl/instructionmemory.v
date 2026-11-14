`timescale 1ns / 1ps

module InstMem (
    input [7:0] addr,
    output [31:0] data_out
);

reg [31:0] mem [0:255];

//initial begin
//    mem[0] = 32'hFFF00093; // addi x1, x0, -1
//    mem[1] = 32'h01F09113; // slli x2, x1, 31
//    mem[2] = 32'h01F0D193; // srli x3, x1, 31
//    mem[3] = 32'h41F0D213; // srai x4, x1, 31
//    mem[4] = 32'h00009293; // slli x5, x1, 0
//    mem[5] = 32'h00115313; // srli x6, x2, 1
//    mem[6] = 32'h41F15393; // srai x7, x2, 31
//    mem[7] = 32'h0000006F; // jal  x0, 0 (infinite loop)
//end

//test 5 jal and jalr 
//initial begin
//    mem[0] = 32'h00100093; // addi x1, x0, 1
//    mem[1] = 32'h008002EF; // jal  x5, target
//    mem[2] = 32'h06408093; // addi x1, x1, 100 (skipped)
//    mem[3] = 32'h01900113; // addi x2, x0, 25
//    mem[4] = 32'h00010367; // jalr x6, 0(x2)
//    mem[5] = 32'h06408093; // addi x1, x1, 100 (skipped)
//    mem[6] = 32'h00208093; // addi x1, x1, 2
//    mem[7] = 32'h00028193; // addi x3, x5, 0
//    mem[8] = 32'h00030213; // addi x4, x6, 0
//    mem[9] = 32'h0000006F; // jal  x0, 0 (infinite loop)
//end

// test 6 
//initial begin
//    mem[0]  = 32'hFFE00093; // addi x1, x0, -2
//    mem[1]  = 32'h00300113; // addi x2, x0, 3
//    mem[2]  = 32'h022081B3; // mul    x3, x1, x2
//    mem[3]  = 32'h02209233; // mulh   x4, x1, x2
//    mem[4]  = 32'h0220A2B3; // mulhsu x5, x1, x2
//    mem[5]  = 32'h0220B333; // mulhu  x6, x1, x2
//    mem[6]  = 32'h0220C3B3; // div    x7, x1, x2
//    mem[7]  = 32'h0220D433; // divu   x8, x1, x2
//    mem[8]  = 32'h0220E4B3; // rem    x9, x1, x2
//    mem[9]  = 32'h0220F533; // remu   x10, x1, x2
//    mem[10] = 32'h0200C5B3; // div    x11, x1, x0
//    mem[11] = 32'h0200E633; // rem    x12, x1, x0
//    mem[12] = 32'h800006B7; // lui    x13, 0x80000
//    mem[13] = 32'hFFF00713; // addi   x14, x0, -1
//    mem[14] = 32'h02E6C7B3; // div    x15, x13, x14
//    mem[15] = 32'h02E6E833; // rem    x16, x13, x14
//    mem[16] = 32'h0000006F; // jal x0, 0 (infinite loop)
//end

//test 7
//initial begin
//    mem[0] = 32'h123450B7; // lui   x1, 0x12345
//    mem[1] = 32'h00000117; // auipc x2, 0
//    mem[2] = 32'h00001197; // auipc x3, 1
//    mem[3] = 32'h80000237; // lui   x4, 0x80000
//    mem[4] = 32'hFFF20293; // addi  x5, x4, -1
//    mem[5] = 32'h0000006F; // jal   x0, 0 (infinite loop)
//end


//test 8 branching


//test 9 load 
//initial begin
//    mem[0] = 32'h04000093; // addi x1, x0, 64
//    mem[1] = 32'h00208103; // lb   x2, 2(x1)
//    mem[2] = 32'h0020C183; // lbu  x3, 2(x1)
//    mem[3] = 32'h00209203; // lh   x4, 2(x1)
//    mem[4] = 32'h0020D283; // lhu  x5, 2(x1)
//    mem[5] = 32'h0000A303; // lw   x6, 0(x1)
//    mem[6] = 32'h00008383; // lb   x7, 0(x1)
//    mem[7] = 32'h0010C403; // lbu  x8, 1(x1)
//    mem[8] = 32'h0000006F; // jal  x0, 0 (infinite loop)
//end

//test 10 store 
//initial begin
//    mem[0]  = 32'h04000093; // addi x1, x0, 64
//    mem[1]  = 32'hFFF00113; // addi x2, x0, -1
//    mem[2]  = 32'h0020A023; // sw   x2, 0(x1)
//    mem[3]  = 32'h01200193; // addi x3, x0, 18
//    mem[4]  = 32'h003080A3; // sb   x3, 1(x1)
//    mem[5]  = 32'h34500213; // addi x4, x0, 837
//    mem[6]  = 32'h00409123; // sh   x4, 2(x1)
//    mem[7]  = 32'h0000A283; // lw   x5, 0(x1)
//    mem[8]  = 32'h0000A223; // sw   x0, 4(x1)
//    mem[9]  = 32'h0040A303; // lw   x6, 4(x1)
//    mem[10] = 32'h0000006F; // jal x0, 0 (infinite loop)
//end




initial begin
    mem[0] = 32'h00500093; // addi x1, x0, 5
    mem[1] = 32'h0000000F; // E instruction -> NOP
    mem[2] = 32'h00308093; // addi x1, x1, 3
    mem[3] = 32'h00100073; // EBREAK -> freeze PC
    mem[4] = 32'h06408093; // addi x1, x1, 100 (not executed)
end








assign data_out = mem[addr];

endmodule
