`include "constants.vh"

module TS_stage(
	input							clk,
	input							rst,
	
	input							TS_Jump,
	input							TS_Branch,
	
	input		[31:0]				ts_JTA,
	input		[31:0]				ts_BTA,
	
	input		[1:0] 				ts_threadID,  
	
	input 		[`INSTR_WIDTH-1:0] 	ts_t0_instr,
    input 		[31:0]  			ts_t0_pc_next,
    input 		[`INSTR_WIDTH-1:0] 	ts_t1_instr,
    input 		[31:0] 				ts_t1_pc_next,
    input 		[`INSTR_WIDTH-1:0]	ts_t2_instr,
    input 		[31:0]  			ts_t2_pc_next,
    input 		[`INSTR_WIDTH-1:0] 	ts_t3_instr,
    input 		[31:0]  			ts_t3_pc_next,
	
	output	reg	[`INSTR_WIDTH-1:0] 	ts_id_instr,
	output 	reg	[31:0]  			ts_id_pc_next,
	output	reg	[1:0]				ts_id_threadID
);

	reg		[`INSTR_WIDTH-1:0]		ts_instr;
	reg		[31:0]					ts_pc_next;
	
	always @(*) begin
		case(ts_threadID)
			2'b00: ts_instr = ts_t0_instr;
			2'b01: ts_instr = ts_t1_instr;
			2'b10: ts_instr = ts_t2_instr;
			2'b11: ts_instr = ts_t3_instr;
			default: ts_instr = 32'b0;
		endcase
	end
	
	always @(*) begin
		case(ts_threadID)
			2'b00: ts_pc_next = ts_t0_pc_next;
			2'b01: ts_pc_next = ts_t1_pc_next;
			2'b10: ts_pc_next = ts_t2_pc_next;
			2'b11: ts_pc_next = ts_t3_pc_next;
			default: ts_instr = 32'b0;
		endcase
	end
	
	wire		[1:0]				id_threadID;
	assign	id_threadID = ts_id_threadID;
	wire BrJr = (id_threadID==ts_threadID) && (TS_Branch||TS_Jump);
	
	always@(posedge clk or posedge rst) begin
		if (rst) begin
			ts_id_instr <= 32'b0;
			ts_id_pc_next <= 32'b0;
			ts_id_threadID <= 2'b0;
		end 
		else if(BrJr == 1'b1) begin
			ts_id_instr <= 32'b0;
			ts_id_pc_next <= 32'b0;
			ts_id_threadID <= 2'b0;
		end
		else begin
			ts_id_instr <= ts_instr;
			ts_id_pc_next <= ts_pc_next;
			ts_id_threadID <= ts_threadID;
		end
	end
	
endmodule