`timescale 1ns/1ps

module fifo_tb;

    // Clock and Reset
    reg clk;
    reg reset;

    // NetFPGA Input
    reg [7:0]  in_ctrl;
    reg [63:0] in_data;
    reg in_wr;
    reg out_rdy;

    // NetFPGA Output
    wire [7:0]  out_ctrl;
    wire [63:0] out_data;
    wire out_wr;
    wire in_rdy;

    // Processor Input
    reg [63:0] proc_data_in;
    reg [7:0]  proc_addr_in;
    reg proc_web;
    reg proc_memEn;
    reg pin_di;

    // Processor Output
    wire [63:0] proc_data_out;
    wire p_en;

    // Debugging Pins for SW/HW Register
    reg [7:0] memAddressQuery;
    wire [71:0] memDataOut;

    // Packet Counter
    wire [8:0] packet_count;

    // Instantiate the DUT (Device Under Test)
    lab8_fifo uut (
        .clk(clk),
        .reset(reset),
        .in_data(in_data),
        .in_ctrl(in_ctrl),
        .in_wr(in_wr),
        .out_rdy(out_rdy),
        .proc_data_in(proc_data_in),
        .proc_addr_in(proc_addr_in),
        .proc_web(proc_web),
        .proc_memEn(proc_memEn),
        .pin_di(pin_di),
        .packet_count(packet_count),
        .out_ctrl(out_ctrl),
        .out_data(out_data),
        .out_wr(out_wr),
        .in_rdy(in_rdy),
        .proc_data_out(proc_data_out),
        .p_en(p_en),
        .memAddressQuery(memAddressQuery),
        .memDataOut(memDataOut)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task: Initialize
    task Initialize;
        begin
            clk = 0;
            reset = 0;
            in_ctrl = 8'b0;
            in_data = 64'b0;
            in_wr = 0;
            out_rdy = 0;
            proc_data_in = 64'b0;
            proc_addr_in = 8'b0;
            proc_web = 0;
            proc_memEn = 0;
            pin_di = 0;
            memAddressQuery = 8'b0;

            // Release reset
            #10;
            reset = 1;

            $display("Initialization complete at %t", $time);
        end
    endtask

    // Task: Send a packet
    task send_packet;
        input [4:0] packet_size; // Number of words in the packet
        input [63:0] base_packet; // Base value for packet data
        integer i;
        begin
            wait(in_rdy); // Wait for IDLE state
            // Send the first few words of the packet
            for (i = 0; i < packet_size - 1; i = i + 1) begin
                @(posedge clk);
                in_wr = 1;
                in_ctrl = 8'h00; // Regular packet word
                in_data = base_packet + i;
                @(posedge clk);
            end

            // Send the last word of the packet
            @(posedge clk);
            in_ctrl = 8'h01; // End of packet
            in_data = base_packet + packet_size - 1;
            in_wr = 1;
            @(posedge clk);
            @(posedge clk);
            in_wr = 0;

            $display("Sent packet with %0d words at %t", packet_size, $time);
        end
    endtask

    // Task: Process a packet
    task process_packet;
        input [7:0] start_address; // Start address in memory
        input [4:0] packet_size; // Number of words in the packet
        integer i;
        begin
            wait(p_en); // Wait for EX state
            for (i = 0; i < packet_size; i = i + 1) begin
                @(posedge clk);
                proc_addr_in = start_address + i;
                proc_memEn = 1'b1; // Enable memory read
                proc_web = 1'b0;

                @(posedge clk); // Read data occurs in next clock cycle

                // Modify data and write back to memory
                @(posedge clk);
                proc_data_in = proc_data_out + 64'h0000_0000_0000_1000;
                proc_web = 1'b1;

                @(posedge clk);
                proc_memEn = 1'b0;
                proc_web = 1'b0;
            end

            @(posedge clk);
            pin_di = 1'b1; // Indicate processing done
            @(posedge clk);
            pin_di = 1'b0;
        end
    endtask

    // Task: Receive a packet
    task receive_packet;
        input [4:0] packet_size; // Number of words to receive
        integer i;
        begin
            out_rdy = 1'b1;

            for (i = 0; i < packet_size; i = i + 1) begin
                wait(out_wr);
                @(posedge clk);
            end

            out_rdy = 1'b0;
        end
    endtask

    // Test procedure
    initial begin
        Initialize; // Initialize the testbench
        #10;

        // Test 1: Send, process, and receive a packet
        send_packet(5'd5, 64'h0000_0000_0000_0002);
        #10;
        process_packet(8'h00, 5'd5);
        #10;
        receive_packet(5'd5);
        #20;

        // Test 2: Send a larger packet
        send_packet(5'd10, 64'h0000_0000_0000_1000);
        #10;
        process_packet(8'h10, 5'd10);
        #10;
        receive_packet(5'd10);
        #20;

        // End of simulation

    end

endmodule