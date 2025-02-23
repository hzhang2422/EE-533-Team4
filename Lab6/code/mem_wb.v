`timescale 1ns / 1ps

// ===============================
// Memory Access (MEM) Stage
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module mem_wb (
	input 										regwrite_in,
	input [`PIPE_REG_ADDR_WIDTH - 1:0]	rd_in,
	input [63:0]								memdata_in,
	
	output reg									regwrite_out,
	output reg[`PIPE_REG_ADDR_WIDTH - 1:0]	rd_out,
	output [63:0]								memdata_out,
	
	input 										clk,
   input 										reset
);

	// Because DMEM is synchronous which has already taken 1 clk
	assign memdata_out = reset ? memdata_in : 64'h0000000000000000;
	
	always @(posedge clk, negedge reset)
	begin
		if(reset == 1'b0)
			begin
				regwrite_out <= 1'b0;
				rd_out <= 3'b000;
			end
		else
			begin
				regwrite_out <= regwrite_in;
				rd_out <= rd_in;
			end
	end
endmodule
