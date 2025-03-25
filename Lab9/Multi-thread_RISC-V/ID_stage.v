`include "constants.vh"

module ID_stage(
	input							clk,
	input							rst,

	input	[`INSTR_WIDTH-1:0]		id_instr,
	input	[31:0]					id_pc_next,
	input	[`DATA_WIDTH-1:0]		wb_rd_data,
	input	[`REG_ADDR_WIDTH-1:0]	wb_rd_addr,
	
	input							WB_Reg_Write,
	
	output	reg	[31:0]				id_ex_pc_next,
	output	reg	[`DATA_WIDTH-1:0]	id_ex_rs1_data,
	output	reg [`DATA_WIDTH-1:0]	id_ex_rs2_data,
	output	reg	[`DATA_WIDTH-1:0]	id_ex_imm_ext,
	output	reg	[`REG_ADDR_WIDTH-1:0] id_ex_rd_addr,
	
	output		[31:0]				id_JTA,
	output		[31:0]				id_BTA,
	output							ID_Jump,
	output							ID_Branch,
	
	output	reg						ID_EX_Reg_Write,
	output	reg						ID_EX_Mem_Read,
	output	reg						ID_EX_Mem_Write,
	output	reg						ID_EX_Mem_to_Reg,
	output	reg	[3:0]				ID_EX_Alu_Crtl,
	output	reg						ID_EX_Alu_Src2,
	output	reg						ID_EX_Jump,
	
	input		[1:0]				id_threadID,
	input		[1:0]				wb_threadID,
	output	reg	[1:0]				id_ex_threadID
);
	// reg_file
	wire	[`REG_ADDR_WIDTH-1:0]	rs1_addr;
	wire	[`REG_ADDR_WIDTH-1:0]	rs2_addr;
	wire	[`REG_ADDR_WIDTH-1:0]	id_rd_addr;
	
	assign	rs1_addr = id_instr[19:15];
	assign	rs2_addr = id_instr[24:20];
	assign	id_rd_addr = id_instr[11:7];
	
	wire	[`DATA_WIDTH-1:0]		id_rs1_data;
	wire	[`DATA_WIDTH-1:0]		id_rs2_data;
	
	Reg_file reg_file(
		.clk(clk),
		.rst(rst),
		.rs1_addr(rs1_addr),
		.rs2_addr(rs2_addr),
		.rd_addr(wb_rd_addr),
		.Reg_Write(WB_Reg_Write),
		.rd_data(wb_rd_data),
		.rs1_data(id_rs1_data),
		.rs2_data(id_rs2_data),
		.id_threadID(id_threadID),
		.wb_threadID(wb_threadID)
	);
	
	// controller
	wire	[6:0]	opcode;
	wire	[2:0]	func3;
	wire	[6:0]	func7;
	wire	[3:0]	ID_Alu_Ctrl;
	wire 			ID_Reg_Write;
	wire			ID_Mem_Read;
	wire			ID_Mem_Write;
	wire			ID_Mem_to_Reg;
	wire			ID_Alu_Src2;
	wire			Branch;
	
	
	assign	opcode = id_instr[6:0];
	assign	func3 = id_instr[14:12];
	assign	func7 = id_instr[31:25];
	
	Controller controller(
		.opcode(opcode),
		.func3(func3),
		.func7(func7),
		.Alu_Ctrl(ID_Alu_Ctrl),
		.Reg_Write(ID_Reg_Write),
		.Mem_Read(ID_Mem_Read),
		.Mem_Write(ID_Mem_Write),
		.Mem_to_Reg(ID_Mem_to_Reg),
		.Alu_Src2(ID_Alu_Src2),
		.Jump(ID_Jump),
		.Branch(Branch)
	);
	
	// Imm generation
	reg			[`DATA_WIDTH-1:0]	imm_ext;
	
	always @(*) begin
		case (opcode)
			7'b0000011, 7'b0010011, 7'b1100111: begin //LW, I-type
				imm_ext = {{52{id_instr[31]}},id_instr[31:20]};
			end
			
			7'b0100011: begin //SW
				imm_ext = {{52{id_instr[31]}},id_instr[31:25],id_instr[11:7]};
			end
			
			7'b1101111: begin //JAL
				imm_ext = {{45{id_instr[31]}},id_instr[19:12],id_instr[20],id_instr[30:21]};
			end
			
			7'b1100011: begin //Branch
				imm_ext = {{53{id_instr[31]}},id_instr[7],id_instr[30:25],id_instr[11:8]};
			end
			
			default: imm_ext = 64'b0;
		endcase
	end
	
	// Jump Branch
	wire Branch_CTRL;
	
	Br_ctrl br_ctrl (
		.rs1(id_rs1_data),
		.rs2(id_rs2_data),
		.func3(func3),
		.Br_ctrl(Branch_CTRL)
	);
	
	assign ID_Branch = Branch_CTRL && Branch;
	assign id_BTA = id_pc_next + imm_ext[31:0];
	
	
	// JTA BTA
	wire	[31:0]	JAL_TA;
	wire	[31:0]	JALR_TA;
	assign	JAL_TA = (id_pc_next - 4) + imm_ext[31:0];
	assign	JALR_TA = id_rs1_data[31:0] + imm_ext[31:0];
	
	assign	id_JTA = (opcode == 7'b1101111) ? JAL_TA : JALR_TA;
	
	// ID|EX registers
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			id_ex_pc_next <= 32'h0;
			id_ex_rs1_data <= 64'h0;
			id_ex_rs2_data <= 64'h0;
			id_ex_imm_ext <= 64'b0;
			id_ex_rd_addr <= 5'b0;
			ID_EX_Reg_Write <= 1'b0;
			ID_EX_Mem_Read <= 1'b0;
			ID_EX_Mem_Write <= 1'b0;
			ID_EX_Mem_to_Reg <= 1'b0;
			ID_EX_Alu_Crtl <= 4'b0000;
			ID_EX_Alu_Src2 <= 1'b0;
			ID_EX_Jump <= 1'b0;
			id_ex_threadID <= 2'b0;
			
		end else begin
			id_ex_pc_next <= id_pc_next;
			id_ex_rs1_data <= id_rs1_data;
			id_ex_rs2_data <= id_rs2_data;
			id_ex_imm_ext <= imm_ext;
			id_ex_rd_addr <= id_rd_addr;
			ID_EX_Reg_Write <= ID_Reg_Write;
			ID_EX_Mem_Read <= ID_Mem_Read;
			ID_EX_Mem_Write <= ID_Mem_Write;
			ID_EX_Mem_to_Reg <= ID_Mem_to_Reg;
			ID_EX_Alu_Crtl <= ID_Alu_Ctrl;
			ID_EX_Alu_Src2 <= ID_Alu_Src2;
			ID_EX_Jump <= ID_Jump;
			id_ex_threadID <= id_threadID;
		end
	end
endmodule