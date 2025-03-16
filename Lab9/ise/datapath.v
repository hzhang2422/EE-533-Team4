`timescale 1ns/1ps

module module(
    input clk, rst
);

wire                stall;
wire                flush;
wire    [1:0]       forwardA, forwarB;
wire                forwardC;

//IF stage
wire    [31:0]      if_pc; // addr of instr
wire    [31:0]      if_pc4; // pc+4
wire    [31:0]      if_nextPc; // addr of next instr
wire    [31:0]      if_instr; // instr


//ID stage
wire    [31:0]      id_pc;
wire    [31:0]      id_instr;
wire    [31:0]      id_imm32;
wire    [31:0]      id_rs1Data, id_rs2Data;
wire    [4:0]       id_rd, id_rs1, id_rs2;

wire    [6:0]       id_opcode;
wire    [2:0]       id_func3;
wire    [6:0]       id_func7;

wire    [4:0]       id_aluc;
wire                id_aluOut_WB_memOut;
wire                id_rs1Data_EX_PC;
wire                id_aluOut_WB_memOut;
wire    [1:0]       id_rs2Data_EX_imm32_4;
wire                id_writeReg;
wire    [1:0]       id_writeMem;
wire    [2:0]       id_readMem;
wire    [2:0]       id_extOP; //imm-gen signal
wire    [1:0]       id_pcImm_NEXTPC_rs1Imm;//Jump

//EX stage
wire    [4:0]       ex_aluc;
wire                ex_aluOut_WB_memOut;
wire                ex_rs1Data_EX_PC;
wire    [1:0]       ex_rs2Data_EX_imm32_4;
wire                ex_writeReg;
wire    [1:0]       ex_writeMem;
wire    [2:0]       ex_readMem;
wire    [1:0]       ex_pcImm_NEXTPC_rsImm;
wire    [31:0]      ex_pc;
wire    [31:0]      ex_rs1Data, ex_rs2Data;
wire    [31:0]      ex_true_rs1Data, ex_true_rs2Data;
wire    [31:0]      ex_imm32;
wire    [4:0]       ex_rd, ex_rs1, ex_rs2;
wire    [31:0]      ex_inAluA, ex_inAluB; //input of ALU
wire    [31:0]      expcImm, exrs1Imm;
wire    [31:0]      ex_outAlu;
wire                ex_conditionBranch;

wire                me_aluOut_WB_memOut;
wire                me_writeReg;
wire    [1:0]       me_writeMem;
wire    [2:0]       me_readMem;
wire    [1:0]       me_pcImm_NEXTPC_rs1Imm;
wire                me_conditionBranch;
wire    [31:0]      me_pcImm, me_rs1Imm;
wire    [31:0]      me_outAlu;
wire    [31:0]      me_rs2Data;
wire    [4:0]       me_rd;
wire    [4:0]       me_rs2;
wire    [31:0]       me_true_rs2Data;
wire    [31:0]      me_outMem;

wire                wb_aluOut_WB_memOut;
wire                wb_writeReg;
wire    [31:0]      wb_outMem;
wire    [31:0]      wb_outAlu;
wire    [31:0]      wb_rdData;
wire    [4:0]       wb_rd;

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
    .stall(stall),
    .flush(flush),
    .next_pc(if_nextPc),

    .pc(if_pc)
);

imem IMEM (
    .pc(if_pc),
    .instruction(if_instr)
);

if_id IF_ID (
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .flush(flush),

    .if_pc(if_pc),
    .if_instr(if_instr),

    .id_pc(id_pc),
    .id_instr(id_instr)
);

id ID(
    .instr(id_instr),

    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),
    .rd(id_rd),
    .rs1(id_rs1),
    .rs2(id_rs2)
);

