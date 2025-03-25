`include "constants.vh"

module IF_stage (
	input							clk,
	input							rst,
	
	input							IF_Jump,
	input							IF_Branch,
	
	input		[31:0]				if_JTA,
	input		[31:0]				if_BTA,
	
	input		[1:0] 				ts_threadID,  
    input 		[1:0] 				id_threadID,
	
	output 		[`INSTR_WIDTH-1:0] 	ts_t0_instr,
    output 		[31:0]  			ts_t0_pc_next,
    output 		[`INSTR_WIDTH-1:0] 	ts_t1_instr,
    output 		[31:0] 				ts_t1_pc_next,
    output 		[`INSTR_WIDTH-1:0]	ts_t2_instr,
    output 		[31:0]  			ts_t2_pc_next,
    output 		[`INSTR_WIDTH-1:0] 	ts_t3_instr,
    output 		[31:0]  			ts_t3_pc_next
	
);
	// PC
	wire		[3:0]				TS_Thread, ID_Thread;
	wire		[31:0]				pc	[3:0];
	wire		[31:0]				if_pc_next [3:0];
	wire		[3:0]				BrJr, Stall;
	
	genvar i;
	generate
		for (i = 0; i < 4; i = i + 1) begin
			assign TS_Thread[i] = (ts_threadID == i[1:0]); 
			assign ID_Thread[i] = (id_threadID == i[1:0]);
	
			assign if_pc_next[i] = (IF_Branch || IF_Jump) && ID_Thread[i] ? 
							(IF_Branch ? if_BTA : if_JTA) : pc[i] + 4;
	
			assign BrJr[i] = ID_Thread[i] && (IF_Branch || IF_Jump);
			assign Stall[i] = ~TS_Thread[i] && ~TS_Thread[i];
			
			PC pc_reg(
				.clk(clk),
				.rst(rst),
				.stall(Stall[i]),
				.pc_next(if_pc_next[i]),
				.pc(pc[i])
			);
			
		end
	endgenerate
	
	// I-mem
	wire	[`INSTR_WIDTH-1:0]	instruction [3:0];
	
	I_mem_t0 i_mem_t0(
		.pc(pc[0]),
		.instruction(instruction[0])
	);
	
	I_mem_t1 i_mem_t1(
		.pc(pc[1]),
		.instruction(instruction[1])
	);
	
	I_mem_t2 i_mem_t2(
		.pc(pc[2]),
		.instruction(instruction[2])
	);
	
	I_mem_t3 i_mem_t3(
		.pc(pc[3]),
		.instruction(instruction[3])
	);
	
	reg		[`INSTR_WIDTH-1:0]		ts_instr [3:0];
	reg		[31:0]					ts_pc_next [3:0];	

	genvar k;  // new/another genvar!!
	generate
		for (k = 0; k < 4; k = k + 1) begin : IFtoTS
			// Instr Pipeline Register
			always@(posedge clk or posedge rst) begin
				if (rst) begin
					ts_instr[k] <= 32'b0;
					ts_pc_next[k] <= 32'b0;					
				end
				else if(BrJr[k] == 1'b1) begin
					ts_instr[k] <= 32'b0;
					ts_pc_next[k] <= 32'b0;
				end
				else if(!TS_Thread[k] == 1'b0) begin
					ts_instr[k] <= instruction[k];
					ts_pc_next[k] <= if_pc_next[k];
				end			
			end			
		end
	endgenerate
	
	assign {ts_t0_instr, ts_t0_pc_next} = {ts_instr[0], ts_pc_next[0]};
	assign {ts_t1_instr, ts_t1_pc_next} = {ts_instr[1], ts_pc_next[1]};
	assign {ts_t2_instr, ts_t2_pc_next} = {ts_instr[2], ts_pc_next[2]};
	assign {ts_t3_instr, ts_t3_pc_next} = {ts_instr[3], ts_pc_next[3]};
	
endmodule	
	