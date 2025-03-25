`include "constants.vh"

module test;

	reg								clk,rst;
	
	//IF/WB-ID
	wire	[`INSTR_WIDTH-1:0]		id_instr;
	wire	[31:0]					id_pc_next;
	wire	[`DATA_WIDTH-1:0]		wb_alu_out;
	wire	[`DATA_WIDTH-1:0]		wb_mem_out;
	wire	[`DATA_WIDTH-1:0]		wb_rd_data;
	wire	[`REG_ADDR_WIDTH-1:0]	wb_rd_addr;
	wire							WB_Reg_Write;
	wire							WB_Mem_to_Reg;
	
	wire	[31:0]					id_if_JTA;
	wire							ID_IF_Jump;
	wire	[31:0]					id_if_BTA;
	wire							ID_IF_Branch;
	
	//TS
	wire	[1:0]					ts_threadID;
	wire	[1:0]					id_threadID;
	wire	[1:0]					ex_threadID;
	wire	[1:0]					me_threadID;
	wire	[1:0]					wb_threadID;
	
	wire	[31:0]					ts_t0_instr;
	wire	[31:0]					ts_t1_instr;
	wire	[31:0]					ts_t2_instr;
	wire	[31:0]					ts_t3_instr;
	wire	[31:0]					ts_t0_pc_next;
	wire	[31:0]					ts_t1_pc_next;
	wire	[31:0]					ts_t2_pc_next;
	wire	[31:0]					ts_t3_pc_next;
	
	
	//ID-EX
	wire	[31:0]					ex_pc_next;
	wire	[`DATA_WIDTH-1:0]		ex_rs1_data;
	wire	[`DATA_WIDTH-1:0]		ex_rs2_data;
	wire	[`DATA_WIDTH-1:0]		ex_imm_ext;
	wire	[`REG_ADDR_WIDTH-1:0]	ex_rd_addr;
	
	wire					 		EX_Reg_Write;
	wire							EX_Mem_Read;
	wire							EX_Mem_Write;
	wire							EX_Mem_to_Reg;
	wire	[3:0]					EX_Alu_Ctrl;
	wire							EX_Alu_Src2;
	wire							EX_Jump;
	
	//EX_ME
	wire	[`DATA_WIDTH-1:0]		me_alu_in;
	wire	[`REG_ADDR_WIDTH-1:0]	me_rd_addr;
	wire	[`DATA_WIDTH-1:0]		me_rs2_data;
	
	wire							ME_Reg_Write;
	wire							ME_Mem_Read;
	wire							ME_Mem_Write;
	wire							ME_Mem_to_Reg;
	
	
	// IF stage
	
	IF_stage dut_if_stage(
		.clk(clk),
		.rst(rst),//
		.IF_Jump(ID_IF_Jump),
		.IF_Branch(ID_IF_Branch),//
		.if_JTA(id_if_JTA),
		.if_BTA(id_if_BTA),//
		.ts_threadID(ts_threadID),
		.id_threadID(id_threadID),//
		.ts_t0_instr(ts_t0_instr),
		.ts_t0_pc_next(ts_t0_pc_next),
		.ts_t1_instr(ts_t1_instr),
		.ts_t1_pc_next(ts_t1_pc_next),
		.ts_t2_instr(ts_t2_instr),
		.ts_t2_pc_next(ts_t2_pc_next),
		.ts_t3_instr(ts_t3_instr),
		.ts_t3_pc_next(ts_t3_pc_next)
	);
	
	// TS stage
	
	TS_stage dut_ts_stage(
		.clk(clk),
		.rst(rst),//
		.TS_Jump(ID_IF_Jump),
		.TS_Branch(ID_IF_Branch),//
		.ts_JTA(id_if_JTA),
		.ts_BTA(id_if_BTA),//
		.ts_threadID(ts_threadID),//
		.ts_t0_instr(ts_t0_instr),
		.ts_t0_pc_next(ts_t0_pc_next),
		.ts_t1_instr(ts_t1_instr),
		.ts_t1_pc_next(ts_t1_pc_next),
		.ts_t2_instr(ts_t2_instr),
		.ts_t2_pc_next(ts_t2_pc_next),
		.ts_t3_instr(ts_t3_instr),
		.ts_t3_pc_next(ts_t3_pc_next),//
		.ts_id_instr(id_instr),
		.ts_id_pc_next(id_pc_next),
		.ts_id_threadID(id_threadID)
	);
	
	// ID stage
	
	assign wb_rd_data = WB_Mem_to_Reg ? wb_mem_out : wb_alu_out;
	
	ID_stage dut_id_stage(
		.clk(clk),
		.rst(rst),//
		.id_instr(id_instr),
		.id_pc_next(id_pc_next),
		.wb_rd_data(wb_rd_data),
		.wb_rd_addr(wb_rd_addr),//
		.WB_Reg_Write(WB_Reg_Write),//
		.id_ex_pc_next(ex_pc_next),
		.id_ex_rs1_data(ex_rs1_data),
		.id_ex_rs2_data(ex_rs2_data),
		.id_ex_imm_ext(ex_imm_ext),
		.id_ex_rd_addr(ex_rd_addr),//
		.id_JTA(id_if_JTA),
		.id_BTA(id_if_BTA),
		.ID_Jump(ID_IF_Jump),
		.ID_Branch(ID_IF_Branch),//
		.ID_EX_Reg_Write(EX_Reg_Write),
		.ID_EX_Mem_Read(EX_Mem_Read),
		.ID_EX_Mem_Write(EX_Mem_Write),
		.ID_EX_Mem_to_Reg(EX_Mem_to_Reg),
		.ID_EX_Alu_Crtl(EX_Alu_Ctrl),
		.ID_EX_Alu_Src2(EX_Alu_Src2),
		.ID_EX_Jump(EX_Jump),//
		.id_threadID(id_threadID),
		.wb_threadID(wb_threadID),
		.id_ex_threadID(ex_threadID)
	);
	
	// EX stage
	
	EX_stage dut_ex_stage(
		.clk(clk),
		.rst(rst),//
		.ex_pc_next(ex_pc_next),
		.ex_rs1_data(ex_rs1_data),
		.ex_rs2_data(ex_rs2_data),
		.ex_imm_ext(ex_imm_ext),
		.ex_rd_addr(ex_rd_addr),//
		.EX_Reg_Write(EX_Reg_Write),
		.EX_Mem_Read(EX_Mem_Read),
		.EX_Mem_Write(EX_Mem_Write),
		.EX_Mem_to_Reg(EX_Mem_to_Reg),
		.EX_Alu_Ctrl(EX_Alu_Ctrl),
		.EX_Alu_Src2(EX_Alu_Src2),
		.EX_Jump(EX_Jump),//
		.ex_me_alu_result(me_alu_in),
		.ex_me_rd_addr(me_rd_addr),
		.ex_me_rs2_data(me_rs2_data),//
		.EX_ME_Reg_Write(ME_Reg_Write),
		.EX_ME_Mem_Read(ME_Mem_Read),
		.EX_ME_Mem_Write(ME_Mem_Write),
		.EX_ME_Mem_to_Reg(ME_Mem_to_Reg),//
		.ex_threadID(ex_threadID),
		.ex_me_threadID(me_threadID)
	);
	
	
	// ME stage
	
	ME_stage dut_me_stage(
		.clk(clk),
		.rst(rst),//
		.me_alu_in(me_alu_in),
		.me_rd_addr(me_rd_addr),
		.me_rs2_data(me_rs2_data),//
		.ME_Reg_Write(ME_Reg_Write),
		.ME_Mem_Read(ME_Mem_Read),
		.ME_Mem_Write(ME_Mem_Write),
		.ME_Mem_to_Reg(ME_Mem_to_Reg),//
		.me_wb_alu_out(wb_alu_out),
		.me_wb_mem_out(wb_mem_out),
		.me_wb_rd_addr(wb_rd_addr),//
		.ME_WB_Reg_Write(WB_Reg_Write),
		.ME_WB_Mem_to_Reg(WB_Mem_to_Reg),//
		.me_threadID(me_threadID),
		.me_wb_threadID(wb_threadID)
	);
	
	Arbiter arbiter(
		.clk(clk),
		.rst(rst),
		.req(4'b1111),
		.ts_threadID(ts_threadID)
	);
	
	initial begin
		clk = 0;
		rst = 0;
		//rd_data = 64'h0;
		//Reg_Write = 0;
		//Alu_Ctrl = 4'b0001; 
		
		@(negedge clk) rst = 1;
		@(negedge clk) rst = 0;
	/*	@(negedge clk) begin
			rd_data = 64'h1;
			Reg_Write = 1;
			Alu_Ctrl = 4'b0010;
		end
	*/	
		#700
		$stop;
	end
	
	always #10 clk = ~clk;
endmodule