`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:06:38 02/22/2025 
// Design Name: 
// Module Name:    pipeline_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module pipeline_tb;
    reg clk;
    reg reset;
    
    // Verification signals
    reg [7:0] mem_raddr_ver;
    wire [63:0] mem_rdata_ver;

   // Output test

    // Instantiate pipeline module
    pipeline uut (
        .clk(clk),
        .reset(reset),
        .mem_raddr_ver(mem_raddr_ver),
        .mem_rdata_ver(mem_rdata_ver)
    );
    
    // Generate clock
    always #5 clk = ~clk; // 10ns cycle
    
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        
        // Reset
        #10 reset = 1;
        #10 reset = 0;
        
        // Run for 6 clock cycles
        #60;
        
        // Stop execution and wait for data write-back
        #50;
        
        // Read RegFile, D-MEM results
        #10; mem_raddr_ver = 0;
        #10; mem_raddr_ver = 1;
        #10; mem_raddr_ver = 2;
        #10; mem_raddr_ver = 3;
        #10; mem_raddr_ver = 4;
        #10; mem_raddr_ver = 5;        
        
        // End simulation
        #20;
    end
    
endmodule
