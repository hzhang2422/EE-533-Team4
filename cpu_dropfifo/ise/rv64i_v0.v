`timescale 1ns/1ps

`define UDP_REG_ADDR_WIDTH 16
`define CPCI_NF2_DATA_WIDTH 16

module rv64i_v0
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
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

      //sw/hw  registers interface
      input [31:0]                        cmd_in,
      input [31:0]                        din_low,
      input [31:0]                        din_high,
      
      output reg [31:0]                   cmd_out,
      output reg [31:0]                   dout_low,
      output reg [31:0]                   dout_high,
      
      //match signal from detect engine
      input                               match,

      // misc
      input                                reset,
      input                                clk
   );

assign reg_req_out = reg_req_in;
assign reg_ack_out = reg_ack_in;
assign reg_rd_wr_L_out = reg_rd_wr_L_in;
assign reg_addr_out = reg_addr_in;
assign reg_data_out = reg_data_in;
assign reg_src_out =  reg_src_in;

reg new_reset;

//latch 1 cycle to meet the FSM next state logic
reg in_wr_reg;
reg [DATA_WIDTH-1:0]  in_data_reg;
reg [CTRL_WIDTH-1:0]  in_ctrl_reg;

//FSM state
reg [1:0] state, state_next;

//local parameter
parameter START = 2'b00;
parameter HEADER = 2'b01;
parameter PAYLOAD = 2'b10;
parameter CPU     = 2'b11;

//FSM signal
reg begin_pkt, begin_pkt_next;
reg end_pkt, end_pkt_next;

//mode switch signal
reg stop_in_rdy, cpu_mode, cpu_mode_next, process_done;

// //register interface
// //software register for regwrite
// wire [31:0]  cmd_in;
// wire [31:0]  din_low;
// wire [31:0]  din_high;
// //hardware register for regread
// reg [31:0]  cmd_out;
// reg [31:0]  dout_low;
// reg [31:0]  dout_high;

// generic_regs
// #( 
// 	.UDP_REG_SRC_WIDTH	(UDP_REG_SRC_WIDTH),
// 	.TAG              (`PIPELINE_BLOCK_ADDR),        
// 	.REG_ADDR_WIDTH   (`PIPELINE_REG_ADDR_WIDTH), 
// 	.NUM_COUNTERS       (0),             
// 	.NUM_SOFTWARE_REGS  (3),           
// 	.NUM_HARDWARE_REGS  (3)             
// ) module_regs (
// 	.reg_req_in       (reg_req_in),
// 	.reg_ack_in       (reg_ack_in),
// 	.reg_rd_wr_L_in   (reg_rd_wr_L_in),
// 	.reg_addr_in      (reg_addr_in),
// 	.reg_data_in      (reg_data_in),
// 	.reg_src_in       (reg_src_in),

// 	.reg_req_out      (reg_req_out),
// 	.reg_ack_out      (reg_ack_out),
// 	.reg_rd_wr_L_out  (reg_rd_wr_L_out),
// 	.reg_addr_out     (reg_addr_out),
// 	.reg_data_out     (reg_data_out),
// 	.reg_src_out      (reg_src_out),

// 	// --- counters interface
// 	.counter_updates  (),
// 	.counter_decrement(),

// 	// --- SW regs interface
// 	.software_regs    ({din_high, din_low, cmd_in}),

// 	// --- HW regs interface
// 	.hardware_regs    ({dout_high, dout_low, cmd_out}),

// 	.clk              (clk),
// 	.reset            (reset)
// );

/************************register signal**************/
//control signal
wire pipeline_en = cmd_in[31] | cpu_mode;
wire req_in = cmd_in[30];
wire rw_in = cmd_in[29];
wire rst_in = cmd_in[28];
//data memory input/output
wire [63:0] din = {din_high, din_low};
wire [7:0] daddr = cmd_in[7:0];


//data memory input/ouput signal
wire [63:0] dmem_data;
wire [7:0] dmem_addr;
wire dmem_write;
wire dmem_read;
wire [63:0] dmem_out;
reg [63:0] out_dmem;

always @(posedge clk) begin
  cmd_out <= cmd_in;
  out_dmem <= dmem_out;
  {dout_high, dout_low} <= (req_in & rw_in) ? out_dmem : 64'b0;
end

/*********internal signal***************/
wire pause; // stall
wire flush; // flush
wire [1: 0] forwardA, forwardB; // forwording
wire forwardC; // hazard forwarding


// IF stage
wire [63: 0] if_pc; // instrction
wire [63: 0] if_pc4; // pc + 4
wire [63: 0] if_nextPc; // next instruction
wire [31: 0] if_instr;

// ID stage
wire [63: 0] id_pc;
wire [31: 0] id_instr;
wire [63: 0] id_imm64; // 64bit immediate number
wire [63: 0] id_rs1Data, id_rs2Data;
wire [4:  0] id_rd, id_rs1, id_rs2;

wire [6: 0] id_opcode; // opcode
wire [2: 0] id_func3; 
wire [6: 0] id_func7;

wire [4:  0] id_aluc; // aluctrl
wire id_aluOut_WB_memOut; //mux2
wire id_rs1Data_EX_PC; //mux2
wire[1: 0] id_rs2Data_EX_imm64_4; //mux3
wire id_writeReg;
wire id_writeMem; 
wire id_readMem;
wire [2: 0] id_extOP;
wire [1: 0] id_pcImm_NEXTPC_rs1Imm;

// EX stage
wire [4:  0] ex_aluc; 
wire ex_aluOut_WB_memOut; 
wire ex_rs1Data_EX_PC;
wire[1: 0] ex_rs2Data_EX_imm64_4;
wire ex_writeReg;
wire ex_writeMem;
wire ex_readMem;
wire[1: 0] ex_pcImm_NEXTPC_rs1Imm; 
wire [63: 0] ex_pc;
wire [63: 0] ex_rs1Data, ex_rs2Data;
wire [63: 0] ex_true_rs1Data, ex_true_rs2Data;
wire [63: 0] ex_imm64;
wire [4: 0] ex_rd, ex_rs1, ex_rs2;
wire [63: 0] ex_inAluA, ex_inAluB;
wire [63: 0] ex_pcImm, ex_rs1Imm;
wire [63: 0] ex_outAlu;
wire ex_conditionBranch;

// ME stage
wire me_aluOut_WB_memOut; 
wire me_writeReg; 
wire me_writeMem;
wire me_readMem;
wire[1: 0] me_pcImm_NEXTPC_rs1Imm;
wire me_conditionBranch;
wire [63:0] me_pc;
wire [63: 0] me_pcImm, me_rs1Imm;
wire [63: 0] me_outAlu;
wire [63: 0] me_rs2Data;
wire [4: 0] me_rd;
wire [4: 0] me_rs2;
wire [63: 0] me_true_rs2Data;
wire [63: 0] me_outMem;

// WB stage
wire wb_aluOut_WB_memOut; 
wire wb_writeReg;
wire [63: 0] wb_outMem;
wire [63: 0] wb_outAlu;
wire [63: 0] wb_rdData;
wire [4: 0] wb_rd;

next_pc NEXT_PC(
    .pcImm_NEXTPC_rs1Imm(me_pcImm_NEXTPC_rs1Imm),
    .condition_branch(me_conditionBranch),

    .pc4(if_pc4),
    .pcImm(me_pcImm),
    .rs1Imm(me_rs1Imm),

    .next_pc(if_nextPc),
    .flush(flush)
);

add_4 ADD_4(
    .pc(if_pc),

    .pc_4(if_pc4)
);

pc PC(
    .rst(reset|rst_in|new_reset),
    .clk(clk),
    .pause(pause),
    .flush(flush),
    .pipeline_en(pipeline_en),
    .next_pc(if_nextPc),

    .pc(if_pc)
);

instruction_mem INSTRUCTION_MEM(
    .pc(if_pc),

    .instruction(if_instr)
);

// ********************************
//         IF/ID
// ********************************
if_id IF_ID(
    .clk(clk),
    .rst(reset|rst_in|new_reset),
    .pause(pause),
    .flush(flush),
    .pipeline_en(pipeline_en),

    .if_pc(if_pc),
    .if_instr(if_instr),

    .id_pc(id_pc),
    .id_instr(id_instr)
);

id ID(
    .instr(id_instr),

    // decode
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),
    .rd(id_rd),
    .rs1(id_rs1),
    .rs2(id_rs2)
);

controller CONTROLLER(
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),

    .aluc(id_aluc),
    .aluOut_WB_memOut(id_aluOut_WB_memOut),
    .rs1Data_EX_PC(id_rs1Data_EX_PC),
    .rs2Data_EX_imm64_4(id_rs2Data_EX_imm64_4),
    .write_reg(id_writeReg),
    .write_mem(id_writeMem),
    .read_mem(id_readMem),
    .extOP(id_extOP),
    .pcImm_NEXTPC_rs1Imm(id_pcImm_NEXTPC_rs1Imm)
);

reg_file REG_FILE(
    .rst(reset|rst_in|new_reset),
    .clk(clk),
    .write_reg(wb_writeReg),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .target_reg(wb_rd),
    .write_rd_data(wb_rdData),

    .read_rs1_data(id_rs1Data),
    .read_rs2_data(id_rs2Data)
);


imm_64 imm_64(
    .instr(id_instr),
    .extOP(id_extOP),

    .imm_64(id_imm64)
);


hazard_detection_unit HAZARD_DETECTION_UNIT(
    .ex_readMem(ex_readMem),
    .ex_rd(ex_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .pause(pause)
);

// ********************************
//         ID/EX
// ********************************
id_ex ID_EX(
    .clk(clk),
    .rst(reset|rst_in|new_reset),
    .pause(pause),
    .flush(flush),
    .pipeline_en(pipeline_en),

    .id_aluc(id_aluc),
    .id_aluOut_WB_memOut(id_aluOut_WB_memOut),
    .id_rs1Data_EX_PC(id_rs1Data_EX_PC),
    .id_rs2Data_EX_imm64_4(id_rs2Data_EX_imm64_4),
    .id_writeReg(id_writeReg),
    .id_writeMem(id_writeMem),
    .id_readMem(id_readMem),
    .id_pcImm_NEXTPC_rs1Imm(id_pcImm_NEXTPC_rs1Imm), //jump choice
    .id_pc(id_pc),
    .id_rs1Data(id_rs1Data),
    .id_rs2Data(id_rs2Data),
    .id_imm64(id_imm64),
    .id_rd(id_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .ex_aluc(ex_aluc),
    .ex_aluOut_WB_memOut(ex_aluOut_WB_memOut),
    .ex_rs1Data_EX_PC(ex_rs1Data_EX_PC),
    .ex_rs2Data_EX_imm64_4(ex_rs2Data_EX_imm64_4),
    .ex_writeReg(ex_writeReg),
    .ex_writeMem(ex_writeMem),
    .ex_readMem(ex_readMem),
    .ex_pcImm_NEXTPC_rs1Imm(ex_pcImm_NEXTPC_rs1Imm),
    .ex_pc(ex_pc),
    .ex_rs1Data(ex_rs1Data),
    .ex_rs2Data(ex_rs2Data),
    .ex_imm64(ex_imm64),
    .ex_rd(ex_rd),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2)
);
//forwarding from Mem stage
mux_3 MUX_FORWARD_A(
    .signal(forwardA),
    .a(ex_rs1Data),
    .b(me_outAlu),
    .c(wb_rdData),

    .out(ex_true_rs1Data)
);

mux_3 MUX_FORWARD_B(
    .signal(forwardB),
    .a(ex_rs2Data),
    .b(me_outAlu),
    .c(wb_rdData),

    .out(ex_true_rs2Data)
);

mux_2 MUX_EX_A(
    .signal(ex_rs1Data_EX_PC),
    .a(ex_true_rs1Data),
    .b(ex_pc),

    .out(ex_inAluA)
);

mux_3 MUX_EX_B(
    .signal(ex_rs2Data_EX_imm64_4),
    .a(ex_true_rs2Data),
    .b(ex_imm64),
    .c(64'd4),

    .out(ex_inAluB)
);

add_pc ADD_PC(
    .pc(ex_pc),
    .imm64(ex_imm64),
    .rs1Data(ex_true_rs1Data),

    .pcImm(ex_pcImm),
    .rs1Imm(ex_rs1Imm)
);

alu ALU(
    .aluc(ex_aluc),
    .a(ex_inAluA),
    .b(ex_inAluB),

    .out(ex_outAlu),
    .condition_branch(ex_conditionBranch)
);

forward_unit FORWARD_UNIT(
    .me_writeReg(me_writeReg),
    .me_rd(me_rd),
    .wb_rd(wb_rd),
    .wb_writeReg(wb_writeReg),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .me_rs2(me_rs2),

    .ex_forwardA(forwardA),
    .ex_forwardB(forwardB),
    .me_forwardC(forwardC)
);

// ********************************
//         EX/ME
// ********************************
ex_me EX_ME(
    .clk(clk),
    .rst(reset|rst_in|new_reset),
    .flush(flush),
    .pipeline_en(pipeline_en),

    .ex_aluOut_WB_memOut(ex_aluOut_WB_memOut),
    .ex_writeReg(ex_writeReg),
    .ex_writeMem(ex_writeMem),
    .ex_readMem(ex_readMem),
    .ex_pcImm_NEXTPC_rs1Imm(ex_pcImm_NEXTPC_rs1Imm),
    .ex_conditionBranch(ex_conditionBranch),
    .ex_pcImm(ex_pcImm),
    .ex_rs1Imm(ex_rs1Imm),
    .ex_outAlu(ex_outAlu),
    .ex_rs2Data(ex_true_rs2Data), //memory write data
    .ex_rd(ex_rd),
    .ex_rs2(ex_rs2),
    .ex_pc(ex_pc),

    .me_aluOut_WB_memOut(me_aluOut_WB_memOut),
    .me_writeReg(me_writeReg),
    .me_writeMem(me_writeMem),
    .me_readMem(me_readMem),
    .me_pcImm_NEXTPC_rs1Imm(me_pcImm_NEXTPC_rs1Imm),
    .me_conditionBranch(me_conditionBranch),
    .me_pcImm(me_pcImm),
    .me_rs1Imm(me_rs1Imm),
    .me_outAlu(me_outAlu),
    .me_rs2Data(me_rs2Data),
    .me_rd(me_rd),
    .me_rs2(me_rs2),
    .me_pc(me_pc)
);

mux_2 MUX_WB_DATA(
    .signal(forwardC),
    .a(me_rs2Data),
    .b(wb_rdData),

    .out(me_true_rs2Data)
);

always @(negedge clk) begin
    if(reset|rst_in|new_reset) begin
        process_done = 1'b0;
    end
    else begin
        if(me_pc[7:2] == 8'h00) begin
            process_done = 1'b0;
        end
        else if(me_pc[7:2] == 8'h08) begin
            process_done = 1'b1;
        end
    end
end


wire match_en = match & end_pkt;

//data path in fifo mode
reg [7:0] headptr, writeptr, readptr, payload_start_ptr;
reg [8:0] depth;
reg valid_data;

wire full = (depth == 9'h100);
wire empty = (depth == 8'h00);

wire fiforead =  out_rdy && (readptr != headptr) && (readptr != writeptr) && ~empty && ~cpu_mode;
wire fifowrite = in_wr_reg && ~full;
assign out_wr = valid_data && (~cpu_mode);

always @(posedge clk) begin
    if(reset|rst_in) begin
        headptr <= 0;
        writeptr <= 0;
        readptr <= 0;
        depth <= 9'b0;
        valid_data <= 0;
    end else if(~cpu_mode) begin
        if(begin_pkt|end_pkt) begin
            //move write pointer to head pointer
            headptr <= writeptr;
        end
        if(fifowrite) begin
            writeptr <= writeptr + 1;
        end
        if(fiforead) begin
            readptr <= readptr + 1;
        end
        //if writing only, increasing depth
        if(fifowrite && ~fiforead) begin
            depth <= depth + 1;
        end
        if(fiforead && ~fifowrite) begin
            depth <= depth - 1;
        end
        valid_data <= fiforead;
    end
end

assign in_rdy = (depth<=9'h0fe) && ~stop_in_rdy;

assign dmem_write  = pipeline_en ? me_writeMem : (req_in & ~rw_in) ? (~rw_in) : me_writeMem;
assign dmem_read  = pipeline_en ? me_readMem :  (req_in & rw_in) ? rw_in : me_readMem;
assign dmem_addr = pipeline_en ? me_outAlu[10:3] : daddr;
assign dmem_data = pipeline_en ? me_true_rs2Data : din; 

//memory input/output mux
wire [7:0] fifo_sram_addra = cpu_mode ? dmem_addr : writeptr;
wire [7:0] fifo_sram_addrb = cpu_mode ? dmem_addr : readptr;
wire [71:0] fifo_sram_dina = cpu_mode ? {8'b0, dmem_data} : {in_ctrl_reg, in_data_reg};
wire fifo_sram_wea = cpu_mode ? dmem_write : fifowrite;
wire [71:0] fifo_sram_doutb;
assign {out_ctrl, out_data} = {fifo_sram_doutb};
assign me_outMem = fifo_sram_doutb[63:0];
assign dmem_out = me_outMem;

//fifo-sram
RAM9B fifo_sram(
    .addra(fifo_sram_addra),
    .dina(fifo_sram_dina),
    .wea(fifo_sram_wea),
    .clka(clk),
    .clkb(clk),
    .addrb(fifo_sram_addrb),
    .doutb(fifo_sram_doutb)
);

// dmem_64 DATA_MEM(
//     .addra(dmem_addr),
//     .addrb(dmem_addr),
//     .clka(clk),
//     .clkb(clk),
//     .dinb(dmem_data),
//     .douta(me_outMem),
//     .web(dmem_wea)
// );

// assign dmem_out = me_outMem;




// ********************************
//         ME/WB
// ********************************
me_wb ME_WB(
    .clk(clk),
    .rst(reset|rst_in|new_reset),
    .pipeline_en(pipeline_en),
    .me_aluOut_WB_memOut(me_aluOut_WB_memOut),
    .me_writeReg(me_writeReg),
    .me_outAlu(me_outAlu),
    .me_rd(me_rd),

    .wb_aluOut_WB_memOut(wb_aluOut_WB_memOut),
    .wb_writeReg(wb_writeReg),
    .wb_outAlu(wb_outAlu),
    .wb_rd(wb_rd)
);

//reduce 1 cycle read delay of D-Mem
assign wb_outMem = me_outMem;

mux_2 MUX_WB(
    .signal(wb_aluOut_WB_memOut),
    .a(wb_outAlu),
    .b(wb_outMem),

    .out(wb_rdData)
);
//-------------------------End of CPU

//Controller
//NSL and OFL
always @(*) begin
    state_next = state;
    begin_pkt_next = 1'b0;
    end_pkt_next = 1'b0;
    stop_in_rdy = 1'b0;
    cpu_mode_next = 1'b0;

    if(in_wr && (depth <= 9'h0fe) && (state != CPU)) begin
      case (state)
         START: begin
            if(in_ctrl!= 0) begin
              state_next = HEADER;
              begin_pkt_next = 1'b1;
              end_pkt_next   = 1'b0;
              end
            end
         HEADER: begin
            begin_pkt_next = 1'b0;
            if(in_ctrl == 0) begin
              state_next = PAYLOAD;
              payload_start_ptr = writeptr;
            end 
          end
         PAYLOAD: begin
             if(in_ctrl != 0) begin
              end_pkt_next = 1'b1;
              if(match_en)
              state_next = CPU;
              stop_in_rdy = 1'b1;
              new_reset = 1'b1; //reset the cpu before starting
             end else begin
              state_next = PAYLOAD;
            end
         end
     endcase
    end else if(state == CPU) begin
        stop_in_rdy = 1'b1;
        cpu_mode_next = 1'b1;
        new_reset = 1'b0; //release the reset
        if(process_done) begin
            state_next = START;
            stop_in_rdy = 1'b0;
            cpu_mode_next = 1'b0;
        end
    end
end

//SM
always @(posedge clk) begin
    if(reset|rst_in) begin
        state <= START;
        begin_pkt <= 1'b0;
        end_pkt <= 1'b0;
        in_wr_reg <= 1'b0;
        in_ctrl_reg <= 8'b0;
        in_data_reg <= 64'b0;
        cpu_mode <= 1'b0;
        process_done <= 1'b0;
    end
    else begin
        state <= state_next;
        begin_pkt <= begin_pkt_next;
        end_pkt <= end_pkt_next;
        in_wr_reg <= in_wr;
        in_ctrl_reg <= in_ctrl;
        in_data_reg <= in_data;
        cpu_mode <= cpu_mode_next;
    end
end

endmodule   