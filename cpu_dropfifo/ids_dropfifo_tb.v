`timescale 1ns / 1ps

module ids_dropfifo_tb;

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
	reg reset;
	reg clk;

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

	// Instantiate the Unit Under Test (UUT)
	ids_dropfifo uut (
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

        //some invalid data
        in_ctrl = 8'h00;
        in_data = 64'h000000000010000000;
        #10;
        
        in_data = 64'h000000000020000000;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule