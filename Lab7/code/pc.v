module pc(
    input                   clk, rst, stall, flush,
    input       [31:0]      next_pc,

    output reg  [31:0]      pc
);

always @(posedge clk) begin
    if(rst) begin
        pc = 32'h5c;
    end else if (flush) begin
        pc <= next_pc;
    end else if (stall) begin
        //empty
    end else begin
        pc <= next_pc;
    end
end

endmodule