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
    reg start;
    
    // I-MEM preload signals
    reg [8:0] imem_waddr_pre;
    reg [31:0] instr_write_pre;
    reg instr_we_pre;
    
    // D-MEM preload signals
    reg [7:0] dmem_waddr_pre;
    reg [63:0] dmem_wdata_pre;
    reg dmem_we_pre;
    
    // Verification signals
    reg [2:0] regfile_raddr_ver;
    wire [63:0] regfile_rdata_ver;
    reg [7:0] mem_raddr_ver;
    wire [63:0] mem_rdata_ver;
    
   //instruction arry
   reg [31:0] instr_mem [7:0]; 
   //datamemory arry
   reg [63:0] datamem_in[7:0];

   // Output test

    // Instantiate pipeline module
    pipeline uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .imem_waddr_pre(imem_waddr_pre),
        .instr_write_pre(instr_write_pre),
        .instr_we_pre(instr_we_pre),
        .dmem_waddr_pre(dmem_waddr_pre),
        .dmem_wdata_pre(dmem_wdata_pre),
        .dmem_we_pre(dmem_we_pre),
        .regfile_raddr_ver(regfile_raddr_ver),
        .regfile_rdata_ver(regfile_rdata_ver),
        .mem_raddr_ver(mem_raddr_ver),
        .mem_rdata_ver(mem_rdata_ver)
    );
    
    // Generate clock
    always #5 clk = ~clk; // 10ns cycle
    
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        start = 0;
        instr_we_pre = 0;
        dmem_we_pre = 0;
        
        // Reset
        #10 reset = 0;
        #10 reset = 1;
        
        // Preload I-MEM, D-MEM
         preload_imem(); 
         init_data_mem();

         #10; instr_we_pre = 1; imem_waddr_pre = 0; instr_write_pre = instr_mem[0]; dmem_we_pre = 1; dmem_waddr_pre = 0; dmem_wdata_pre = datamem_in[0];
         #10; instr_we_pre = 1; imem_waddr_pre = 1; instr_write_pre = instr_mem[1]; dmem_we_pre = 1; dmem_waddr_pre = 1; dmem_wdata_pre = datamem_in[1];
         #10; instr_we_pre = 1; imem_waddr_pre = 2; instr_write_pre = instr_mem[2]; dmem_we_pre = 1; dmem_waddr_pre = 2; dmem_wdata_pre = datamem_in[2];
         #10; instr_we_pre = 1; imem_waddr_pre = 3; instr_write_pre = instr_mem[3]; dmem_we_pre = 1; dmem_waddr_pre = 3; dmem_wdata_pre = datamem_in[3];
         #10; instr_we_pre = 1; imem_waddr_pre = 4; instr_write_pre = instr_mem[4]; dmem_we_pre = 1; dmem_waddr_pre = 4; dmem_wdata_pre = datamem_in[4];
         #10; instr_we_pre = 1; imem_waddr_pre = 5; instr_write_pre = instr_mem[5]; dmem_we_pre = 1; dmem_waddr_pre = 5; dmem_wdata_pre = datamem_in[5];
         #10; instr_we_pre = 1; imem_waddr_pre = 6; instr_write_pre = instr_mem[6]; dmem_we_pre = 1; dmem_waddr_pre = 6; dmem_wdata_pre = datamem_in[6];
         #10; instr_we_pre = 1; imem_waddr_pre = 7; instr_write_pre = instr_mem[7]; dmem_we_pre = 1; dmem_waddr_pre = 7; dmem_wdata_pre = datamem_in[7];
        
        // Start the pipeline
        #10 start = 1; instr_we_pre = 0; dmem_we_pre = 0;
        
        // Run for 6 clock cycles
        #60;
        
        // Stop execution and wait for data write-back
        #50;
        
        // Read RegFile, D-MEM results
        #10; start = 0; instr_we_pre = 0; regfile_raddr_ver = 0; dmem_we_pre = 0; mem_raddr_ver = 0;
        #10; regfile_raddr_ver = 1; mem_raddr_ver = 1;
        #10; regfile_raddr_ver = 2; mem_raddr_ver = 2;
        #10; regfile_raddr_ver = 3; mem_raddr_ver = 3;
        #10; regfile_raddr_ver = 4; mem_raddr_ver = 4;
        #10; regfile_raddr_ver = 5; mem_raddr_ver = 5;        
        
        // End simulation
        #20;
    end
    
   task preload_imem;
      begin
      instr_mem[0] = 32'b00000000000000000100000001000000; //ld R2, R0
      instr_mem[1] = 32'b00000000000000000100000001100000; //ld R3, R0
      instr_mem[2] = 32'b00000000000000000000000000000000; //Noop
      instr_mem[3] = 32'b00000000000000000000000000000000; //Noop
      instr_mem[4] = 32'b00000000000000000000000000000000; //Noop
      instr_mem[5] = 32'b00000000000000001001001100000000; //st R2, R1
      instr_mem[6] = 32'b00000000000000000000000000000000; //Noop
      instr_mem[7] = 32'b00000000000000000000000000000000; //Noop
      end
   endtask
    
   //initialize data memory
   task init_data_mem;
      begin
      datamem_in[0]   = 64'h0000_0000_0000_0004;
      datamem_in[1]   = 64'h0000_0000_0000_0002;
      datamem_in[2]   = 64'h0000_0000_0000_0003;
      datamem_in[3]   = 64'h0000_0000_0000_0004;
      datamem_in[4]   = 64'h0000_0000_0000_0064;
      datamem_in[5]   = 64'h0000_0000_0000_0006;
      datamem_in[6]   = 64'h0000_0000_0000_0007;
      datamem_in[7]   = 64'h0000_0000_0000_0008;
   end
   endtask
    
endmodule
