`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg rst;

cpu uut(
    .clk(clk),
    .rst(rst)
);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 1'b0;
    rst = 1'b0;
    #10;
    rst = 1'b1;
    #10;
    rst = 1'b0;
end

endmodule
