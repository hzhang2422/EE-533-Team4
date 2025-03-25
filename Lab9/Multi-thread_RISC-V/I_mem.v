`include "constants.vh"

module I_mem (
	input				[31:0]	pc,
	output	[`INSTR_WIDTH-1:0]	instruction
);

	reg	[`INSTR_WIDTH-1:0]	instr_mem	[0:`IMEM_DEPTH-1];
	
	initial begin
		// instruction initialization
		
		instr_mem[0] = 32'h00000513; //  ADDI x10, x0, 0  # x10 = 0 (dmem[0] 地址)
		instr_mem[1] = 32'h00100593; // ADDI x11, x0, 1 # x11 = 1 (dmem[1] 地址)
		instr_mem[2] = 32'h00200613; // ADDI x12, x0, 2 # x12 = 2 (dmem[2] 地址)
		
		instr_mem[3] <= 32'h0; // NOP
		
		instr_mem[4] <= 32'h00052683; // LW  x13, 0(x10)  # x13 = dmem[0] =3
		instr_mem[5] <= 32'h0005a703; // LW  x14, 0(x11)  # x14 = dmem[1] =1
		instr_mem[6] <= 32'h00062783; // LW  x15, 0(x12)  # x15 = dmem[2] =2
		
		instr_mem[7] <= 32'h0;
		instr_mem[8] <= 32'h0;
		
		instr_mem[9] <= 32'h00e6c563;  // BLT x13, x14, next1 (offset=+5) 
		instr_mem[10] <= 32'h00d5a023; // SW x13, 0(x11)
		instr_mem[11] <= 32'h00e52023; // SW x14, 0(x10)
		instr_mem[12] <= 32'h00068833; // ADD x16, x13, x0
		instr_mem[13] <= 32'h000706b3; // ADD x13, x14, x0  # x13 = 1
		
		instr_mem[14] <= 32'h0;
		instr_mem[15] <= 32'h0;
		
		instr_mem[16] <= 32'h00080733; // ADD x14, x16, x0  # x14 = 3
		
		instr_mem[17] <= 32'h0;
		instr_mem[18] <= 32'h0;
		instr_mem[19] <= 32'h0;
		
		instr_mem[20] <= 32'h00f74563; // next1: BLT x14, x15, next2 (offset=+5)
		instr_mem[21] <= 32'h00e62023; // SW x14, 0(x12)
		instr_mem[22] <= 32'h00f5a023; // SW x15, 0(x11)
		instr_mem[23] <= 32'h00070833; // ADD x16, x14, x0
		
		instr_mem[24] <= 32'h0;
		instr_mem[25] <= 32'h0;
		
		instr_mem[26] <= 32'h00078733; // ADD x14, x15, x0  # x14 = 2
		instr_mem[27] <= 32'h000807b3; // ADD x15, x16, x0  # x15 = 3
		
		instr_mem[28] <= 32'h0;
		instr_mem[29] <= 32'h0;
		
		instr_mem[30] <= 32'h00e6c563;  // next2: BLT x13, x14, sorted (offset=+5)

		instr_mem[31] <= 32'h00d5a023; // SW x13, 0(x11)
		instr_mem[32] <= 32'h00e52023; // SW x14, 0(x10)
		instr_mem[33] <= 32'h00068833; // ADD x16, x13, x0
		
		instr_mem[34] <= 32'h0;
		instr_mem[35] <= 32'h0;
		
		instr_mem[36] <= 32'h000706b3; // ADD x13, x14, x0
		instr_mem[37] <= 32'h00080733; // ADD x14, x16, x0

		instr_mem[38] <= 32'h0;
		instr_mem[39] <= 32'h0;
		
		instr_mem[40] <= 32'h00d52023; // sorted: SW x13, 0(x10)
		instr_mem[41] <= 32'h00e5a023; // SW x14, 0(x11)
		instr_mem[42] <= 32'h00f62023; // SW x15, 0(x12)
		instr_mem[43] <= 32'hffbff06f;  // J sorted (offset=-3)
		
	/*
		instr_mem[0] = 32'b0000000_00000_00011_000_00001_0110011;
		instr_mem[1] = 32'b0100000_00000_00011_000_00001_0110011;
		instr_mem[2] = 32'b0000000_00000_00011_001_00001_0110011;
		instr_mem[3] = 32'b0000000_00000_00011_010_00001_0110011;
		instr_mem[4] = 32'b0000000_00000_00011_011_00001_0110011;
		instr_mem[5] = 32'b0000000_00000_00011_100_00001_0110011;
		instr_mem[6] = 32'b0000000_00000_00011_101_00001_0110011;
		instr_mem[7] = 32'b0100000_00000_00011_101_00001_0110011;
		instr_mem[8] = 32'b0000000_00000_00011_110_00001_0110011;
		instr_mem[9] = 32'b0000000_00000_00011_111_00001_0110011;
		instr_mem[10] = 32'b0000000_00000_00011_111_00001_0110011;
		instr_mem[11] = 32'b0000000_00000_00011_111_00001_0110011;
	*/
	
	/*SW
		instr_mem[0] = 32'b0000000_00001_00000_010_00001_0100011;
		instr_mem[1] = 32'b0000000_00010_00001_010_00001_0100011;
		instr_mem[2] = 32'b0000000_00011_00010_010_00001_0100011;
		instr_mem[3] = 32'b0000000_00011_00011_010_00001_0100011;
	*/	
	/*LW
		instr_mem[0] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[1] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[2] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[3] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[4] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[5] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[6] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[7] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[8] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[9] = 32'b0000000_00100_00001_000_00001_0000011;
		instr_mem[10] = 32'b0000000_00100_00001_000_00001_0000011;
	*/
		
	end
	
	assign instruction = instr_mem[pc[10:2]];
endmodule