module id_ex(
    input clk, rst, pause, flush,
    input pipeline_en,

    input [4: 0] id_aluc,
    input id_aluOut_WB_memOut,
    input id_rs1Data_EX_PC,
    input [1: 0] id_rs2Data_EX_imm64_4,
    input id_writeReg,
    input id_writeMem,
    input id_readMem,
    input [1: 0] id_pcImm_NEXTPC_rs1Imm,
//    input [31: 0] id_pc,
//    input [31: 0] id_rs1Data, id_rs2Data,
//    input [31: 0] id_imm32,
    input [63: 0] id_pc,
    input [63: 0] id_rs1Data, id_rs2Data,
    input [63: 0] id_imm64,
    input [4: 0] id_rd,
    input [4: 0] id_rs1,
    input [4: 0] id_rs2,

    output reg [4: 0] ex_aluc,
    output reg ex_aluOut_WB_memOut,
    output reg ex_rs1Data_EX_PC,
    output reg [1: 0] ex_rs2Data_EX_imm64_4,
    output reg ex_writeReg,
    output reg ex_writeMem,
    output reg ex_readMem,
    output reg [1: 0] ex_pcImm_NEXTPC_rs1Imm,
//    output reg [31: 0] ex_pc,
//    output reg [31: 0] ex_rs1Data, ex_rs2Data,
//    output reg [31: 0] ex_imm32,
    output reg [63: 0] ex_pc,
    output reg [63: 0] ex_rs1Data, ex_rs2Data,
    output reg [63: 0] ex_imm64,
    output reg [4: 0] ex_rd,
    output reg [4: 0] ex_rs1,
    output reg [4: 0] ex_rs2
);

always @(posedge clk) begin
    if(rst || pause || flush)begin
        ex_aluc <= 5'b00000;
        ex_aluOut_WB_memOut <= 1'b0;
        ex_rs1Data_EX_PC <= 1'b0;
        ex_rs2Data_EX_imm64_4 <= 2'b01;
        ex_writeReg <= 1'b1;
        ex_writeMem <= 1'b0;
        ex_readMem <= 1'b0;
        ex_pcImm_NEXTPC_rs1Imm <= 2'b00;
        ex_pc <= 64'h0;
        ex_rs1Data <= 64'd0;
        ex_rs2Data <= 64'd0;
        ex_imm64 <= 64'd0;
        ex_rd <= 5'd0;
        ex_rs1 <= 5'd0;
        ex_rs2 <= 5'd0;
    end else if(pipeline_en) begin
        ex_aluc <= id_aluc;
        ex_aluOut_WB_memOut <= id_aluOut_WB_memOut;
        ex_rs1Data_EX_PC <= id_rs1Data_EX_PC;
        ex_rs2Data_EX_imm64_4 <= id_rs2Data_EX_imm64_4;
        ex_writeReg <= id_writeReg;
        ex_writeMem <= id_writeMem;
        ex_readMem <= id_readMem;
        ex_pcImm_NEXTPC_rs1Imm <= id_pcImm_NEXTPC_rs1Imm;
        ex_pc <= id_pc;
        ex_rs1Data <= id_rs1Data;
        ex_rs2Data <= id_rs2Data;
        ex_imm64 <= id_imm64;
        ex_rd <= id_rd;
        ex_rs1 <= id_rs1;
        ex_rs2 <= id_rs2;
    end
    
end
endmodule