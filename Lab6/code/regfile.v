`timescale 1ns / 1ps

`define PIPE_REG_ADDR_WIDTH 3

module regfile(
	input 										regwrite,

	input [`PIPE_REG_ADDR_WIDTH - 1:0] 	rs,
	input [`PIPE_REG_ADDR_WIDTH - 1:0] 	rt,
	input [`PIPE_REG_ADDR_WIDTH - 1:0] 	rd,
	input [63:0] 								rddata,
	
	output [63:0] 								rsdata_out,
	output [63:0] 								rtdata_out,

	// To verify RegFile result
	input [`PIPE_REG_ADDR_WIDTH - 1:0]	regfile_raddr,
	output reg [63:0]							regfile_rdata,
	
	input 										clk,
	input											reset
   );
	
	// 32 registers each with 64bits
	reg [63:0] 									register [31:0];
	integer 										i;
	wire 											wvalid;
	
	//read operation - asynchronous read
	assign rsdata_out = register[rs];
	assign rtdata_out = register[rt];
	
	//write enable
	assign wvalid = (regwrite == 1'b1) && (rd != 5'b00000);
	
	// This register file writes in the middle of the clock
	// (i.e. on the negative edges of the SYS_CLK) so that
	// the internal forwarding becomes automatic.
	always@(negedge clk, negedge reset)
	begin
		if(reset == 1'b0)
		begin
			for(i = 0; i < 31; i = i + 1)
				register[i] <= 32'b0;
		end
		//write operation
		else if (wvalid)
			register[rd] <= rddata;
	end

	// To verify RegFile result
	always @ (posedge clk)
	begin
		regfile_rdata <= register[regfile_raddr];
	end

endmodule
