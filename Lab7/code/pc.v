module pc(
    input rst, clk, pause, flush,
    input [31: 0] next_pc,

    output reg [31: 0] pc
);

always @(posedge clk) begin
    if(rst) begin
        pc <= 32'h0;
    end else if(flush) begin
        pc <= next_pc;
    end else if(pause) begin
        // empty
    end else begin
        pc <= next_pc;
    end 
end

endmodule