///////////////////////////////////////////////////////////////////////////////
// Module: processor.v
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module processor 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (      
      // --- Packet Data interface
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
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
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );


   //------------------------- Signals-------------------------------
   /*REGISTER INTERFACE*/
   // software registers 
    wire [31:0]                   instr_addr;
    wire [31:0]                   instr_data;
    wire [31:0]                   data_addr;
    wire [31:0]                   data_dataLow;
    wire [31:0]                   data_dataHigh;
    wire [31:0]                   datapath_cmd;
    wire [31:0]                   mode;
   
    // hardware registers
    reg [31:0]                    data_low0;
    reg [31:0]                    data_high0;
 
    //Top-level Instruction memory signals
	wire out_wr0;
	wire in_rdy0;
	
    // Defining instruction counters for four different threads, as we have a multithreading system.
    reg [6:0] instructionCounter0;  // Counter for thread 0, ranges from 0 to 127 (7 bits wide).
    reg [7:0] instructionCounter1;  // Counter for thread 1, ranges from 128 to 255 (8 bits wide).
    reg [8:0] instructionCounter2;  // Counter for thread 2, ranges from 256 to 383 (9 bits wide).
    reg [8:0] instructionCounter3;  // Counter for thread 3, ranges from 384 to 511 (9 bits wide).

    // The actual program counter used in our datapath, reflecting the current instruction's address.
    wire [8:0] PC; 
    wire [8:0] instrAddrIn; // Input to the instruction memory, indicating which instruction to fetch.

    // Implementing a round-robin scheduling mechanism for the four threads.
    reg [1:0] thread_num0; // 2-bit counter to track the current thread being executed (thread0, thread1, thread2, thread3).

    // Signals related to instruction memory and instruction fetch stage.
    wire [31:0] instrDataIn;  // Data to be written into the instruction memory.
    wire instrWeaIn;         // Write enable signal for the instruction memory.
    wire PCsel;              // Selector for choosing the next program counter value.
    wire [8:0] jump_address; // Address to jump to when executing a jump instruction.
    wire [31:0] instrDataOut; // Data read from the instruction memory.

    // Top level data memory signals for thread 0.
    wire [31:0] dataDataOut_hi0; // Higher 32 bits of the data read from memory.
    wire [31:0] dataDataOut_lo0; // Lower 32 bits of the data read from memory.

    // Control signals for the processor's operation and inter-thread communication.
    wire processor_control0;  // Control signal specific for the processor's operation for thread 0.
    wire thread_can_inc0;     // Indicates whether the thread's instruction counter can increment.
    wire gnt0;                // Grant signal for accessing shared resources.
    wire gnt0_output;         // Output of the grant signal after processing.
    wire output_req0;         // Request signal for sending data from the processor to external devices.

    // Packet data and control signals for interfacing with external devices or memory.
    wire [DATA_WIDTH-1:0] out_data0; // Output data from the processor for thread 0.
    wire [CTRL_WIDTH-1:0] out_ctrl0;  // Control signals associated with the output data for thread 0.

    // Determine the current program counter based on the active thread number.
    assign PC = thread_num0[1] ? (thread_num0[0] ? instructionCounter3 : instructionCounter2) 
                            : (thread_num0[0] ? {1'b0, instructionCounter1} 
                                                : {2'b0, instructionCounter0});
    // Assign instruction address input based on mode selection.
    assign instrAddrIn = mode[2] ? PC : (mode[1] ? 9'bX : instr_addr[8:0]);
    // Assign instruction data input based on mode selection.
    assign instrDataIn = mode[2] ? 32'bX : (mode[1] ? 32'bX : ( mode[0] ? instr_data : 32'bX ));
    // Determine the write enable signal for instruction memory based on mode selection.
    assign instrWeaIn = mode[2] ? 1'b0 : (mode[1] ? 1'b0 : ( mode[0] ? 1'b1 : 1'b0));


   //------------------------- Modules-------------------------------
	
   bus_arbiter input_bus_arbiter (
      //EDIT 4/12 TO CHANGE REQUEST SIGNALS
      .req0(in_rdy0),
	  .clk(clk), 
	  .rst(reset),
//	  .enable(),
	  .gnt0(gnt0),
   );

   ids dp0 (
      .clk (clk),
      .reset (reset),
	  .thread_num (thread_num0),
      .instrMem_addr  (instrAddrIn),
      .instrMem_data  (instrDataIn),
      .instrMem_wea (instrWeaIn),
      .dMem_addrTopLevel  (data_addr[7:0]),
      .dMem_dataTopLevel  ({data_dataHigh, data_dataLow}),
      .modeTopLevel  (mode[2:0]),  
	  .input_grant(gnt0),
	  .output_grant(gnt0_output),
	  .in_data (in_data),
	  .in_ctrl (in_ctrl),
      .in_wr (in_wr),
	  .in_rdy (in_rdy0),
	  .out_data (out_data0),
	  .out_ctrl (out_ctrl0),
  	  .out_wr (out_wr0),
  	  .out_rdy (out_rdy),
	  .thread_can_inc (thread_can_inc0),  // used for incrementing thread_num
      .processor_control_out(processor_control0),
      .output_req(output_req0),
  	  .PCsel(PCsel),
  	  .jump_address(jump_address),
      .dMem_outHiTopLevel (dataDataOut_hi0),
      .dMem_outLoTopLevel (dataDataOut_lo0),
      .iMem_outTopLevel (instrDataOut)
   );
   
   bus_arbiter output_bus_arbiter (
      .req0(output_req0),
	  .clk(clk), 
	  .rst(reset),
	  .gnt0(gnt0_output),
   );
   
   assign out_wr = out_wr0;
   assign out_data = out_data0;
   assign out_ctrl = out_ctrl0;
   assign in_rdy = in_rdy0;
   
   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (7),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (4)                  // Number of hw regs
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
      .software_regs    ({mode}),

      // --- HW regs interface
      .hardware_regs    ({data_low0, data_high0}),

      .clk              (clk),
      .reset            (reset)
    );

   //------------------------- Logic-------------------------------   
   
    always @(posedge clk) begin
        if(reset) begin
            // Set initial values for instruction counters for each thread.
            instructionCounter0 <= 7'b0;       // Set for thread 0.
            instructionCounter1 <= 8'h80;      // Set for thread 1, starts at 128.
            instructionCounter2 <= 9'h100;     // Set for thread 2, starts at 256.
            instructionCounter3 <= 9'h180;     // Set for thread 3, starts at 384.
            thread_num0 <= 2'b0;               // Reset the thread counter to 0.
            data_low0 <= 32'b0;                // Reset the lower data register.
            data_high0 <= 32'b0;               // Reset the higher data register.
        end
        else begin
            // If datapath command indicates, reset data registers to zero.
            if (datapath_cmd[0]) begin
                data_low0 <= 32'b0;
                data_high0 <= 32'b0;
            end 
            else begin
                // Data read mode: fetch data from memory and reset instruction counters and thread number.
                if((!mode[2]) && (mode[1]) && (!mode[0])) begin
                    data_low0 <= dataDataOut_lo0;  // Load the lower part of data from memory.
                    data_high0 <= dataDataOut_hi0; // Load the higher part of data from memory.
                    // Reset instruction counters and thread number as it's a new cycle.
                    instructionCounter0 <= 7'b0;
                    instructionCounter1 <= 8'h80;
                    instructionCounter2 <= 9'h100;
                    instructionCounter3 <= 9'h180;
                    thread_num0 <= 2'b0;
                end
                // Instruction read mode: reset data registers, instruction counters, and thread number.
                else if ((!mode[2]) && (!mode[1]) && (!mode[0])) begin
                    data_high0 <= instrDataOut; // Store instruction data.
                    data_low0 <= 32'b0;         // Clear the lower data register.
                    // Reset instruction counters and thread number to start values.
                    instructionCounter0 <= 7'b0;
                    instructionCounter1 <= 8'h80;
                    instructionCounter2 <= 9'h100;
                    instructionCounter3 <= 9'h180;
                    thread_num0 <= 2'b0;
                end     
                // Execution mode: check processor control and update counters accordingly.
                else if(mode[2]) begin
                    if(!processor_control0) begin // Processor is idle, reset counters and thread number.
                        thread_num0 <= 2'b0;
                        instructionCounter0 <= 7'b0;
                        instructionCounter1 <= 8'h80;
                        instructionCounter2 <= 9'h100;
                        instructionCounter3 <= 9'h180;
                    end 
                    else if (PCsel) begin // If PC selection is enabled, jump to specified address.
                        // Update the instruction counter for the current thread based on jump_address.
                        case(thread_num0)
                            2'b11: instructionCounter3 <= jump_address; // Thread 3
                            2'b10: instructionCounter2 <= jump_address; // Thread 2
                            2'b01: instructionCounter1 <= jump_address[7:0]; // Thread 1
                            default: instructionCounter0 <= jump_address[6:0]; // Thread 0
                        endcase
                    end
                    else begin
                        // Round-robin scheduling: increment the thread counter if allowed.
                        if (thread_can_inc0) begin
                            thread_num0 <= thread_num0 + 1'b1;
                        end
                        // Increment instruction counters based on the current thread and check for overflow.
                        case(thread_num0)
                            2'b11: // Thread 3
                                instructionCounter3 <= (instructionCounter3 == 9'h1ff) ? 9'h180 : instructionCounter3 + 1'b1;
                            2'b10: // Thread 2
                                instructionCounter2 <= (instructionCounter2 == 9'h17f) ? 9'h100 : instructionCounter2 + 1'b1;
                            2'b01: // Thread 1
                                instructionCounter1 <= (instructionCounter1 == 8'hff) ? 8'h80 : instructionCounter1 + 1'b1;
                            default: // Thread 0
                                instructionCounter0 <= (instructionCounter0 == 7'h7f) ? 7'b0 : instructionCounter0 + 1'b1;
                        endcase
                    end
                end
            end
        end // else: !if(reset)
    end // always @(posedge clk)




endmodule 