module imem(
    input   [31:0]  pc,
    output  [31:0]  instruction
);

reg [31:0]  instr_mem   [63:0];

assign  instruction = instr_mem[pc >> 2]

initial begin
    instr_mem[0] = 32'hfe010113;
    instr_mem[1] = 32'h00812e23;
    instr_mem[2] = 32'h02010413;
    instr_mem[3] = 32'hfea42623;
    instr_mem[4] = 32'hfec42783;
    instr_mem[5] = 32'h0007a703;
    instr_mem[6] = 32'h00200793;
    instr_mem[7] = 32'h00f71e63;
    instr_mem[8] = 32'hfec42783;
    instr_mem[9] = 32'h0007a783;
    instr_mem[10] = 32'h00178713;
    instr_mem[11] = 32'hfec42783;
    instr_mem[12] = 32'h00e7a023;
    instr_mem[13] = 32'h01c0006f;
    instr_mem[14] = 32'hfec42783;
    instr_mem[15] = 32'h0007a783;
    instr_mem[16] = 32'h00a78713;
    instr_mem[17] = 32'hfec42783;
    instr_mem[18] = 32'h00e7a023;
    instr_mem[19] = 32'h00000013;
    instr_mem[20] = 32'h01c12403;
    instr_mem[21] = 32'h02010113;
    instr_mem[22] = 32'h00008067;

    instr_mem[23] = 32'hfe010113;
    instr_mem[24] = 32'h00112e23;
    instr_mem[25] = 32'h00812c23;
    instr_mem[26] = 32'h02010413;
    instr_mem[27] = 32'h00100793;
    instr_mem[28] = 32'hfef42623;
    instr_mem[29] = 32'hfec40793;
    instr_mem[30] = 32'h00078513;
    instr_mem[31] = 32'hf85ff0ef;
    instr_mem[32] = 32'h00000793;
    instr_mem[33] = 32'h00078513;
    instr_mem[34] = 32'h01c12083;
    instr_mem[35] = 32'h01812403;
    instr_mem[36] = 32'h02010113;
end

endmodule