`timescale 1ns/1ps

`define UDP_REG_ADDR_WIDTH 16
`define CPCI_NF2_DATA_WIDTH 16

module ids_dropfifo
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
      input                                reset,
      input                                clk
   );

assign reg_req_out = reg_req_in;
assign reg_ack_out = reg_ack_in;
assign reg_rd_wr_L_out = reg_rd_wr_L_in;
assign reg_addr_out = reg_addr_in;
assign reg_data_out = reg_data_in;
assign reg_src_out =  reg_src_in;

/************signals************/
//latch 1 cycle to meet the FSM next state logic
reg in_wr_reg;
reg [DATA_WIDTH-1:0]  in_data_reg;
reg [CTRL_WIDTH-1:0]  in_ctrl_reg;

reg begin_pkt, begin_pkt_next;
reg end_pkt, end_pkt_next;
wire [8:0] depth;

//(max depth-2) : 1 cycle in advance + 1 latch slot 
assign in_rdy = (depth<9'h0fe);

//FSM state
reg [1:0] state, state_next;

//local parameter
parameter START = 2'b00;
parameter HEADER = 2'b01;
parameter PAYLOAD = 2'b10;

drop_fifo  dropfifo(
    .clk(clk),
    .rst(reset),
    .firstword(begin_pkt),
    .lastword(end_pkt),
    .fifowrite(in_wr_reg),
    .fiforead(out_rdy),
    .in_fifo({in_ctrl_reg,in_data_reg}),
    .out_fifo({out_ctrl,out_data}),
    .depth(depth),
    .valid_data(out_wr)
);

//FSM
//NSL and OFL
always @(*) begin
    state_next = state;
    begin_pkt_next = 1'b0;
    end_pkt_next = 1'b0;

    if(in_wr && (depth<=9'h0fe)) begin
    case (state)
      START: begin
        if(in_ctrl!= 0) begin
            state_next = HEADER;
            begin_pkt_next = 1'b1;
            end_pkt_next   = 1'b0;
        end
      end
      HEADER: begin
        begin_pkt_next = 1'b0;
        if(in_ctrl == 0) begin
          state_next = PAYLOAD;
        end 
      end
      PAYLOAD: begin
        if(in_ctrl != 0) begin
            state_next = START;
            end_pkt_next = 1'b1;
        end else begin
            state_next = PAYLOAD;
        end
      end
    endcase
  end
end

//SM
always @(posedge clk) begin
    if(reset) begin
        state <= START;
        begin_pkt <= 1'b0;
        end_pkt <= 1'b0;
        in_wr_reg <= 1'b0;
        in_ctrl_reg <= 8'b0;
        in_data_reg <= 64'b0;
    end
    else begin
        state <= state_next;
        begin_pkt <= begin_pkt_next;
        end_pkt <= end_pkt_next;
        in_wr_reg <= in_wr;
        in_ctrl_reg <= in_ctrl;
        in_data_reg <= in_data;
    end
end

endmodule
          


