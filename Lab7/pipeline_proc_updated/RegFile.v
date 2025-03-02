
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:03:52 02/14/2024 
// Design Name: 
// Module Name:    RegFile 
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
module RegFile(
	input clk,
	input reset,
	input [4:0] r0addr,
	input [4:0] r1addr,
	output [63:0] r0data,
	output [63:0] r1data,
	input wren,
	input [4:0] wraddr,
	input [63:0] wrdata
    );
	
	// 32 registers each with 64bits
	reg signed [63:0] register [0:31];
	integer i;
	wire wvalid;
	
	//read operation - asynchronous read
	assign r0data = register[r0addr];
	assign r1data = register[r1addr];
	
	//write enable
	assign wvalid = (wren == 1'b1) && (wraddr != 5'b00000);
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			for(i = 0; i < 31; i = i + 1)
				register[i] <= 32'b0;
		end
		//write operation
		else if (wvalid)
			register[wraddr] <= wrdata;
	end
	

endmodule
