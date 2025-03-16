`timescale 1ns / 1ps

module ids(
	input clk,
	input reset,
	//Instruction memory inputs, allows us to set i-mem
	input [1:0] thread_num,
	input input_grant,
    input output_grant,
	input [8:0] instrMem_addr,
	input [31:0] instrMem_data,
	input instrMem_wea,
	//Data memory input signals, allows us to set d-mem
	input [7:0] dMem_addrTopLevel,
	input [63:0] dMem_dataTopLevel,
	input [2:0] mode,
	input [63:0] in_data,
	input [7:0] in_ctrl,
	input in_wr,
	output in_rdy,
	output [63:0] out_data,
	output [7:0] out_ctrl,
	output out_wr,
	input out_rdy,
	output reg thread_can_inc,
	
	output processor_control_out,
	output output_req,
	output PCsel,
	output [8:0]  jump_address,
	//Outputs to read imem and dmem
	output [31:0] dMem_outHiTopLevel,
	output [31:0] dMem_outLoTopLevel,
	output [31:0] iMem_outTopLevel
);
	/*INTERNAL SIGNALS AND REGISTERS*/
	
	// IFID Register: This register is primarily used in the Instruction Fetch and Decode stages.
	reg [42:0] IFIDReg; // Stores the instruction meant for the controller.
	// Breakdown of IFID Register bits:
	// | Bits 9-0 are for various control signals like branch, jump, ALU control, ALU source, memory to register transfer, memory write, and register write. |

	// IDEX Register: Intermediate pipeline register between Instruction Decode and Execute stages.
	reg [243:0] IDEXReg; 
	// Breakdown of IDEX Register bits:
	// | Bits 243-242 for thread_num, 241-238 for MSB flags for registers B and A, 237 for jal, 236-228 for link address,
	// | 227-212 for control signals for two output registers, 211-202 for controller signals, 201-74 for two 64-bit data outputs,
	// | 73-68 for shamt, 67-4 for sign extended value, 3-0 for destination ID. |

	// EXMEM Register: Used between Execute and Memory Access stages, holding execution results and control signals.
	reg [230:0] EXMEMReg; 
	// Breakdown of EXMEM Register bits:
	// | Bits 230-226 for thread number, 225-202 for control and ALU signals, 201-67 for ALU outputs and register IDs, 
	// | 66-3 for memory address and control, 2-0 for destination ID. |

	// MEMWB Register: Used between Memory Access and Write Back stages, containing data to be written back into registers.
	reg [163:0] MEMWBReg; 
	// Breakdown of MEMWB Register bits:
	// | Bits 163-159 for thread number and MSB ALU flags, 158-149 for jump and link address, 
	// | 148-133 for memory output control, 132-67 for ALU output and memory data, 
	// | 66-3 for memory output and additional flags, 2-0 for destination ID. |
		
	//Actual Registers to hold items except data
	reg [1:0] thread_num_stage1;
	reg [1:0] thread_num_stage2;
	reg [1:0] thread_num_stage3;
	reg [1:0] thread_num_stage4;
	// since we remove output dffs of registerFile, so we need 2 74bit dffs instead of original 8 dffs.
	reg [71:0] r1Out_stage2;
	reg [71:0] r2Out_stage2;
	
	reg jal_stage3;
	reg jal_stage4;
	reg [8:0] link_addr_stage1;
	reg [8:0] link_addr_stage2;
	reg [8:0] link_addr_stage3;
	reg [8:0] link_addr_stage4;
	
	reg [7:0] control_stage2;
  reg [7:0] control_stage3;
  reg [7:0] r2Out_ctrl_stage3;
	reg [7:0] r1Out_ctrl_stage3;
	reg [7:0] r1Out_ctrl_stage4;
	reg [3:0] destinationID_stage2;
	reg [3:0] destinationID_stage3;
	reg [3:0] destinationID_stage4;
	reg memtoreg_stage3;
	reg memWrite_stage3;
	reg regWrite_stage3;
	reg branch_stage3;
	reg jump_stage3;
	reg memtoreg_stage4;
	reg regWrite_stage4;
	//Registers to hold non-delayed data
	reg [5:0]  shamt_stage2;
	reg [63:0] extended_data_stage2;
	reg [63:0] Rb_stage3;
	reg [63:0] Ra_stage3;
	reg [63:0] ALU_stage4;
	
    
	//Intermediate signals for i-mem
	wire [31:0] instrMemOut;
	
	//intermediate signals for register file
	wire [71:0] r1Out_thread0;
	wire [71:0] r2Out_thread0;
	wire [71:0] r1Out_thread1;
	wire [71:0] r2Out_thread1;
	wire [71:0] r1Out_thread2;
	wire [71:0] r2Out_thread2;
	wire [71:0] r1Out_thread3;
	wire [71:0] r2Out_thread3;
	// output of two 4to1 74-bit muxes
	wire [71:0] r1Out;
	wire [71:0] r2Out;
	
	wire [3:0] r1Addr;
	wire [3:0] r2Addr;
	wire [71:0] regfile_wdata;
	wire [3:0] regfile_waddr;
	
	wire regfile_wena0;
	wire regfile_wena1;
	wire regfile_wena2;
	wire regfile_wena3;
	
	wire [63:0] extended_data;
	//intermediate signals for controller
	wire [5:0] opcode;
	wire [3:0] aluctrl_c;
	wire alusrc;
	wire memtoreg;
	wire memWrite;
	wire regWrite;
	wire branch;
	wire jump;
	
	wire jal;
	
	//intermediate signals for alu
	wire [63:0] aluOut;
	wire [63:0] aluA;
	wire [63:0] aluB;
	wire [5:0] shamt;
	wire [3:0] aluctrl;  //driven by controller
	
	//intermediate signals for dmem
	wire [71:0] dMemOut;
	wire dMem_wena;
	wire [71:0] dMemIn;
	wire [7:0] dMemAddr;

	// intermediate signals for jal
	wire [8:0] jal_addr; 
	//intermediate signals for netfpga datapath
	wire valid_data;
	wire fifo_empty;
	wire fifo_read;
	reg [2:0]                     state, state_next;
	reg                           in_pkt_body, in_pkt_body_next;
	reg                           end_of_pkt, end_of_pkt_next;
	reg                           begin_pkt, begin_pkt_next;
	reg [2:0]                     header_counter, header_counter_next;
	reg [2:0]                     num_of_halt, num_of_halt_next;
	reg							  processor_control, processor_control_next;
	reg							  processor_done, processor_done_next;
	reg							  fifo_ready, fifo_ready_next;
	reg							  mem_pointer_reset, mem_pointer_reset_next;
	parameter                     START = 3'b000;
	parameter                     HEADER = 3'b001;
	parameter                     PAYLOAD = 3'b010;
	parameter					  PROCESS = 3'b011;
	parameter					  FORWARD = 3'b100;
	parameter					  REGISTER = 3'b101;
	parameter					  RESET = 3'b110;
		
	//ASSIGNS FOR INTERMEDIATE SIGNALS
	//assigns for regfile
	assign r1Addr = IFIDReg[21:18];// Ra
	assign r2Addr = IFIDReg[17:14];// Rb
	assign jal_addr = MEMWBReg[158:150] + 1'b1;
	assign regfile_wdata = MEMWBReg[159] ? {63'b0, jal_addr} : (MEMWBReg[133] ? {MEMWBReg[149:142], MEMWBReg[67:4]} : {MEMWBReg[141:134], MEMWBReg[131:68]});//output of last stage
	
	assign regfile_wena0 = MEMWBReg[132] && (!MEMWBReg[163]) && (!MEMWBReg[162]);//wr_reg after last pipeline stage
	assign regfile_wena1 = MEMWBReg[132] && (!MEMWBReg[163]) && (MEMWBReg[162]);//wr_reg after last pipeline stage
	assign regfile_wena2 = MEMWBReg[132] && (MEMWBReg[163])  && (!MEMWBReg[162]);//wr_reg after last pipeline stage
	assign regfile_wena3 = MEMWBReg[132] && (MEMWBReg[163])  && (MEMWBReg[162]);//wr_reg after last pipeline stage
	assign r1Out = IFIDReg[42] ? (IFIDReg[41] ? r1Out_thread3 : r1Out_thread2) : (IFIDReg[41] ? r1Out_thread1 : r1Out_thread0);
	assign r2Out = IFIDReg[42] ? (IFIDReg[41] ? r2Out_thread3 : r2Out_thread2) : (IFIDReg[41] ? r2Out_thread1 : r2Out_thread0);
	
	assign regfile_waddr = MEMWBReg[3:0]; //wreg1 after last pipeline stage
	//ASSIGN FOR CONTROLLER
	assign opcode = IFIDReg[31:26];
	//ASSIGN FOR SIGN 
	assign extended_data = {{50{IFIDReg[13]}}, IFIDReg[13:0]}; //sign extension
	assign PCsel = (EXMEMReg[136] && EXMEMReg[4]) || EXMEMReg[135];
	assign jump_address = EXMEMReg[145:137];
	
	//ASSIGNS FOR ALU
	assign aluA = IDEXReg[201:138];
	assign aluB = IDEXReg[205] ? IDEXReg[67:4] : IDEXReg[137:74];
	assign shamt = IDEXReg[73:68];
	assign aluctrl = IDEXReg[209:206];
	
	//ASSIGNS FOR DMEM - DEPENDS ON MODE
	// mode 0 - instruction read
	// mode 1 - instruction write
	// mode 2 - data read
	// mode 3 - data write
	// mode 4 - CPU execute
	assign dMem_wena = mode[2] ? EXMEMReg[133] : (mode[1] ? (mode[0] ? 1'b1 : 1'b0) : 1'b0);
	assign dMemIn = mode[2] ? {EXMEMReg[216:209], EXMEMReg[67:4]} : (mode[1] ? (mode[0] ? {8'b0,dMem_dataTopLevel} : 72'bX ) : 72'bX);
	assign dMemAddr = mode[2] ? EXMEMReg[75:68] : (mode[1] ? dMem_addrTopLevel : 8'bX); 
	
	//ASSIGNS FOR PIPES
	assign IFIDReg[42:41] = thread_num_stage1;
	assign IFIDReg[40:32] = link_addr_stage1;
	assign IFIDReg[31:0] = instrMemOut;
	
	assign IDEXReg[243:242] = thread_num_stage2;
	assign IDEXReg[241] = r2Out[73]; 
	assign IDEXReg[240] = r2Out[72];
	assign IDEXReg[239] = r1Out[73];
	assign IDEXReg[238] = r1Out[72];
	assign IDEXReg[241] = r2Out_stage2[73]; 
	assign IDEXReg[240] = r2Out_stage2[72];
	assign IDEXReg[239] = r1Out_stage2[73];
	assign IDEXReg[238] = r1Out_stage2[72];
	assign IDEXReg[237] = jal;
	assign IDEXReg[236:228] = link_addr_stage2;
	assign IDEXReg[227:220] = r2Out[71:64];
	assign IDEXReg[219:212] = r1Out[71:64];
	assign IDEXReg[227:220] = r2Out_stage2[71:64];
	assign IDEXReg[219:212] = r1Out_stage2[71:64];
	assign IDEXReg[211:202] = {branch, jump, aluctrl_c, alusrc, memtoreg, memWrite, regWrite};
	assign IDEXReg[201:138] = r1Out[63:0];
	assign IDEXReg[137:74] = r2Out[63:0];     
	assign IDEXReg[201:138] = r1Out_stage2[63:0];
	assign IDEXReg[137:74] = r2Out_stage2[63:0]; 	
	assign IDEXReg[73:68] = shamt_stage2;
	assign IDEXReg[67:4] = extended_data_stage2;
	assign IDEXReg[3:0] = destinationID_stage2;

	assign EXMEMReg[230:229] = thread_num_stage3;
	assign EXMEMReg[228] = aluOut[65];
	assign EXMEMReg[227] = aluOut[64];
	assign EXMEMReg[226] = jal_stage3;
	assign EXMEMReg[225:217] = link_addr_stage3;
	assign EXMEMReg[216:209] = r2Out_ctrl_stage3;
	assign EXMEMReg[208:201] = r1Out_ctrl_stage3;
	assign EXMEMReg[200:137] = Ra_stage3;
	assign EXMEMReg[136] = branch_stage3;
	assign EXMEMReg[135] = jump_stage3;
	assign EXMEMReg[134] = memtoreg_stage3;
	assign EXMEMReg[133] = memWrite_stage3;
	assign EXMEMReg[132] = regWrite_stage3;
	assign EXMEMReg[131:68] = aluOut;
	assign EXMEMReg[67:4] = Rb_stage3;
	assign EXMEMReg[3:0] = destinationID_stage3;

	assign MEMWBReg[163:162] = thread_num_stage4;
	assign MEMWBReg[161] = ALU_stage4[65];
	assign MEMWBReg[160] = ALU_stage4[64];
	assign MEMWBReg[159] = jal_stage4;
	assign MEMWBReg[158:150] = link_addr_stage4;
	assign MEMWBReg[149:142] = dMemOut[71:64];
	assign MEMWBReg[141:134] = r1Out_ctrl_stage4;
	assign MEMWBReg[133] = memtoreg_stage4;
	assign MEMWBReg[132] = regWrite_stage4;
	assign MEMWBReg[131:68] = ALU_stage4;
	assign MEMWBReg[67:4] = dMemOut[63:0];
	assign MEMWBReg[3:0] = destinationID_stage4;
	
	//Assigns for outputs
	assign iMem_outTopLevel = instrMemOut;
	assign dMem_outHiTopLevel = dMemOut[63:32];
	assign dMem_outLoTopLevel = dMemOut[31:0];
	assign output_req = processor_done;

	//Assigns for NetFPGA datapath
	assign out_data = dMemOut[63:0]; //always dMemOut, whether or not it is valid data yet
	assign out_ctrl = dMemOut[71:64];//always dMemOut, whether or not it is valid data yet
	assign out_wr = valid_data;//wait until we have valid data in memory, and processor is done
	assign in_rdy = fifo_ready;
	assign fifo_read = out_rdy && output_grant;
	assign processor_control_out = processor_control;
	
	/*MODULE INSTANTIALIZE*/
	instrMem instructionMemory(
		.clka	(clk),
		.dina	(instrMem_data),//comes from top level
		.addra	(instrMem_addr),//comes from top level
		.wea	(instrMem_wea),//comes from top level
		.douta	(instrMemOut)
	);
	
	controller ctrller(
	  .opcode(opcode),
		.clk(clk),
		.aluctrl(aluctrl_c),
		.alusrc(alusrc),
		.memtoreg(memtoreg),
		.memWrite(memWrite),
		.regWrite(regWrite),
		.branch(branch),
		.jump(jump),
		.jal(jal)
    );

	regfile8 registerFile0(
		.r0addr(r1Addr), 
		.r1addr(r2Addr), 
		.wdata(regfile_wdata), 
		.read_en((!IFIDReg[42]) && (!IFIDReg[41])),
		.wena(regfile_wena0), 
		.waddr(regfile_waddr), 
		.CLK(clk), 
		.reset(reset), 
		.r0data(r1Out_thread0), 
		.r1data(r2Out_thread0)
	);

	regfile8 registerFile1(
		.r0addr(r1Addr), 
		.r1addr(r2Addr), 
		.wdata(regfile_wdata), 
		.read_en((!IFIDReg[42]) && (IFIDReg[41])),
		.wena(regfile_wena1), 
		.waddr(regfile_waddr), 
		.CLK(clk), 
		.reset(reset), 
		.r0data(r1Out_thread1), 
		.r1data(r2Out_thread1)
	);

	regfile8 registerFile2(
		.r0addr(r1Addr), 
		.r1addr(r2Addr), 
		.wdata(regfile_wdata), 
		.read_en((IFIDReg[42]) && (!IFIDReg[41])),
		.wena(regfile_wena2), 
		.waddr(regfile_waddr), 
		.CLK(clk), 
		.reset(reset), 
		.r0data(r1Out_thread2), 
		.r1data(r2Out_thread2)
	);

	regfile8 registerFile3(  
		.r0addr(r1Addr), 
		.r1addr(r2Addr), 
		.wdata(regfile_wdata), 
		.read_en((IFIDReg[42]) && (IFIDReg[41])),
		.wena(regfile_wena3), 
		.waddr(regfile_waddr), 
		.CLK(clk), 
		.reset(reset), 
		.r0data(r1Out_thread3), 
		.r1data(r2Out_thread3)
	);
	
	alu64 alu(
		.A(aluA),
		.B(aluB),
		.shamt(shamt),
		.aluctrl(aluctrl),
		.CLK(clk),   
		.Z(aluOut)    
	);
	
	memfifo dataMemory(
		.clk(clk), 
        .fiforead(fifo_read), 
        .fifowrite(in_wr && input_grant), 
        .firstword(begin_pkt),
        .in_fifo({in_ctrl, in_data}), //netfpga packet data 
        .lastword(end_of_pkt), 
        .processor_addr_in(dMemAddr), 
        .processor_control(processor_control), //1 for processor control, 0 for netfpga - just FIFO buffering now, no processing 
        .processor_data_in(dMemIn), 
        .processor_wea(dMem_wena), 
        .rst((reset || mem_pointer_reset)),//reset head and tail to zero every packet 
        .out_fifo(dMemOut), //mem data out
        .packet_head(), //OUTPUT: beginning addr of packet 
        .packet_tail(), //OUTPUT: end addr of packet 
        .valid_data(valid_data),   //OUTPUT
        .fifo_empty(fifo_empty)//Output, tells when our fifo is ready for a new packet
	);
	
	//pipelogic with additional registered delay added
	always @ (posedge clk) begin
	if(reset)
	begin
		thread_num_stage1 <= 0;
		thread_num_stage2 <= 0;
		thread_num_stage3 <= 0;
		thread_num_stage4 <= 0;
		r1Out_stage2 <= 0;
		r2Out_stage2 <= 0;
	
	  destinationID_stage2 <= 0;
		destinationID_stage3 <= 0;
		destinationID_stage4 <= 0;
		memtoreg_stage3 <= 0;
		memWrite_stage3 <= 0;
		regWrite_stage3 <= 0;
		branch_stage3 <= 0;
		jump_stage3 <= 0;
		memtoreg_stage4 <= 0;
		regWrite_stage4 <= 0;
		shamt_stage2 <= 0;
		extended_data_stage2 <= 0;
		Rb_stage3 <= 0;
		Ra_stage3 <= 0;
		ALU_stage4 <= 0;
		control_stage2 <= 0;
		control_stage3 <= 0;
		
		r2Out_ctrl_stage3 <= 0;
		r1Out_ctrl_stage3 <= 0;
		r1Out_ctrl_stage4 <= 0;
		
		jal_stage3 <= 0;
		jal_stage4 <= 0;
		link_addr_stage1 <= 0;
		link_addr_stage2 <= 0;
		link_addr_stage3 <= 0;
		link_addr_stage4 <= 0;
	end
	
	else begin	
		thread_num_stage1 <= thread_num;
		thread_num_stage2 <= IFIDReg[42:41];
		thread_num_stage3 <= IDEXReg[243:242];
		thread_num_stage4 <= EXMEMReg[230:229];
		r1Out_stage2 <= r1Out;
		r2Out_stage2 <= r2Out;
	
		destinationID_stage2 <= IFIDReg[25:22];
		destinationID_stage3 <= IDEXReg[3:0];
		destinationID_stage4 <= EXMEMReg[3:0];
		memtoreg_stage3 <= IDEXReg[204];
		memWrite_stage3 <= IDEXReg[203];
		regWrite_stage3 <= IDEXReg[202];
		memtoreg_stage4 <= EXMEMReg[134];
		regWrite_stage4 <= EXMEMReg[132];
		shamt_stage2 <= IFIDReg[13:8];
		extended_data_stage2 <= extended_data;
		Rb_stage3 <= IDEXReg[137:74];
		ALU_stage4 <= EXMEMReg[131:68];
		
		branch_stage3 <= IDEXReg[211];
		jump_stage3 <= IDEXReg[210];
		Ra_stage3 <= IDEXReg[201:138];
		
		control_stage2 <= MEMWBReg[141:134];
		control_stage3 <= IDEXReg[219:212];
		
		r2Out_ctrl_stage3 <= IDEXReg[227:220];
		r1Out_ctrl_stage3 <= IDEXReg[219:212];
		r1Out_ctrl_stage4 <= EXMEMReg[208:201];
		
		jal_stage3 <= IDEXReg[237];
		jal_stage4 <= EXMEMReg[226];
		link_addr_stage1 <= instrMem_addr;
		link_addr_stage2 <= IFIDReg[40:32];
		link_addr_stage3 <= IDEXReg[236:228];
		link_addr_stage4 <= EXMEMReg[225:217];
		
	end
	
	end
	
	//FSM
	always @(*) begin
    state_next = state;
    header_counter_next = header_counter;
		num_of_halt_next = num_of_halt;
    end_of_pkt_next = end_of_pkt;    // Maybe this can be FIFO FULL signal. If end_of_pkt = 1, then FIFO IS full. Otherwise, it is not full.
    in_pkt_body_next = in_pkt_body;  // Maybe this is the signal we can send to processor telling the data is ready to be processed.
	                                     // DON'T ingore header since we want to change information like TTL in the header
	  begin_pkt_next = begin_pkt;  // We can use this signal. In original ids.v the design for FIFO is circular, which means that
		processor_control_next = processor_control; // after we finish processing the first packet and the second packet is about to come, we do not reset the tailPtr.
		processor_done_next = processor_done;
		fifo_ready_next = fifo_ready;
		mem_pointer_reset_next = mem_pointer_reset;
		case(state)
			START: begin
				thread_can_inc = 1'b0;
				if ((in_ctrl != 1'b0) && input_grant) begin // If control bits are not 0, then we have new coming packet.
					state_next = HEADER;
					begin_pkt_next = 1'b1;
					end_of_pkt_next = 1'b0;
				end
				else if (!mode[2]) begin
					state_next = REGISTER;
					fifo_ready_next = 1'b0;
					begin_pkt_next = 1'b0;
					end_of_pkt_next = 1'b1;
				end
			end
			HEADER: begin
				begin_pkt_next = 1'b0;
				if (in_ctrl == 1'b0) begin
					 header_counter_next = header_counter + 1'b1;
					if (header_counter_next == 2'b11) begin
						 state_next = PAYLOAD;
					end
				end
				if (!mode[2]) begin
					state_next = REGISTER;
					header_counter_next = 1'b0;
					end_of_pkt_next = 1'b1;
					fifo_ready_next = 1'b0;
				end
			end
			PAYLOAD: begin
				if (in_ctrl != 1'b0) begin
					state_next = PROCESS;
					header_counter_next = 1'b0;
					end_of_pkt_next = 1'b1;
					fifo_ready_next = 1'b0;
				end 
				//Stop receiving packet and listen to reg interface
				if(!mode[2]) begin
					state_next = REGISTER;
					header_counter_next = 1'b0;
					end_of_pkt_next = 1'b1;
					fifo_ready_next = 1'b0;
				end
			end
			PROCESS: begin
				processor_control_next = 1'b1;
				if(mode[2]) begin //Can only leave state if we are in execute mode
					thread_can_inc = 1'b1;
					if(opcode == 6'b111111) begin
						num_of_halt_next = num_of_halt + 1'b1;
					end
					if(num_of_halt_next == 3'b100) begin
						processor_done_next = 1'b1;
						thread_can_inc = 1'b0;
						processor_control_next = 1'b0;
						state_next = FORWARD;
					end
				end
				else begin
					thread_can_inc = 1'b0;
				end
			end
			FORWARD: begin
				thread_can_inc = 1'b0;
				if(fifo_empty) begin //once we are done sending packet out, then ask for next
					mem_pointer_reset_next = 1'b1;
					//wait until we finish forwarding so we don't stall pipeline
					if(!mode[2]) begin
						state_next = REGISTER;
					end
					else begin
						state_next = RESET;
					end
					processor_done_next = 1'b0; //processor not done again
				end

			end
			REGISTER: begin
				processor_control_next=1'b1;
				thread_can_inc = 1'b0;
				if(mode[2]) begin
					//Back to execute mode, so go back to reset then start state
					state_next = RESET;
					mem_pointer_reset_next=1'b1;
					processor_control_next = 1'b0;

				end
			end
			RESET: begin //this is just a dummy one clock state to reset packet pointers, and we can use it for other things later if we want
				num_of_halt_next = 3'b0;
				mem_pointer_reset_next = 1'b0;
				fifo_ready_next = 1'b1;
				state_next = START;
				if(!mode[2]) begin
					fifo_ready_next = 1'b0;
					state_next = REGISTER;
				end
			end
		endcase			
	end
	
	always @(posedge clk) begin
		if(reset) begin
			header_counter <= 0;
			num_of_halt <= 0;
			state <= START;
			begin_pkt <= 0;
			end_of_pkt <= 0;
			processor_control <= 0;
			processor_done <= 0;
			fifo_ready <= 1'b1;
			mem_pointer_reset <=0;
		end else begin
			header_counter <= header_counter_next;
			num_of_halt <= num_of_halt_next;
			state <= state_next;
			begin_pkt <= begin_pkt_next;
			end_of_pkt <= end_of_pkt_next;
			processor_control <= processor_control_next;
			processor_done <= processor_done_next;
			fifo_ready <= fifo_ready_next;
			mem_pointer_reset <= mem_pointer_reset_next;
        end // else: !if(reset)
    end // always @ (posedge clk)   

endmodule
