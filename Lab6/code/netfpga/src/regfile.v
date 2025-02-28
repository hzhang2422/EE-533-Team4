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

always @(posedge clk) 
begin
	if (reset == 1'b1) 
	begin
      register[0] <= 64'b0;
      register[1] <= 64'b0;
      register[2] <= 64'b0;
      register[3] <= 64'b0;
      register[4] <= 64'b0;
      register[5] <= 64'b0;
      register[6] <= 64'b0;
      register[7] <= 64'b0;
      register[8] <= 64'b0;
      register[9] <= 64'b0;
		register[10] <= 64'b0;
		register[11] <= 64'b0;
		register[12] <= 64'b0;
		register[13] <= 64'b0;
		register[14] <= 64'b0;
		register[15] <= 64'b0;
		register[16] <= 64'b0;
		register[17] <= 64'b0;
		register[18] <= 64'b0;
		register[19] <= 64'b0;
		register[20] <= 64'b0;
		register[21] <= 64'b0;
		register[22] <= 64'b0;
		register[23] <= 64'b0;
		register[24] <= 64'b0;
		register[25] <= 64'b0;
		register[26] <= 64'b0;
		register[27] <= 64'b0;
		register[28] <= 64'b0;
		register[29] <= 64'b0;
		register[30] <= 64'b0;
		register[31] <= 64'b0;
   end
	else if (wvalid)
	begin
		register[rd] <= rddata;
	end
end

endmodule
