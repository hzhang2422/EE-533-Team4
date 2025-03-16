module mux_2(
    input signal,
//    input [31: 0] a, b,
    input [63: 0] a, b,

//    output [31: 0] out
    output [63: 0] out
);

assign out = (signal == 0) ? a : b;

endmodule

