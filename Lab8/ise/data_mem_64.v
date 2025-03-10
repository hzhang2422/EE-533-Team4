module data_mem(
    input clk, rst, 
    input [1: 0] write_mem, 
    input [2: 0] read_mem,  

    input [63: 0] address, write_data,

    output reg [63: 0] out_mem
);

reg [63: 0] data [255: 0];
wire [63:0] memindex;

assign memindex = address>>3;

always @(*) begin
    case (read_mem[1:0])
      2'b00: begin
        out_mem = 64'b0;
      end
      2'b01: begin
        out_mem = data[memindex];
      end
      default: begin
        out_mem = 64'b0;
      end
    endcase
end

always @(posedge clk) begin
    if(rst) begin
        integer i;
        for(i=0;i<256;i=i+1) begin
            data[i] <= 64'b0;
        end
    end else begin
      case (write_mem)
        2'b01: begin
        data[memindex] <= write_data;
        end
        default: begin

        end
      endcase
    end
end

initial begin
    data[0]=64'h0000_0000_0000_0143;
    data[1]=64'h0000_0000_0000_007B;
    data[2]=64'h0000_0000_FFFF_FE39;
    data[3]=64'h0000_0000_0000_0002;
    data[4]=64'h0000_0000_0000_0062;
/*    data[5]=64'h0000_0000_
    data[6]=64'h0000_0000_
    data[7]=64'h0000_0000_
    data[8]=64'h0000_0000_
    data[9]=64'h0000_0000_*/
end

endmodule
