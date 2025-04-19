module pc(
    input rst, clk, pause, flush,
    input pipeline_en,
//    input [31: 0] next_pc,
    input [63: 0] next_pc,

//    output reg [31: 0] pc
    output reg [63: 0] pc
);

always @(posedge clk) begin
    if(rst) begin
        pc <= 64'h0;
    end else if(pipeline_en) begin
	  if(flush) begin
        pc <= next_pc;
      end else if(pause) begin
         // empty
      end else begin
        pc <= next_pc;
      end 
	end
end

endmodule