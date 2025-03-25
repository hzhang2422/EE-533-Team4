`include "constants.vh"

module ME_stage(
	input							clk,
	input							rst,
	
	input	[`DATA_WIDTH-1:0]		me_alu_in,
	input	[`REG_ADDR_WIDTH-1:0]	me_rd_addr,
	input	[`DATA_WIDTH-1:0]		me_rs2_data,
	
	input							ME_Reg_Write,
	input							ME_Mem_Read,
	input							ME_Mem_Write,
	input							ME_Mem_to_Reg,
	
	output	reg	[`DATA_WIDTH-1:0]	me_wb_alu_out,
	output	reg [`DATA_WIDTH-1:0]	me_wb_mem_out,	
	output	reg	[`REG_ADDR_WIDTH-1:0] me_wb_rd_addr,
	
	output	reg						ME_WB_Reg_Write,
	output	reg						ME_WB_Mem_to_Reg,
	
	input		[1:0]				me_threadID,
	output	reg	[1:0]				me_wb_threadID		
);

	wire	[7:0]				dmem_addr;
	wire	[`DATA_WIDTH-1:0]	me_mem_out;
	wire	[`DATA_WIDTH-1:0]	me_alu_out;
	
	assign dmem_addr = me_alu_in[7:0]; //log2(`DMEM_DEPTH)-1
	
	D_mem d_mem(
		.clka(clk),
		.clkb(clk),
		.rst(rst),
		.wen(ME_Mem_Write),
		.addra(dmem_addr),
		.addrb(dmem_addr),
		.douta(me_mem_out),
		.dinb(me_rs2_data)
	);
	
	assign	me_alu_out = me_alu_in;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			me_wb_mem_out <= 64'b0;
			me_wb_alu_out <= 64'b0;
			me_wb_rd_addr <= 5'b0;
			ME_WB_Reg_Write <= 1'b0;
			ME_WB_Mem_to_Reg <= 1'b0;
			me_wb_threadID <= 2'b0;
		end else begin
			me_wb_mem_out <= me_mem_out;
			me_wb_alu_out <= me_alu_out;
			me_wb_rd_addr <= me_rd_addr;
			ME_WB_Reg_Write <= ME_Reg_Write;
			ME_WB_Mem_to_Reg <= ME_Mem_to_Reg;
			me_wb_threadID <= me_threadID;
		end
	end
endmodule