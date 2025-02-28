`timescale 1ns / 1ps

// ===============================
// Execute (EX) Stage
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module ex_mem (
   input 										memwrite_in,
   input 										regwrite_in,

   output reg									memwrite_out,
   output reg									regwrite_out,

   input [63:0] 								rsdata_in,
   input [63:0] 								rtdata_in,
   input [`PIPE_REG_ADDR_WIDTH - 1:0] 		rd_in,

   output reg [63:0] 						rsdata_out,
   output reg [63:0] 						rtdata_out,
   output reg [`PIPE_REG_ADDR_WIDTH - 1:0] rd_out,
	 
	input 										clk,
   input 										reset
);

	always @(posedge clk)
	
		begin
		if(reset == 1'b1)
			begin
				memwrite_out <= 1'b0;
				regwrite_out <= 1'b0;
				rsdata_out <= 64'h0000000000000000;
				rtdata_out <= 64'h0000000000000000;
				rd_out <= 3'b000;
			end
		else
			begin
				memwrite_out <= memwrite_in;
				regwrite_out <= regwrite_in;
				rsdata_out   <= rsdata_in;
				rtdata_out   <= rtdata_in;
				rd_out       <= rd_in;
			end
		end

endmodule
