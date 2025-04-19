`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:32:24 04/16/2025
// Design Name:   rv64i_v0
// Module Name:   C:/Documents and Settings/student/My Documents/EE533/Project_v0/project_v0_tb.v
// Project Name:  Project_v0
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rv64i_v0
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module project_v0_tb;

	// Inputs
	reg [63:0] in_data;
	reg [7:0] in_ctrl;
	reg in_wr;
	reg out_rdy;
	reg reg_req_in;
	reg reg_ack_in;
	reg reg_rd_wr_L_in;
	reg [15:0] reg_addr_in;
	reg [15:0] reg_data_in;
	reg [1:0] reg_src_in;
	reg [31:0] cmd_in;
	reg [31:0] din_low;
	reg [31:0] din_high;
	reg reset;
	reg clk;
	reg match;

	// Outputs
	wire in_rdy;
	wire [63:0] out_data;
	wire [7:0] out_ctrl;
	wire out_wr;
	wire reg_req_out;
	wire reg_ack_out;
	wire reg_rd_wr_L_out;
	wire [15:0] reg_addr_out;
	wire [15:0] reg_data_out;
	wire [1:0] reg_src_out;
	wire [31:0] cmd_out;
	wire [31:0] dout_low;
	wire [31:0] dout_high;

	// Instantiate the Unit Under Test (UUT)
	rv64i_v0 uut (
		.in_data(in_data), 
		.in_ctrl(in_ctrl), 
		.in_wr(in_wr), 
		.in_rdy(in_rdy), 
		.out_data(out_data), 
		.out_ctrl(out_ctrl), 
		.out_wr(out_wr), 
		.out_rdy(out_rdy), 
		.reg_req_in(reg_req_in), 
		.reg_ack_in(reg_ack_in), 
		.reg_rd_wr_L_in(reg_rd_wr_L_in), 
		.reg_addr_in(reg_addr_in), 
		.reg_data_in(reg_data_in), 
		.reg_src_in(reg_src_in), 
		.reg_req_out(reg_req_out), 
		.reg_ack_out(reg_ack_out), 
		.reg_rd_wr_L_out(reg_rd_wr_L_out), 
		.reg_addr_out(reg_addr_out), 
		.reg_data_out(reg_data_out), 
		.reg_src_out(reg_src_out), 
		.cmd_in(cmd_in), 
		.din_low(din_low), 
		.din_high(din_high), 
		.cmd_out(cmd_out), 
		.dout_low(dout_low), 
		.dout_high(dout_high), 
		.match(match),
		.reset(reset), 
		.clk(clk)
	);

	always #5 clk = ~clk;

	initial begin
		// Initialize Inputs
		in_data = 0;
		in_ctrl = 0;
		in_wr = 0;
		out_rdy = 0;
		reg_req_in = 0;
		reg_ack_in = 0;
		reg_rd_wr_L_in = 0;
		reg_addr_in = 0;
		reg_data_in = 0;
		reg_src_in = 0;
		cmd_in = 0;
		din_low = 0;
		din_high = 0;
		reset = 0;
		clk = 0;

		#20;
        reset = 1;
        #20;
        reset = 0;

        #20;

		out_rdy = 1'b1;
        //Write a packet to the drop FIFO
        //begin of the packet
        in_wr = 1'b1;
        in_ctrl = 8'h11;
        in_data = 64'h0000_0000_0000_2000;
        #10;

        //middle part of the packet
        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2100;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2200;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2300;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2400;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2500;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2600;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2700;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2800;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_2900;
        #10;

        //end of the packet
        in_ctrl = 8'h01;
        in_data = 64'h0000_0000_0000_2A00;
        #10;

        //stop writing
        in_wr = 1'b0;

		wait(uut.process_done == 1'b1);

		//wait for in_rdy signal stable
		  #10;
		  
		//some invalid data
        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0010_0000;
        #10;
        
        in_data = 64'h0000_0000_0020_0000;
        #10;
		

        //send the 2nd malicious packet
        //begin of the packet
        in_wr = 1'b1;
        in_ctrl = 8'h11;
        in_data = 64'h0000_0000_0000_3000;
        #10;

		in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3100;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3200;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3300;
        #10;

        //malicious packet
        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_DEAD_BEAF;
		match = 1'b1;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3500;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3600;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3700;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3800;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_3900;
        #10;

        //end of the packet
        in_ctrl = 8'h01;
        in_data = 64'h0000_0000_0000_3A00;
        #10;

		//stop writing
        in_wr = 1'b0;
		match = 1'b0; //reset match
        #10;

		//some invalid data
        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_8888_8888;
        #10;
        
        in_data = 64'h0000_0000_9999_9999;
        #10;

		//send the 3rd packet
        //begin of the packet
        in_wr = 1'b1;
        in_ctrl = 8'h11;
        in_data = 64'h0000_0000_0000_4000;
        #10;

		in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4100;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4200;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4300;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4400;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4500;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4600;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4700;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4800;
        #10;

        in_ctrl = 8'h00;
        in_data = 64'h0000_0000_0000_4900;
        #10;

        //end of the packet
        in_ctrl = 8'h01;
        in_data = 64'h0000_0000_0000_4A00;
        #10;

		//stop writing
        in_wr = 1'b0;

		wait(uut.process_done == 1'b1);

		//wait for in_rdy signal stable
		#10;


		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

