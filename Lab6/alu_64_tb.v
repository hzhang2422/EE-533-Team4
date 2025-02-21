`timescale 1ns / 1ps
module alu_64_tb;
    
    parameter SUB_START = 0;
    parameter SUB_WIDTH = 16;
    
    reg [63:0] A;
    reg [63:0] B;
    reg [3:0]  aluctrl;
    reg [63:0] cmp_val;
    reg clk;
    reg reset;
    
    wire [63:0] Z;
    wire overflow;
    
	
    alu_64 #(
        .SUB_START(SUB_START),
        .SUB_WIDTH(SUB_WIDTH)
    ) uut (
        .A(A),
        .B(B),
        .Z(Z),
        .overflow(overflow),
        .aluctrl(aluctrl),
        .cmp_val(cmp_val),
        .clk(clk),
        .reset(reset)
    );
    
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    
    initial begin
        // initial value
        reset    = 1;
        A        = 64'd0;
        B        = 64'd0;
        aluctrl  = 4'b0000;
        cmp_val  = 64'd0;
        
        #10;
        reset = 0;  // reset
        
        // 1. addition testï¼ˆaluctrl = 4'b0000ï¼‰
        A = 64'd20;
        B = 64'd30;
        aluctrl = 4'b0000;
        #10;
        $display("addition test: A=%d, B=%d, Z=%d, overflow=%b", A, B, Z, overflow);
        
        // 2. substract testï¼ˆaluctrl = 4'b0001ï¼‰
        A = 64'd50;
        B = 64'd20;
        aluctrl = 4'b0001;
        #10;
        $display("substract: A=%d, B=%d, Z=%d, overflow=%b", A, B, Z, overflow);
        
        // 3. bitwise AND testï¼ˆaluctrl = 4'b0010ï¼‰
        A = 64'hFF00FF00FF00FF00;
        B = 64'h0F0F0F0F0F0F0F0F;
        aluctrl = 4'b0010;
        #10;
        $display("bitwise AND: A=%h, B=%h, Z=%h", A, B, Z);
        
        // 4. bitwise OR testï¼ˆaluctrl = 4'b0011ï¼‰
        A = 64'hFF00FF00FF00FF00;
        B = 64'h0F0F0F0F0F0F0F0F;
        aluctrl = 4'b0011;
        #10;
        $display("bitwise OR: A=%h, B=%h, Z=%h", A, B, Z);
        
        // 5. bitwise XNOR testï¼ˆaluctrl = 4'b0100ï¼‰
        A = 64'hAAAAAAAAAAAAAAAA;
        B = 64'h5555555555555555;
        aluctrl = 4'b0100;
        #10;
        $display("bitwise XNOR: A=%h, B=%h, Z=%h", A, B, Z);
        
        // 6. compare testï¼ˆaluctrl = 4'b0101ï¼‰
        A = 64'd100;
        B = 64'd100;
        aluctrl = 4'b0101;
        #10;
        $display("compare(equal): A=%d, B=%d, Z=%h", A, B, Z);
        
        A = 64'd100;
        B = 64'd50;
        aluctrl = 4'b0101;
        #10;
        $display("compare(not equal): A=%d, B=%d, Z=%h", A, B, Z);
        
        // 7. logic left-shift testï¼ˆaluctrl = 4'b0110ï¼‰
        A = 64'd1;
        B = 64'd3;
        aluctrl = 4'b0110;
        #10;
        $display("logic left-shift: A=%d, B=%d, Z=%d", A, B, Z);
        
        // 8. logic right-shift testï¼ˆaluctrl = 4'b0111ï¼‰
        A = 64'd16;
        B = 64'd2; 
        aluctrl = 4'b0111;
        #10;
        $display("logic right-shift: A=%d, B=%d, Z=%d", A, B, Z);
        
        // 9. substring comparison testï¼ˆaluctrl = 4'b1000ï¼‰
        A = 64'h000000000000ABCD;
        B = 64'h000000000000ABCD;
        aluctrl = 4'b1000;
        #10;
        $display("substring comparison: A=%h, B=%h, Z=%h", A, B, Z);
        
        // 10. left-shift-then-compare testï¼ˆSTC, aluctrl = 4'b1001ï¼‰
        A = 64'd3;
        B = 64'd2;  // 3 << 2 = 12
        cmp_val = 64'd12;
        aluctrl = 4'b1001;
        #10;
        $display("left-STC test: A=%d, B=%d, cmp_val=%d, Z=%h", A, B, cmp_val, Z);
        
        // 11. right-shift-then-compare testï¼ˆSTC, aluctrl = 4'b1010ï¼‰
        A = 64'd32;
        B = 64'd3;  // 32 >> 3 = 4
        cmp_val = 64'd4;
        aluctrl = 4'b1010;
        #10;
        $display("right-STC: A=%d, B=%d, cmp_val=%d, Z=%h", A, B, cmp_val, Z);
        
        // test finish
        $finish;
    end
endmodule