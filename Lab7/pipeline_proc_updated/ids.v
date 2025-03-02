`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:56:15 02/14/2024 
// Design Name: 
// Module Name:    pipeline 
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
module ids
	#(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
    )
	(
	input clk,
	input reset,

	input  [DATA_WIDTH-1:0]             in_data,
	input  [CTRL_WIDTH-1:0]   			in_ctrl,
    input                               in_wr,
    output                              in_rdy,

	output [DATA_WIDTH-1:0]             out_data,
    output [CTRL_WIDTH-1:0]             out_ctrl,
    output                              out_wr,
    input                               out_rdy,

	// --- Register interface
    input                               reg_req_in,
    input                               reg_ack_in,
    input                               reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

    output                              reg_req_out,
    output                              reg_ack_out,
    output                              reg_rd_wr_L_out,
    output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
    output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
    output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out

    );

wire enable;
wire [7:0] MemAddressQuery;
wire [8:0] PC_out;
wire [63:0] MemDataOut;
reg [31:0] MemDataOut_high;
reg [31:0] MemDataOut_low;


assign out_data = in_data;
assign out_ctrl = in_ctrl;
assign out_wr = in_wr;
assign in_rdy = out_rdy;

	pipeline module_pipeline(
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.PC_out(PC_out),
		.mem_data_out(MemDataOut),
		.MemAddressQuery(MemAddressQuery)
	);

	generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (2),
      .TAG                 (`IDS_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`IDS_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (2),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (2)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    ({enable,MemAddressQuery}),

      // --- HW regs interface
      .hardware_regs    ({MemDataOut_high,MemDataOut_low}),

      .clk              (clk),
      .reset            (reset)
    );


	always@(posedge clk)
	begin
		MemDataOut_high <= MemDataOut[63:32];
		MemDataOut_low <= MemDataOut[31:0];
	end
	
endmodule
