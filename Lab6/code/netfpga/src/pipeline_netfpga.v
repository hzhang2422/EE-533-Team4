`timescale 1ns / 1ps

// ===============================
// Pipeline Datapath Module
// ===============================
`define PIPE_REG_ADDR_WIDTH 3

module pipeline 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
	(
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc	
		input 										clk,
		input 										reset
);

	// Software registers
	wire [7:0]									mem_raddr_ver;

   // Hardware registers
   wire [63:0]								   mem_rdata_ver;
	wire [31:0]								   mem_rdata_ver_high;	
   wire [31:0]								   mem_rdata_ver_low;

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
	
   assign out_data = in_data;
   assign out_ctrl =in_ctrl;
   assign out_wr = in_wr;
   assign in_rdy = out_rdy;

	// Verification(D-MEM)
	assign mem_rdata_ver = dmem_rdata;
   assign mem_rdata_ver_low = mem_rdata_ver[63:32];
   assign mem_rdata_ver_high = mem_rdata_ver[31:0];
	
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
	assign dmem_raddr = 	pc_out == 9'b111111111 ? mem_raddr_ver : mem_rsdata;	// If end of program

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

   generic_regs
   #( 
      .UDP_REG_SRC_WIDTH   (UDP_REG_SRC_WIDTH),
      .TAG                 (`PIPELINE_BLOCK_ADDR),          // Tag -- eg. MODULE_TAG
      .REG_ADDR_WIDTH      (`PIPELINE_REG_ADDR_WIDTH),     // Width of block addresses -- eg. MODULE_REG_ADDR_WIDTH
      .NUM_COUNTERS        (0),                 // Number of counters
      .NUM_SOFTWARE_REGS   (1),                 // Number of sw regs
      .NUM_HARDWARE_REGS   (2)                  // Number of hw regs
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // --- counters interface
      .counter_updates  (),
      .counter_decrement(),

      // --- SW regs interface
      .software_regs    (mem_raddr_ver),

      // --- HW regs interface
      .hardware_regs    ({mem_rdata_ver_high, mem_rdata_ver_low}),

      .clk              (clk),
      .reset            (reset)
    );

endmodule
