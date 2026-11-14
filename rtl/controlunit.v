
`timescale 1ns / 1ps

module controlunit(
input [6:0] opcode,
input bit20,
output reg ebreak,
output reg branch,
output reg auipc,
output reg lui,
output reg jal,
output reg jalr,
output reg nop,
//output reg [1:0]memtoreg,
output reg [1:0]aluop,
output reg regwrite,
output reg memread,
output reg memwrite,
output reg alusrc1,
output reg alusrc2,
output reg [1:0] wbSrc
//Pcsrc={jalr,or gate result}
//alusrc1={auipc,jalr}
    );
    
    always@(*) begin
        aluop=2'b10;
        memread=0;
        memwrite=0;
        alusrc1=0;
        alusrc2=0;
        regwrite=0;
        ebreak=0;
        branch=0;
        auipc=0;
        lui=0;
        jal=0;
        jalr=0;
        nop=0;

        case(opcode)
            7'd51 : begin  //rtype
            regwrite=1;
            end 
            7'd19 : begin   //itype
            regwrite=1;
            alusrc2=1;
            end
            7'd3 : begin     //load
            memread=1;
            regwrite=1;
            aluop=2'b00;
            alusrc2=1;
            end
            7'd35 : begin   //sw
            memwrite=1;
            aluop=2'b00;
            alusrc2=1;
            end
            7'd99 : begin  //branch signal!
            branch=1;
            aluop=2'b01;
            end
            7'd111: begin  //jal
            aluop = 2'b00;
            jal=1;
            regwrite=1;
            end
            7'd103: begin //jalr
            alusrc1 = 0;
            aluop = 2'b00;
            jalr=1;
            regwrite=1;
            alusrc2=1;
            end
            7'd55: begin  //lui
            lui=1;
            regwrite=1;
            end
            7'd23: begin //auipc
            auipc=1;
            regwrite=1;
            alusrc2=1;
            alusrc1 = 1;
            aluop = 2'b00;
            end
            7'd15: begin  //e instructions
            nop=1;
            regwrite=1;
            alusrc2=1;
            aluop=2'b10;
            end
            default: begin
            nop=1;
            regwrite=1;
            alusrc2=1;
            aluop=2'b10;
            end
        endcase 

        // assign alusrc1 = auipc;
        wbSrc = { memread | lui, jal | jalr | lui};

        //memtoreg={0,memread,(jal||jalr)};
        if(opcode==7'd115&&bit20==1)begin
            ebreak=1;
            nop=0;
            regwrite=0;
            alusrc2=0;
        end
    end 
 
endmodule
