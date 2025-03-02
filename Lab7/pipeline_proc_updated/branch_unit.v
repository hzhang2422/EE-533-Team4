`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:47 02/21/2024 
// Design Name: 
// Module Name:    branch_unit 
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
module branch_unit(
    input eq,
	 input uslt,
    input [1:0] branch,
    input [63:0] imm,
    input [8:0] PC,
    input pidi_d,
    output reg [8:0] bta,
    output reg branch_taken
    );

    always@(*)
    begin
        if(pidi_d == 1'b1)
        begin
            branch_taken = 1'b1;
            bta = 9'b0;
        end
        else if(((eq == 1'b1 ) && (branch == 2'b01)))
        begin
            branch_taken = 1'b1;
            bta = PC + imm[8:0];
        end
		  else if(((uslt == 1'b1) && (branch == 2'b10)))
		  begin
				branch_taken = 1'b1;
				bta = PC + imm[8:0];
		  end
        else
        begin
            branch_taken = 1'b0;
            bta = 9'b0;
        end
    end
endmodule
