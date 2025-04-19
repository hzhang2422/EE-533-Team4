`timescale 1ns/1ps

module drop_fifo(
    input clk,
    input rst,
    input firstword,
    input lastword,
    input fifowrite,
    input fiforead,
    input [71:0] in_fifo,
    output [71:0] out_fifo,
    output reg [8:0] depth,
    output reg valid_data 
);

wire full;
wire empty;

assign full = (depth == 9'h100);
assign empty = (depth == 8'h00);

reg [7:0] headptr, writeptr, readptr;

wire read_enable =  fiforead && (readptr != headptr) && (readptr != writeptr) && ~empty;
wire write_enable = fifowrite && ~full;

RAM9B fifo_block(
    .addra(writeptr),
    .dina(in_fifo),
    .wea(write_enable),
    .clka(clk),
    .clkb(clk),
    .addrb(readptr),
    .doutb(out_fifo)
);

always @(posedge clk) begin
    if(rst) begin
        headptr <= 0;
        writeptr <= 0;
        readptr <= 0;
        depth <= 9'b0;
        valid_data <= 0;
    end else begin
        if(firstword|lastword) begin
            //move write pointer to head pointer
            headptr <= writeptr;
        end
        if(write_enable) begin
            writeptr <= writeptr + 1;
        end
        if(read_enable) begin
            readptr <= readptr + 1;
        end
        //if writing only, increasing depth
        if(write_enable && ~read_enable) begin
            depth <= depth + 1;
        end
        if(read_enable && ~write_enable) begin
            depth <= depth - 1;
        end
        valid_data <= read_enable;
    end
end

endmodule









