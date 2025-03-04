`timescale 1ns / 1ps

module cpu(
    input clk, rst
);

wire pause; // stall
wire flush; // flush
wire [1: 0] forwardA, forwardB; // forwording
wire forwardC; // hazard forwarding

// IF stage
wire [31: 0] if_pc; // instrction
wire [31: 0] if_pc4; // pc + 4
wire [31: 0] if_nextPc; // next instruction
wire [31: 0] if_instr; 

// ID stage
wire [31: 0] id_pc;
wire [31: 0] id_instr;
wire [31: 0] id_imm32; // 32bit immediate number
wire [31: 0] id_rs1Data, id_rs2Data;
wire [4:  0] id_rd, id_rs1, id_rs2;

wire [6: 0] id_opcode; // opcode
wire [2: 0] id_func3; 
wire [6: 0] id_func7;

wire [4:  0] id_aluc; // aluctrl
wire id_aluOut_WB_memOut; //mux2
wire id_rs1Data_EX_PC; //mux2
wire[1: 0] id_rs2Data_EX_imm32_4; //mux3
wire id_writeReg;
wire [1: 0] id_writeMem; 
wire [2: 0] id_readMem;
wire [2: 0] id_extOP;
wire [1: 0] id_pcImm_NEXTPC_rs1Imm;

// EX stage
wire [4:  0] ex_aluc; 
wire ex_aluOut_WB_memOut; 
wire ex_rs1Data_EX_PC;
wire[1: 0] ex_rs2Data_EX_imm32_4;
wire ex_writeReg;
wire [1: 0] ex_writeMem;
wire [2: 0] ex_readMem;
wire[1: 0] ex_pcImm_NEXTPC_rs1Imm;
wire [31: 0] ex_pc; 
wire [31: 0] ex_rs1Data, ex_rs2Data;
wire [31: 0] ex_true_rs1Data, ex_true_rs2Data;
wire [31: 0] ex_imm32;
wire [4: 0] ex_rd, ex_rs1, ex_rs2;
wire [31: 0] ex_inAluA, ex_inAluB;
wire [31: 0] ex_pcImm, ex_rs1Imm;
wire [31: 0] ex_outAlu;
wire ex_conditionBranch;

// ME stage
wire me_aluOut_WB_memOut; 
wire me_writeReg; 
wire [1: 0] me_writeMem;
wire [2: 0] me_readMem;
wire[1: 0] me_pcImm_NEXTPC_rs1Imm;
wire me_conditionBranch;
wire [31: 0] me_pcImm, me_rs1Imm;
wire [31: 0] me_outAlu;
wire [31: 0] me_rs2Data;
wire [4: 0] me_rd;
wire [4: 0] me_rs2;
wire [31: 0] me_true_rs2Data;
wire [31: 0] me_outMem;

// WB stage
wire wb_aluOut_WB_memOut; 
wire wb_writeReg;
wire [31: 0] wb_outMem;
wire [31: 0] wb_outAlu;
wire [31: 0] wb_rdData;
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
    .rst(rst),
    .clk(clk),
    .pause(pause),
    .flush(flush),
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
    .rst(rst),
    .pause(pause),
    .flush(flush),

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
    .rs2Data_EX_imm32_4(id_rs2Data_EX_imm32_4),
    .write_reg(id_writeReg),
    .write_mem(id_writeMem),
    .read_mem(id_readMem),
    .extOP(id_extOP),
    .pcImm_NEXTPC_rs1Imm(id_pcImm_NEXTPC_rs1Imm)
);

reg_file REG_FILE(
    .rst(rst),
    .clk(clk),
    .write_reg(wb_writeReg),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .target_reg(wb_rd),
    .write_rd_data(wb_rdData),

    .read_rs1_data(id_rs1Data),
    .read_rs2_data(id_rs2Data)
);

imm IMM(
    .instr(id_instr),
    .extOP(id_extOP),

    .imm_32(id_imm32)
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
    .rst(rst),
    .pause(pause),
    .flush(flush),

    .id_aluc(id_aluc),
    .id_aluOut_WB_memOut(id_aluOut_WB_memOut),
    .id_rs1Data_EX_PC(id_rs1Data_EX_PC),
    .id_rs2Data_EX_imm32_4(id_rs2Data_EX_imm32_4),
    .id_writeReg(id_writeReg),
    .id_writeMem(id_writeMem),
    .id_readMem(id_readMem),
    .id_pcImm_NEXTPC_rs1Imm(id_pcImm_NEXTPC_rs1Imm),
    .id_pc(id_pc),
    .id_rs1Data(id_rs1Data),
    .id_rs2Data(id_rs2Data),
    .id_imm32(id_imm32),
    .id_rd(id_rd),
    .id_rs1(id_rs1),
    .id_rs2(id_rs2),

    .ex_aluc(ex_aluc),
    .ex_aluOut_WB_memOut(ex_aluOut_WB_memOut),
    .ex_rs1Data_EX_PC(ex_rs1Data_EX_PC),
    .ex_rs2Data_EX_imm32_4(ex_rs2Data_EX_imm32_4),
    .ex_writeReg(ex_writeReg),
    .ex_writeMem(ex_writeMem),
    .ex_readMem(ex_readMem),
    .ex_pcImm_NEXTPC_rs1Imm(ex_pcImm_NEXTPC_rs1Imm),
    .ex_pc(ex_pc),
    .ex_rs1Data(ex_rs1Data),
    .ex_rs2Data(ex_rs2Data),
    .ex_imm32(ex_imm32),
    .ex_rd(ex_rd),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2)
);

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
    .signal(ex_rs2Data_EX_imm32_4),
    .a(ex_true_rs2Data),
    .b(ex_imm32),
    .c(32'd4),

    .out(ex_inAluB)
);

add_pc ADD_PC(
    .pc(ex_pc),
    .imm32(ex_imm32),
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
    .rst(rst),
    .flush(flush),

    .ex_aluOut_WB_memOut(ex_aluOut_WB_memOut),
    .ex_writeReg(ex_writeReg),
    .ex_writeMem(ex_writeMem),
    .ex_readMem(ex_readMem),
    .ex_pcImm_NEXTPC_rs1Imm(ex_pcImm_NEXTPC_rs1Imm),
    .ex_conditionBranch(ex_conditionBranch),
    .ex_pcImm(ex_pcImm),
    .ex_rs1Imm(ex_rs1Imm),
    .ex_outAlu(ex_outAlu),
    .ex_rs2Data(ex_true_rs2Data),
    .ex_rd(ex_rd),
    .ex_rs2(ex_rs2),

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
    .me_rs2(me_rs2)
);

mux_2 MUX_WB_DATA(
    .signal(forwardC),
    .a(me_rs2Data),
    .b(wb_rdData),

    .out(me_true_rs2Data)
);

data_mem DATA_MEM(
    .clk(clk),
    .rst(rst),
    .address(me_outAlu),
    .write_data(me_true_rs2Data),
    .write_mem(me_writeMem),
    .read_mem(me_readMem),

    .out_mem(me_outMem)
);

// ********************************
//         ME/WB
// ********************************
me_wb ME_WB(
    .clk(clk),
    .rst(rst),
    .me_aluOut_WB_memOut(me_aluOut_WB_memOut),
    .me_writeReg(me_writeReg),
    .me_outMem(me_outMem),
    .me_outAlu(me_outAlu),
    .me_rd(me_rd),

    .wb_aluOut_WB_memOut(wb_aluOut_WB_memOut),
    .wb_writeReg(wb_writeReg),
    .wb_outMem(wb_outMem),
    .wb_outAlu(wb_outAlu),
    .wb_rd(wb_rd)
);

mux_2 MUX_WB(
    .signal(wb_aluOut_WB_memOut),
    .a(wb_outAlu),
    .b(wb_outMem),

    .out(wb_rdData)
);
endmodule