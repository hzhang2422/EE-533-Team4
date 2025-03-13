module data_mem_64(
    input clk, rst, 
    input [1: 0] write_mem, 
    input [2: 0] read_mem,  

    input [63: 0] address, write_data,

    output reg [63: 0] out_mem
);

reg [63: 0] data [255: 0];
wire [7:0] memindex;

assign memindex = address>>3;

always @(*) begin
    case (read_mem[1:0])
      2'b00: begin
        out_mem = 64'b0;
      end
      //lw
      2'b01: begin
        out_mem = data[memindex];
      end
      //lh
      2'b10: begin
        if(read_mem[2]) out_mem = {32'b0, data[memindex][31:0]};
        else out_mem = {{32{data[memindex][31]}}, data[memindex][31:0]};
      end
      //lb
      2'b11: begin
        if(read_mem[2]) out_mem = {56'b0, data[memindex][7:0]};
        else out_mem = {{56{data[memindex][7]}}, data[memindex][7:0]};
      end
      default: begin
        out_mem = 64'b0;
      end
    endcase
end

always @(posedge clk) begin
      case (write_mem)
        2'b01: begin
        data[memindex] <= write_data;
        end
        2'b10: begin
        data[memindex][31:0] <= write_data[31:0];
        end
        2'b11: begin
        data[memindex][7:0] <= write_data[7:0];
        end
        default: begin

        end
      endcase
end

initial begin
    data[0]=64'h0000_0000_0000_0143; //323
    data[1]=64'h0000_0000_0000_007B; //123
    data[2]=64'h0000_0000_FFFF_FE39; //-455
    data[3]=64'h0000_0000_0000_0002; //2
    data[4]=64'h0000_0000_0000_0062; //98
    data[5]=64'h0000_0000_0000_007D; //125
    data[6]=64'h0000_0000_0000_000A; //10
    data[7]=64'h0000_0000_0000_0041; //65
    data[8]=64'h0000_0000_FFFF_FFC8; //-56
    data[9]=64'h0000_0000_0000_0000; //0
end

endmodule
