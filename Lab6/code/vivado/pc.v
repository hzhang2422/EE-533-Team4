`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:50:24 02/22/2025 
// Design Name: 
// Module Name:    pc 
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

module pc (
   output reg [8:0]  pc_out,

   input clk,
   input reset
);

always @ (posedge clk)
begin
    if (reset == 1'b1)
        pc_out <= 0;
    else if (pc_out == 9'b111111111)
        pc_out <= 9'b111111111;
    else
        pc_out <= pc_out + 1;
end

endmodule
