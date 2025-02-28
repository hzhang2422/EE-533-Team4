`timescale 1ns / 1ps

// ===============================
// Pipeline Datapath Module
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module pipeline 
	(
		// To verify D-MEM result 
		input [7:0]									mem_raddr_ver,
		output [63:0]								mem_rdata_ver,	
	
	   // misc	
		input 										clk,
		input 										reset
);

	// D-MEM
	wire [7:0]									dmem_waddr;
	wire [63:0]									dmem_wdata;
	wire 											dmem_we;
	wire [7:0]									dmem_raddr;
	wire [63:0]									dmem_rdata;

	// Pipeline
	wire [8:0]									pc_out;

	wire [31:0]									if_instr;

	wire											id_memwrite;
	wire 											id_regwrite;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	id_rs;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	id_rt;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	id_rd;
	wire [63:0]									id_rsdata;
	wire [63:0]									id_rtdata;
	wire [31:0] 								id_instr;
	
	wire											ex_memwrite;
	wire 											ex_regwrite;
	wire [63:0]									ex_rsdata;
	wire [63:0]									ex_rtdata;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	ex_rd;
	
	wire											mem_memwrite;
	wire 											mem_regwrite;
	wire [63:0]									mem_rsdata;
	wire [63:0]									mem_rtdata;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	mem_rd;
	wire [63:0]									mem_dout;
	
	wire											wb_regwrite;
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	wb_rd;
	wire [63:0]									wb_memdata;
	wire [63:0]									wb_regdata;
	
	// Verification(D-MEM)
	assign mem_rdata_ver = mem_raddr_ver === 8'bxxxxxxxx ? 64'b0 : dmem_rdata;	// If input mem_raddr_ver is unknown
	
	pc PC (
		.clk										(clk),
		.reset									(reset),

		.pc_out									(pc_out)
	);

	instr_mem I_MEM(
		.addr										(pc_out),
		.clk										(clk),
		.dout										(if_instr)
	);	

	if_id IF_ID (
		.instr_in								(if_instr),
		
		.memwrite								(id_memwrite),
		.regwrite								(id_regwrite),
		.rs										(id_rs),
		.rt										(id_rt),
		.rd										(id_rd),
		
		.clk										(clk), 
		.reset									(reset)
	);

	regfile RegFile (
		.rs				(id_rs), 
		.rt				(id_rt), 
		.rd				(wb_rd),
		.rddata			(wb_regdata),
		.regwrite		(wb_regwrite), 
		
		.rsdata_out		(id_rsdata), 
		.rtdata_out		(id_rtdata),
		
		.clk				(clk),
		.reset			(reset)
	);

	id_ex ID_EX (
		.regwrite_in							(id_regwrite),
		.memwrite_in							(id_memwrite),
		.rd_in									(id_rd),

		.rsdata_in								(id_rsdata),
		.rtdata_in								(id_rtdata),
		
		.memwrite_out							(ex_memwrite), 
		.regwrite_out							(ex_regwrite), 
		.rsdata_out								(ex_rsdata), 
		.rtdata_out								(ex_rtdata), 
		.rd_out									(ex_rd),
		
		.clk										(clk), 
		.reset									(reset)
	);
	
	ex_mem EX_MEM (
		.memwrite_in							(ex_memwrite), 
		.regwrite_in							(ex_regwrite), 
		.rsdata_in								(ex_rsdata), 
		.rtdata_in								(ex_rtdata), 
		.rd_in									(ex_rd),
		
		.memwrite_out							(mem_memwrite), 
		.regwrite_out							(mem_regwrite), 
		.rsdata_out								(mem_rsdata), 
		.rtdata_out								(mem_rtdata), 
		.rd_out									(mem_rd),
		
		.clk										(clk), 
		.reset									(reset)
	);
	
	// D-MEM
	assign dmem_waddr = mem_rsdata;
	assign dmem_wdata = mem_rtdata;
	assign dmem_we = mem_memwrite;
	assign dmem_raddr = 	mem_raddr_ver === 8'bxxxxxxxx ? mem_rsdata : mem_raddr_ver;	// If input mem_raddr_ver is unknown

   data_mem D_MEM(
		.addra				(dmem_waddr),
		.addrb				(dmem_raddr),
		.clka					(clk),
		.clkb					(clk),
		.dina					(dmem_wdata),				
		.doutb				(dmem_rdata),
		.wea					(dmem_we)
	);

	assign mem_dout = dmem_rdata;

	mem_wb MEM_WB (  
		.regwrite_in							(mem_regwrite),  
		.rd_in									(mem_rd),
		.memdata_in								(mem_dout),
		
		.regwrite_out							(wb_regwrite),
		.rd_out									(wb_rd),
		.memdata_out							(wb_memdata),
		
		.clk										(clk), 
		.reset									(reset) 
	);

	assign wb_regdata = wb_memdata;

endmodule
