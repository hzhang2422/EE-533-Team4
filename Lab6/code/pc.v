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
   input             start,
   output reg [8:0]  pc_out,
   input clk,
   input reset
);

always @ (posedge clk, negedge reset)
begin
    if (reset == 1'b0)
        pc_out <= 0;
    else if (start == 1'b0)
        pc_out <= 0;
    else
        pc_out <= pc_out + 1;
end

endmodule
