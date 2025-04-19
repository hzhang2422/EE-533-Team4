`timescale 1ns / 1ps

module drop_fifo_tb;

	// Inputs
	reg clk;
	reg rst;
	reg firstword;
	reg lastword;
	reg fifowrite;
	reg fiforead;
	reg [71:0] in_fifo;

	// Outputs
	wire [71:0] out_fifo;
	wire [8:0] depth;
	wire valid_data;

	// Instantiate the Unit Under Test (UUT)
	drop_fifo uut (
		.clk(clk), 
		.rst(rst), 
		.firstword(firstword), 
		.lastword(lastword), 
		.fifowrite(fifowrite), 
		.fiforead(fiforead), 
		.in_fifo(in_fifo), 
		.out_fifo(out_fifo), 
		.depth(depth), 
		.valid_data(valid_data)
	);

    always #5 clk = ~clk;

    task Send_Packet;
      input [7:0] packet_size;
      input [71:0] first_word;
      integer i;
      reg [71:0] payload_word;
      begin
        //send the first word of packet
        firstword = 1'b1; //set up firstword signal
        fifowrite = 1'b1;
        in_fifo = {8'h01, first_word[63:0]};

        #10;
        firstword = 1'b0; //reset firstword
        #10;

        //send the payload of packet
        for(i=1; i<packet_size-1; i=i+1) begin
            payload_word = first_word + i;
            in_fifo = payload_word;
            #10;
        end

        //send the end of packet
        lastword = 1'b1;
        in_fifo = {8'h01, payload_word[63:0]};

        #10;
        lastword = 1'b0;
        fifowrite = 1'b0;
        #10;
      end
    endtask



	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		firstword = 0;
		lastword = 0;
		fifowrite = 0;
		fiforead = 0;
		in_fifo = 0;

        #20;
        rst = 1;
        #20;
        rst = 0;

        #20;

        //Send a small number of packets into the FIFO
        Send_Packet(8'h0f, 72'h000000000010000000);
        Send_Packet(8'h0f, 72'h000000000020000000);

        #20;
        
        //Read packets from the FIFO as well as sending packets into the FIFO
        fiforead = 1'b1;
        Send_Packet(8'h0f, 72'h000000000030000000);
        
        //Read out all the packets from the FIFO
        #600;

        fiforead = 1'b0;

        //Send a large number of packets to fill the FIFO
        Send_Packet(8'h0f, 72'h000000000010000000);
        Send_Packet(8'h0f, 72'h000000000020000000);
        Send_Packet(8'h0f, 72'h000000000030000000);
        Send_Packet(8'h0f, 72'h000000000040000000);
        Send_Packet(8'h0f, 72'h000000000050000000);
        Send_Packet(8'h0f, 72'h000000000060000000);
        Send_Packet(8'h0f, 72'h000000000070000000);
        Send_Packet(8'h0f, 72'h000000000080000000);
        Send_Packet(8'h0f, 72'h000000000090000000);
        Send_Packet(8'h0f, 72'h0000000000A0000000);
        Send_Packet(8'h0f, 72'h0000000000B0000000);
        Send_Packet(8'h0f, 72'h0000000000C0000000);
        Send_Packet(8'h0f, 72'h0000000000D0000000);
        Send_Packet(8'h0f, 72'h0000000000E0000000);
        Send_Packet(8'h0f, 72'h0000000000F0000000);
        Send_Packet(8'h0f, 72'h00DEADBEEFF0000000);


		// Wait 100 ns for global reset to finish
		#100;


        
		// Add stimulus here

	end
      
endmodule