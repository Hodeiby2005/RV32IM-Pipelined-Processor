
`timescale 1ns / 1ps


module FullDatapath_tb();
        reg clk;
        reg reset;
        FullDatapath dut (.clk(clk), .reset(reset));
    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        reset = 1;
        #30;
        
        reset = 0;
 
    end
        
        
endmodule
