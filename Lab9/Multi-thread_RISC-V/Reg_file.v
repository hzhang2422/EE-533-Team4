`include "constants.vh"

module Reg_file(
	input							clk,
	input							rst,
	
	input	[`REG_ADDR_WIDTH-1:0]	rs1_addr,
	input	[`REG_ADDR_WIDTH-1:0] 	rs2_addr,
	input	[`REG_ADDR_WIDTH-1:0] 	rd_addr,
	
	input							Reg_Write,
	input	[`DATA_WIDTH-1:0]		rd_data,
	
	output	[`DATA_WIDTH-1:0]		rs1_data,
	output	[`DATA_WIDTH-1:0]		rs2_data,
	
	input	[1:0]					id_threadID,
	input	[1:0]					wb_threadID
);

	reg		[`DATA_WIDTH-1:0]	registers	[0:127];
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			for (integer i=0; i<128; i=i+1)
				registers[i] <= 64'h0000_0000;
			/*
			registers[0] <= 64'h0000_0000_0000_0000_0000_0000_0000_0002;
			registers[1] <= 64'h0000_0000_0000_0000_0000_0000_0000_0007;
			registers[2] <= 64'h0000_0000_0000_0000_0000_0000_0000_0007;
			registers[3] <= 64'h0000_0000_0000_0000_0000_0000_0000_0005;
			registers[7] <= 64'h0000_0000_0000_0000_0000_0000_0000_0007;
			*/
		end
		else begin
			if (Reg_Write && rd_addr != 5'b00000) begin
				registers[{wb_threadID, rd_addr}] <= rd_data;
			end
		end
	end
	
	assign	rs1_data = registers[{id_threadID,rs1_addr}];
	assign	rs2_data = registers[{id_threadID,rs2_addr}];
	
endmodule