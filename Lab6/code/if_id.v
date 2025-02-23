`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:40 02/22/2025 
// Design Name: 
// Module Name:    if_id 
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

// ===============================
// Instruction Fetch (IF) Stage
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module if_id (
	input [31:0]								instr_in,
	
	output reg									memwrite,	
	output reg									regwrite,
	output reg [`PIPE_REG_ADDR_WIDTH - 1:0]	rs,
	output reg [`PIPE_REG_ADDR_WIDTH - 1:0]	rt,
	output reg [`PIPE_REG_ADDR_WIDTH - 1:0]	rd,							

   input 										clk,
   input 										reset
);

	always @ (posedge clk, negedge reset)
	begin
		if (reset == 1'b0)
		begin
			memwrite = 1'b0;
			regwrite = 1'b0;
			rs = 3'b000;
			rt = 3'b000;
			rd = 3'b000;
		end
		else
		begin
			memwrite = instr_in[15];
			regwrite = instr_in[14];
			rs = instr_in[13:11];
			rt = instr_in[10:8];
			rd = instr_in[7:5];
		end
	end
		
endmodule
