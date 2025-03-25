`include "constants.vh"

module EX_stage(
	input							clk,
	input							rst,
	
	input	[31:0]					ex_pc_next,
	input	[`DATA_WIDTH-1:0]		ex_rs1_data,
	input	[`DATA_WIDTH-1:0]		ex_rs2_data,
	input	[`DATA_WIDTH-1:0]		ex_imm_ext,
	input	[`REG_ADDR_WIDTH-1:0]	ex_rd_addr,
	
	input							EX_Reg_Write,
	input							EX_Mem_Read,
	input							EX_Mem_Write,
	input							EX_Mem_to_Reg,
	input	[3:0]					EX_Alu_Ctrl,
	input							EX_Alu_Src2,
	input							EX_Jump,
	
	output	reg [`DATA_WIDTH-1:0]	ex_me_alu_result,
	output	reg	[`REG_ADDR_WIDTH-1:0]  ex_me_rd_addr,
	output	reg	[`DATA_WIDTH-1:0]	ex_me_rs2_data,
	
	output	reg						EX_ME_Reg_Write,
	output	reg						EX_ME_Mem_Read,
	output	reg						EX_ME_Mem_Write,
	output	reg						EX_ME_Mem_to_Reg,
	
	input		[1:0]				ex_threadID,
	output	reg	[1:0]				ex_me_threadID	
);
	wire	[`DATA_WIDTH-1:0]	alu_src2;
	wire	[`DATA_WIDTH-1:0]	ex_alu_result;
	wire	[`DATA_WIDTH-1:0]	alu_result;
	
	assign	alu_src2 = EX_Alu_Src2 ? ex_imm_ext : ex_rs2_data;

	ALU_64 alu_64(
		.A(ex_rs1_data),
		.B(alu_src2),
		.Alu_Ctrl(EX_Alu_Ctrl),
		.Z(alu_result)
	);
	
	assign ex_alu_result = (EX_Jump == 1'b1) ? {{32{1'b0}},ex_pc_next} : alu_result;
	
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ex_me_alu_result <= 64'b0;
			ex_me_rd_addr <= 5'b0;
			ex_me_rs2_data <= 64'b0;
			EX_ME_Reg_Write <= 1'b0;
			EX_ME_Mem_Read <= 1'b0;
			EX_ME_Mem_Write <= 1'b0;
			EX_ME_Mem_to_Reg <= 1'b0;
			ex_me_threadID <= 2'b0;
		end else begin
			ex_me_alu_result <= ex_alu_result;
			ex_me_rd_addr <= ex_rd_addr;
			ex_me_rs2_data <= ex_rs2_data;
			EX_ME_Reg_Write <= EX_Reg_Write;
			EX_ME_Mem_Read <= EX_Mem_Read;
			EX_ME_Mem_Write <= EX_Mem_Write;
			EX_ME_Mem_to_Reg <= EX_Mem_to_Reg;
			ex_me_threadID <= ex_threadID;
		end
	end
endmodule
			