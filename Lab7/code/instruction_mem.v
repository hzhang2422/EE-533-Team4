module instruction_mem (
    input [31: 0] pc,

    output reg [31: 0] instruction
);

reg [31: 0] inst_mem[127: 0];

always @(*) begin
    instruction = inst_mem[pc >> 2];
end

initial begin
    inst_mem[0] = 32'hfb010113;        // addi	sp,sp,-80     
    inst_mem[1] = 32'h04812623;        // sw	s0,76(sp)       
    inst_mem[2] = 32'h05010413;        // addi	s0,sp,80      
    inst_mem[3] = 32'h00000793;        // li	a5,0         
    inst_mem[4] = 32'h0007a303;        // lw	t1,0(a5)      
    inst_mem[5] = 32'h0047a883;        // lw	a7,4(a5)    
    inst_mem[6] = 32'h0087a803;        // lw	a6,8(a5)      
    inst_mem[7] = 32'h00c7a503;        // lw	a0,12(a5)       
    inst_mem[8] = 32'h0107a583;        // lw	a1,16(a5)    
    inst_mem[9] = 32'h0147a603;        // lw	a2,20(a5)
    inst_mem[10] = 32'h0187a683;        // lw	a3,24(a5) 
    inst_mem[11] = 32'h01c7a703;        // lw	a4,28(a5)    
    inst_mem[12] = 32'h0207a783;        // lw	a5,32(a5)     
    inst_mem[13] = 32'h0247ae03;        // lw	t3,36(a5)       
    inst_mem[14] = 32'hfa642023;        // sw	t1,-96(s0)      
    inst_mem[15] = 32'hfb142223;        // sw	a7,-92(s0)      
    inst_mem[16] = 32'hfb042423;        // sw	a6,-88(s0)     
    inst_mem[17] = 32'hfaa42623;        // sw	a0,-84(s0)      
    inst_mem[18] = 32'hfab42823;        // sw	a1,-80(s0)      
    inst_mem[19] = 32'hfac42a23;        // sw	a2,-76(s0)  
    inst_mem[20] = 32'hfad42c23;        // sw	a3,-72(s0) 
    inst_mem[21] = 32'hfae42e23;        // sw	a4,-68(s0)  
    inst_mem[22] = 32'hfcf42023;        // sw	a5,-64(s0)  
    inst_mem[23] = 32'hfdc42223;        // sw	t3,-60(s0) 
    inst_mem[24] = 32'hfe042623;        // sw	zero,-20(s0) 
    inst_mem[25] = 32'h0bc0006f;        // j	120 <main+0x120>
    inst_mem[26] = 32'hfec42783;        // lw	a5,-20(s0)
    inst_mem[27] = 32'h00178793;        // addi	a5,a5,1 
    inst_mem[28] = 32'hfef42423;        // sw	a5,-24(s0)
    inst_mem[29] = 32'h0940006f;        // j	108 <main+0x108>
    inst_mem[30] = 32'hfe842783;        // lw	a5,-24(s0) 
    inst_mem[31] = 32'h00279793;        // slli	a5,a5,0x2 
    inst_mem[32] = 32'hfa040713;        // addi	a4,s0,-96 
    inst_mem[33] = 32'h00f707b3;        // add	a5,a4,a5 
    inst_mem[34] = 32'h0007a703;        // lw	a4,0(a5)
    inst_mem[35] = 32'hfec42783;        // lw	a5,-20(s0) 
    inst_mem[36] = 32'h00279793;        // slli	a5,a5,0x2 
    inst_mem[37] = 32'hfa040693;        // addi	a3,s0,-96   
    inst_mem[38] = 32'h00f687b3;        // add	a5,a3,a5   
    inst_mem[39] = 32'h0007a783;        // lw	a5,0(a5)  
    inst_mem[40] = 32'h04f75e63;        // bge	a4,a5,fc <main+0xfc> 
    inst_mem[41] = 32'hfe842783;        // lw	a5,-24(s0)
    inst_mem[42] = 32'h00279793;        // slli	a5,a5,0x2 
    inst_mem[43] = 32'hfa040713;        // addi	a4,s0,-96   
    inst_mem[44] = 32'h00f707b3;        // add	a5,a4,a5  
    inst_mem[45] = 32'h0007a783;        // lw	a5,0(a5)   
    inst_mem[46] = 32'hfef42223;        // sw	a5,-28(s0)   
    inst_mem[47] = 32'hfec42783;        // lw	a5,-20(s0)     
    inst_mem[48] = 32'h00279793;        // slli	a5,a5,0x2 
    inst_mem[49] = 32'hfa040713;        // addi	a4,s0,-96  
    inst_mem[50] = 32'h00f707b3;        // add	a5,a4,a5    
    inst_mem[51] = 32'h0007a703;        // lw	a4,0(a5)      
    inst_mem[52] = 32'hfe842783;        // lw	a5,-24(s0)    
    inst_mem[53] = 32'h00279793;        // slli	a5,a5,0x2  
    inst_mem[54] = 32'hfa040693;        // addi	a3,s0,-96  
    inst_mem[55] = 32'h00f687b3;        // add	a5,a3,a5    
    inst_mem[56] = 32'h00e7a023;        // sw	a4,0(a5)  
    inst_mem[57] = 32'hfec42783;        // lw	a5,-20(s0) 
    inst_mem[58] = 32'h00279793;        // slli	a5,a5,0x2 
    inst_mem[59] = 32'hfa040713;        // addi	a4,s0,-96    
    inst_mem[60] = 32'h00f707b3;        // add	a5,a4,a5       
    inst_mem[61] = 32'hfe442703;        // lw	a4,-28(s0)      
    inst_mem[62] = 32'h00e7a023;        // sw	a4,0(a5)      
    inst_mem[63] = 32'hfe842783;        // lw	a5,-24(s0)      
    inst_mem[64] = 32'h00178793;        // addi	a5,a5,1     
    inst_mem[65] = 32'hfef42423;        // sw	a5,-24(s0)     
    inst_mem[66] = 32'hfe842703;        // lw	a4,-24(s0)    
    inst_mem[67] = 32'h00900793;        // li	a5,9     
    inst_mem[68] = 32'hf6e7d4e3;        // bge	a5,a4,78 <main+0x78>
    inst_mem[69] = 32'hfec42783;        // lw	a5,-20(s0)  
    inst_mem[70] = 32'h00178793;        // addi	a5,a5,1  
    inst_mem[71] = 32'hfef42623;        // sw	a5,-20(s0)  
    inst_mem[72] = 32'hfec42703;        // lw	a4,-20(s0) 
    inst_mem[73] = 32'h00800793;        // li	a5,8    
    inst_mem[74] = 32'hf4e7d0e3;        // bge	a5,a4,68 <main+0x68>
    inst_mem[75] = 32'h00000793;        // li	a5,0
    inst_mem[76] = 32'hfa042303;        // lw	t1,-96(s0)    
    inst_mem[77] = 32'h0067a023;        // sw	t1,0(a5)      
    inst_mem[78] = 32'hfa442883;        // lw	a7,-92(s0)    
    inst_mem[79] = 32'h0117a223;        // sw	a7,4(a5)     
    inst_mem[80] = 32'hfa842803;        // lw	a6,-88(s0) 
    inst_mem[81] = 32'h0107a423;        // sw	a6,8(a5)
    inst_mem[82] = 32'hfac42503;        // lw	a0,-84(s0)
    inst_mem[83] = 32'h00a7a623;        // sw	a0,12(a5)
    inst_mem[84] = 32'hfb042583;        // lw	a1,-80(s0)
    inst_mem[85] = 32'h00b7a823;        // sw	a1,16(a5)
    inst_mem[86] = 32'hfb442603;        // lw	a2,-76(s0)
    inst_mem[87] = 32'h00c7aa23;        // sw	a2,20(a5)
    inst_mem[88] = 32'hfb842683;        // lw	a3,-72(s0)
    inst_mem[89] = 32'h00d7ac23;        // sw	a3,24(a5)
    inst_mem[90] = 32'hfbc42703;        // lw	a4,-68(s0)
    inst_mem[91] = 32'h00e7ae23;        // sw	a4,28(a5)
    inst_mem[92] = 32'hfc042783;        // lw	a5,-64(s0)
    inst_mem[93] = 32'h02f7a023;        // sw	a5,32(a5)
    inst_mem[94] = 32'hfc442e03;        // lw	t3,-60(s0)     
    inst_mem[95] = 32'h03c7a223;        // sw	t3,36(a5)       
    inst_mem[96] = 32'h00000793;        // li	a5,0         
    inst_mem[97] = 32'h00078513;        // mv	a0,a5        
    inst_mem[98] = 32'h04c12403;        // lw	s0,76(sp)       
    inst_mem[99] = 32'h05010113;        // addi	sp,sp,80     
//inst_mem[100] = 32'h00008067;        // ret              

    inst_mem[100] = {12'h0, 5'b0, 3'b000, 5'b0, 7'b0010011}; // nop

    // inst_mem[0] = {12'h1, 5'b0, 3'b000, 5'b1, 7'b0010011}; // addi
    // inst_mem[1] = {12'h1, 5'b1, 3'b000, 5'h2, 7'b0010011}; // addi
    // inst_mem[2] = {7'b0, 5'b1, 5'h2, 3'b000, 5'h3, 7'b0110011}; // add
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