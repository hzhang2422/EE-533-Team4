module instruction_mem (
//    input [31: 0] pc,
    input [63: 0] pc,

    output reg [31: 0] instruction
);

reg [31: 0] inst_mem[127: 0];

always @(pc) begin
    instruction = inst_mem[pc >> 2];
end

initial begin
    
    inst_mem[0] = 32'hfd010113;        // addi	sp,sp,-48
    inst_mem[1] = 32'h02812623;        // sw	s0,44(sp)
    inst_mem[2] = 32'h03010413;        // addi	s0,sp,48
    inst_mem[3] = 32'h12400793;        // li	a5,292
    inst_mem[4] = 32'h0007a583;        // lw	a1,0(a5)
    inst_mem[5] = 32'h0047a603;        // lw	a2,4(a5)
    inst_mem[6] = 32'h0087a683;        // lw	a3,8(a5)
    inst_mem[7] = 32'h00c7a703;        // lw	a4,12(a5)
    inst_mem[8] = 32'h0107a783;        // lw	a5,16(a5)
    inst_mem[9] = 32'hfcb42823;        // sw	a1,-48(s0)
    inst_mem[10] = 32'hfcc42a23;        // sw	a2,-44(s0)
    inst_mem[11] = 32'hfcd42c23;        // sw	a3,-40(s0)
    inst_mem[12] = 32'hfce42e23;        // sw	a4,-36(s0)
    inst_mem[13] = 32'hfef42023;        // sw	a5,-32(s0)
    inst_mem[14] = 32'hfe042623;        // sw	zero,-20(s0)
    inst_mem[15] = 32'h0c80006f;        // j	104 <main+0x104>
    inst_mem[16] = 32'hfe042423;        // sw	zero,-24(s0)
    inst_mem[17] = 32'h0a00006f;        // j	e4 <main+0xe4>
    inst_mem[18] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[19] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[20] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[21] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[22] = 32'hfe07a703;        // lw	a4,-32(a5)
    inst_mem[23] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[24] = 32'h00178793;        // addi	a5,a5,1
    inst_mem[25] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[26] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[27] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[28] = 32'hfe07a783;        // lw	a5,-32(a5)
    inst_mem[29] = 32'h06e7d263;        // bge	a5,a4,d8 <main+0xd8>
    inst_mem[30] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[31] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[32] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[33] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[34] = 32'hfe07a783;        // lw	a5,-32(a5)
    inst_mem[35] = 32'hfef42223;        // sw	a5,-28(s0)
    inst_mem[36] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[37] = 32'h00178793;        // addi	a5,a5,1
    inst_mem[38] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[39] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[40] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[41] = 32'hfe07a703;        // lw	a4,-32(a5)
    inst_mem[42] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[43] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[44] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[45] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[46] = 32'hfee7a023;        // sw	a4,-32(a5)
    inst_mem[47] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[48] = 32'h00178793;        // addi	a5,a5,1
    inst_mem[49] = 32'h00279793;        // slli	a5,a5,0x2
    inst_mem[50] = 32'hff078793;        // addi	a5,a5,-16
    inst_mem[51] = 32'h008787b3;        // add	a5,a5,s0
    inst_mem[52] = 32'hfe442703;        // lw	a4,-28(s0)
    inst_mem[53] = 32'hfee7a023;        // sw	a4,-32(a5)
    inst_mem[54] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[55] = 32'h00178793;        // addi	a5,a5,1
    inst_mem[56] = 32'hfef42423;        // sw	a5,-24(s0)
    inst_mem[57] = 32'h00400713;        // li	a4,4
    inst_mem[58] = 32'hfec42783;        // lw	a5,-20(s0)
    inst_mem[59] = 32'h40f707b3;        // sub	a5,a4,a5
    inst_mem[60] = 32'hfe842703;        // lw	a4,-24(s0)
    inst_mem[61] = 32'hf4f74ae3;        // blt	a4,a5,48 <main+0x48>
    inst_mem[62] = 32'hfec42783;        // lw	a5,-20(s0)
    inst_mem[63] = 32'h00178793;        // addi	a5,a5,1
    inst_mem[64] = 32'hfef42623;        // sw	a5,-20(s0)
    inst_mem[65] = 32'hfec42703;        // lw	a4,-20(s0)
    inst_mem[66] = 32'h00300793;        // li	a5,3
    inst_mem[67] = 32'hf2e7dae3;        // bge	a5,a4,40 <main+0x40>
    inst_mem[68] = 32'h00000793;        // li	a5,0
    inst_mem[69] = 32'h00078513;        // mv	a0,a5
    inst_mem[70] = 32'h02c12403;        // lw	s0,44(sp)
    inst_mem[71] = 32'h03010113;        // addi	sp,sp,48
	inst_mem[72] = {12'h0, 5'b0, 3'b000, 5'b0, 7'b0010011}; // nop */

    //  inst_mem[0] = {12'h1, 5'b0, 3'b000, 5'b1, 7'b0010011}; // addi
    //  inst_mem[1] = {12'h1, 5'b1, 3'b000, 5'h2, 7'b0010011}; // addi
    //  inst_mem[2] = {7'b0, 5'b1, 5'h2, 3'b000, 5'h3, 7'b0110011}; // add
    // inst_mem[3] = {7'b010_0000, 5'h2, 5'h3, 3'b000, 5'h4, 7'b0110011}; // sub
    // inst_mem[4] = {7'b0, 5'h2, 5'h4, 3'b110, 5'h1, 7'b0110011}; // or
    
    // inst_mem[5] = {12'h0, 5'b0, 3'b000, 5'b0, 7'b0010011}; // nop


    // inst_mem[0] = {12'h1, 5'b0, 3'b000, 5'b1, 7'b0010011}; // addi
    // inst_mem[1] = {12'h001, 5'b1, 3'b000, 5'h2, 7'b0010011}; // addi

    // // R
    // inst_mem[2] = {7'b0, 5'b1, 5'h2, 3'b000, 5'h3, 7'b0110011}; // add
    // inst_mem[3] = {7'b010_0000, 5'h2, 5'h3, 3'b000, 5'h4, 7'b0110011}; // sub
    // inst_mem[4] = {7'b0, 5'h2, 5'h4, 3'b110, 5'h1, 7'b0110011}; // or
    // inst_mem[5] = {7'b0, 5'b0, 5'h1, 3'b111, 5'h1, 7'b0110011}; // and
    // inst_mem[6] = {7'b0, 5'd2, 5'd3, 3'b100, 5'd1, 7'b0110011}; // xor
    // inst_mem[7] = {7'b0, 5'd1, 5'd3, 3'b001, 5'd3, 7'b0110011}; // sll
    // inst_mem[8] = {7'b010_0000, 5'd3, 5'd1, 3'b000, 5'h1, 7'b0110011}; //sub
    // inst_mem[9] = {7'b0, 5'd3, 5'd1, 3'b010, 5'd2, 7'b0110011}; // slt
    // inst_mem[10] = {7'b0, 5'd3, 5'd1, 3'b011, 5'd2, 7'b0110011}; // sltu
    // inst_mem[11] = {7'b0, 5'd2, 5'd1, 3'b101, 5'd1, 7'b0110011}; // srl
    // inst_mem[12] = {7'b010_0000, 5'd4, 5'd1, 3'b101, 5'd1, 7'b0110011}; // sra

    // inst_mem[13] = {12'hfff, 5'd1, 3'b010, 5'd2, 7'b0010011}; // slti
    // inst_mem[14] = {12'hfff, 5'd2, 3'b011, 5'd2, 7'b0010011}; // sltiu
    // inst_mem[15] = {12'h009, 5'd3, 3'b100, 5'd3, 7'b0010011}; // xori
    // inst_mem[16] = {12'hffd, 5'd3, 3'b110, 5'd2, 7'b0010011}; // ori
    // inst_mem[17] = {12'h1, 5'd2, 3'b111, 5'd2, 7'b0010011}; // andi
    // inst_mem[18] = {12'h2, 5'd2, 3'b001, 5'd2, 7'b0010011}; //slli
    // inst_mem[19] = {12'b1000000_00000, 5'd1, 3'b101, 5'd1, 7'b0010011}; // srli
    // inst_mem[20] = {12'b1100000_00001, 5'd1, 3'b101, 5'd1, 7'b0010011}; // srai

    // // S
    // inst_mem[21] = {7'h0, 5'd3, 5'd0, 3'b010, 5'd2, 7'b0100011}; // sw

    // // L
    // inst_mem[22] = {12'd1, 5'd4, 3'b010, 5'd2, 7'b0000011}; // lw

    // inst_mem[23] = {7'h0, 5'd1, 5'd4, 3'b001, 5'd5, 7'b0100011}; //sh

    // inst_mem[24] = {12'd5, 5'd0, 3'b001, 5'd3, 7'b0000011}; // lh;

    // inst_mem[25] = {7'h0, 5'd4, 5'd4, 3'b000, 5'd5, 7'b0100011}; // sb

    // inst_mem[26] = {12'd6, 5'd0, 3'b000, 5'd3, 7'b0000011}; // lb

    // inst_mem[27] = {12'd7, 5'd0, 3'b100, 5'd4, 7'b0000011}; // lbu

    // inst_mem[28] = {12'd6, 5'd0, 3'b101, 5'd4, 7'b0000011}; // lhu

    // inst_mem[29] = {1'b0, 10'd4, 1'b0, 8'b0, 5'd4, 7'b1101111}; // jal

    // inst_mem[31] = {20'b1, 5'd4, 7'b0110111}; // lui

    // inst_mem[32] = {20'b1, 5'd4, 7'b0010111}; // auipc

    // inst_mem[33] = {12'd4, 5'd0, 3'b000, 5'd4, 7'b1100111}; // jalr
end

endmodule