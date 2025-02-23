`timescale 1ns / 1ps

// ===============================
// Pipeline Datapath Module
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module pipeline 
	(
	// To preload I-MEM
	input [8:0]									imem_waddr_pre,
	input [31:0]								instr_write_pre,
	input											instr_we_pre,
	
	// To preload D-MEM
	input [7:0]									dmem_waddr_pre,
	input [63:0]								dmem_wdata_pre,
	input											dmem_we_pre,

	// To verify RegFile result
	input [`PIPE_REG_ADDR_WIDTH - 1:0]	regfile_raddr_ver,
	output [63:0]								regfile_rdata_ver,

	// To verify D-MEM result 
	input [7:0]									mem_raddr_ver,
	output [63:0]								mem_rdata_ver,	

	// Status signals
	input 										start,	// Start pipeline signal

	// Outpu test
	
	input 										clk,
	input 										reset
);

	// I-MEM
	wire [8:0]									imem_waddr;
	wire [31:0]									instr_write;
	wire 											instr_we;

	// D-MEM
	wire [7:0]									dmem_waddr;
	wire [63:0]									dmem_wdata;
	wire 											dmem_we;

	// Verification(RegFile)
	wire [`PIPE_REG_ADDR_WIDTH - 1:0]	regfile_raddr;
	wire [63:0]									regfile_rdata;

	// Verification(D-MEM)
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
	
	// Preload I-MEM
	assign imem_waddr = !start ? imem_waddr_pre : 9'b0;
	assign instr_write = !start ? instr_write_pre : 32'b0;
	assign instr_we = !start ? instr_we_pre : 1'b0;

	// Preload D-MEM (code is in D-MEM block)
	
	// Verification(RegFile)
	assign regfile_raddr = !start ? regfile_raddr_ver : 3'b0;
	assign regfile_rdata_ver = !start ? regfile_rdata : 64'b0;

	// Verification(D-MEM)
	assign mem_rdata_ver = !start ? dmem_rdata : 64'b0;

	// Output test
	
	pc PC (
		.clk										(clk),
		.reset									(reset),
		.start									(start),

		.pc_out									(pc_out)
	);

	instr_mem I_MEM(
		.addra									(imem_waddr),
		.addrb									(pc_out),
		.clka										(clk),
		.clkb										(clk),
		.dina										(instr_write),
		.doutb									(if_instr),
		.wea										(instr_we)
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

		// To verify RegFile result
		.regfile_raddr	(regfile_raddr),
		.regfile_rdata	(regfile_rdata),
		
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
	assign dmem_waddr = !start ? dmem_waddr_pre : mem_rsdata;
	assign dmem_wdata = !start ? dmem_wdata_pre : mem_rtdata;
	assign dmem_we = !start ? dmem_we_pre : mem_memwrite;
	assign dmem_raddr = !start ? mem_raddr_ver : mem_rsdata;

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
