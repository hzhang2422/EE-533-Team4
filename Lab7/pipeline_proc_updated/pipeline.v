`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:56:15 02/14/2024 
// Design Name: 
// Module Name:    pipeline 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pipeline(
	input clk,
	input enable,
	input reset,
	output reg [8:0] PC_out,
	//pi_di is a flag used to jump to PC = 0 when current opcode is 7'b1111111
	output pi_di,
	// Memory Interface
	output [63:0] mem_data_out,
	input [7:0] MemAddressQuery
    );

//////////////Declare internal wires and registers for inter-stage communication///////////////


////////////////////////////global//////////////////////////////////
//Branch
wire br;
wire [8:0] br_target;


///////////////////////////IF stage/////////////////////////////////
wire [31:0] IF_ID_out;
reg IF_ID_ring;
reg [8:0] IF_ID_PC;


///////////////////////////ID stage/////////////////////////////////
wire [63:0] ID_EX_r0data_w, ID_EX_r1data_w;
reg [63:0] ID_EX_r0data, ID_EX_r1data;

//ALU & Branch
reg [2:0] ID_EX_ALUop;
wire [2:0] ID_EX_ALUop_w;
reg ID_EX_sub, ID_EX_ALUSel;
wire ID_EX_sub_w, ID_EX_ALUSel_w;
reg [1:0] ID_EX_br;
wire [1:0]ID_EX_br_w;

//Memory & Register
reg ID_EX_memWrite, ID_EX_WBSel, ID_EX_regWrite;
wire ID_EX_memWrite_w, ID_EX_WBSel_w, ID_EX_regWrite_w;
reg [4:0] ID_EX_rd;


reg [8:0] ID_EX_PC;
wire [63:0] imm_i, imm_b, imm_s;
reg [63:0] ID_EX_imm, ID_EX_imm_w;
reg ID_EX_pidi;
wire ID_EX_pidi_w;


////////////////////////////EX stage///////////////////////////////
//ALU & ALU4branch
wire [63:0] EX_op;
reg [63:0] EX_MEM_ALUResult;
wire [63:0] EX_MEM_ALUResult_w;
reg EX_MEM_eq, EX_MEM_uslt;
wire EX_MEM_eq_w, EX_MEM_uslt_w;
reg [1:0] EX_MEM_br;

//Memory & Register
reg [63:0] EX_MEM_memData;
reg EX_MEM_memWrite, EX_MEM_WBSel, EX_MEM_regWrite;


reg [8:0] EX_MEM_PC;
reg [4:0] EX_MEM_rd;
reg EX_MEM_pidi;


////////////////////////////MEM stage///////////////////////////////
wire [63:0] MEM_WB_memResult;
reg [63:0] MEM_WB_ALUResult;
reg MEM_WB_WBSel, MEM_WB_regWrite;
reg [4:0] MEM_WB_rd;


///////////////////////////WB stage////////////////////////////////
wire [63:0] WB_regData;


/////////////////////////////////Logic/////////////////////////////////////


//PC
	always@(posedge clk)
	begin
		if(reset)
			PC_out <= 9'd0;
		else if(enable)
			//if br then fetch inst at bta, otherwise fetch pc+1
			PC_out <= (br ? br_target : PC_out + 1);
			//PC_out <= PC_out + 1;
	end
	
//IF stage
	InstructionMemory IMem (
	.addr(PC_out),
	.clk(clk),
	.dout(IF_ID_out),
	.en(enable)
	);
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			IF_ID_ring 				<= 1'd0;
			IF_ID_PC 				<= 9'd0;
		end
		else if(enable)
		begin
			IF_ID_ring 				<= (br ? 1'd1 : 1'd0);
			IF_ID_PC 				<= PC_out;
		end
	end
		
	
//ID stage
	RegFile regfile (
		.clk(clk),
		.reset(reset),
		.r0addr(IF_ID_out[19:15]),
		.r1addr(IF_ID_out[24:20]),
		.r0data(ID_EX_r0data_w),
		.r1data(ID_EX_r1data_w),
		.wren(MEM_WB_regWrite),
		.wraddr(MEM_WB_rd),
		.wrdata(MEM_WB_WBSel ? MEM_WB_memResult : MEM_WB_ALUResult)
	);

	//decoding
	control_unit cu1(
		.opcode(IF_ID_out[6:0]),
		.func3(IF_ID_out[14:12]),
		.bit30(IF_ID_out[30]),
		.sub(ID_EX_sub_w),
		.ALUop(ID_EX_ALUop_w),
		.ALUSel(ID_EX_ALUSel_w),
		.branch(ID_EX_br_w),
		.memWrite(ID_EX_memWrite_w),
		.WBSel(ID_EX_WBSel_w),
		.regWrite(ID_EX_regWrite_w),
		.pidi(ID_EX_pidi_w)
	);
	
	//imm generator
	assign imm_i = { {52{IF_ID_out[31]}}, IF_ID_out[31:20] };
	assign imm_s = { {52{IF_ID_out[31]}}, IF_ID_out[31:25], IF_ID_out[11:7] };
	assign imm_b = { {53{IF_ID_out[31]}}, IF_ID_out[7], IF_ID_out[30:25], IF_ID_out[11:8] };
	
	always@(*)
	begin
		case(IF_ID_out[6:4])
			3'b001 : ID_EX_imm_w = imm_i;
			3'b000 : ID_EX_imm_w = imm_i;
			3'b110 : ID_EX_imm_w = imm_b;
			3'b010 : ID_EX_imm_w = imm_s;
			default : ID_EX_imm_w = 64'd0;
		endcase
	end
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			ID_EX_r0data 			<= 64'd0;
			ID_EX_r1data 			<= 64'd0;
			ID_EX_ALUop 			<= 3'd0;
			ID_EX_sub 				<= 1'd0;
			ID_EX_br 				<= 2'd00;
			ID_EX_ALUSel 			<= 1'd0;
			ID_EX_memWrite 			<= 1'd0;
			ID_EX_WBSel 			<= 1'd0;
			ID_EX_regWrite 			<= 1'd0;
			ID_EX_rd 				<= 5'd0;
			ID_EX_PC 				<= 9'd0;
			ID_EX_imm 				<= 64'd0;
			ID_EX_pidi 				<= 1'd0;
		end
		else if(enable)
		begin
			ID_EX_r0data 			<= ID_EX_r0data_w;
			ID_EX_r1data 			<= ID_EX_r1data_w;
			ID_EX_ALUop 			<= ((IF_ID_ring | br) ? 3'd0 : ID_EX_ALUop_w);
			ID_EX_sub 				<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_sub_w);
			ID_EX_ALUSel 			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_ALUSel_w);
			ID_EX_br 				<= ((IF_ID_ring | br) ? 2'd00 : ID_EX_br_w);
			ID_EX_memWrite 			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_memWrite_w);
			ID_EX_WBSel 			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_WBSel_w);
			ID_EX_regWrite 			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_regWrite_w);
			ID_EX_rd 				<= IF_ID_out[11:7];
			ID_EX_PC 				<= IF_ID_PC;
			ID_EX_imm 				<= ID_EX_imm_w;
			ID_EX_pidi 				<= ID_EX_pidi_w;
		end
	end

//EX stage
	assign EX_op = ID_EX_ALUSel ? ID_EX_imm : ID_EX_r1data;

	ALU a1(
		.a(ID_EX_r0data),
		.b(EX_op),
		.branch(ID_EX_br),
		.op(ID_EX_ALUop),
		.sub(ID_EX_sub),
		.z(EX_MEM_ALUResult_w),
		.zero(),
		.uslt(EX_MEM_uslt_w),
		.slt(),
		.eq(EX_MEM_eq_w),
		.neq()
	);


	always@(posedge clk)
	begin
		if(reset)
		begin
			EX_MEM_ALUResult 		<= 64'd0;
			EX_MEM_eq				<= 1'd0;
			EX_MEM_uslt				<= 1'd0;
			EX_MEM_memData	 		<= 64'd0;
			EX_MEM_br				<= 1'd0;
			EX_MEM_memWrite			<= 1'd0;
			EX_MEM_WBSel			<= 1'd0;
			EX_MEM_regWrite			<= 1'd0;
			EX_MEM_PC 				<= 9'd0;
			EX_MEM_rd	 			<= 5'd0;
			EX_MEM_pidi				<= 1'd0;
		end
		else if(enable)
		begin
			EX_MEM_ALUResult 		<= EX_MEM_ALUResult_w;
			EX_MEM_eq				<= EX_MEM_eq_w;
			EX_MEM_uslt           <= EX_MEM_uslt_w;
			EX_MEM_memData	 		<= (ID_EX_br ? ID_EX_imm : ID_EX_r1data);
			EX_MEM_br				<= ((IF_ID_ring | br) ? 2'd00 : ID_EX_br);
			EX_MEM_memWrite			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_memWrite);
			EX_MEM_WBSel			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_WBSel);
			EX_MEM_regWrite			<= ((IF_ID_ring | br) ? 1'd0 : ID_EX_regWrite);
			EX_MEM_PC 				<= ID_EX_PC;
			EX_MEM_rd	 			<= ID_EX_rd;
			EX_MEM_pidi				<= ID_EX_pidi;
		end
	end
	
//Mem stage
	branch_unit bu1(
		.eq(EX_MEM_eq),
		.uslt(EX_MEM_uslt),
		.branch(EX_MEM_br),
		.imm(EX_MEM_memData),
		.PC(EX_MEM_PC),
		.pidi_d(EX_MEM_pidi),
		.bta(br_target),
		.branch_taken(br)
	);

	DataMemory DMem (
		.clka(clk),
		.clkb(clk),
		.addra(EX_MEM_ALUResult[7:0]),
		.dina(EX_MEM_memData),
		.ena(enable),
		.wea(EX_MEM_memWrite),
		.douta(MEM_WB_memResult),
		//Memory Interface
		.addrb(MemAddressQuery),
		.doutb(mem_data_out)
	);
	
//WB stage
	always@(posedge clk)
	begin
		if(reset)
		begin
			MEM_WB_ALUResult 		<= 64'd0;
			MEM_WB_WBSel 			<= 1'd0;
			MEM_WB_regWrite			<= 1'd0;
			MEM_WB_rd 				<= 5'd0;
		end
		else if(enable)
		begin
			MEM_WB_ALUResult 		<= EX_MEM_ALUResult;
			MEM_WB_WBSel 			<= EX_MEM_WBSel;
			MEM_WB_regWrite			<= EX_MEM_regWrite;
			MEM_WB_rd 				<= EX_MEM_rd;
		end
	end
	
endmodule
