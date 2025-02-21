`timescale 1ns / 1ps

module alu_64 #(
	parameter SUB_START = 0,
	parameter SUB_WIDTH = 16
)	(
	input		[63:0]	A,
	input		[63:0]	B,
	output reg	[63:0]	Z,
	output reg			overflow,
	
	input		[3:0]	aluctrl, 	//4'b0000 add
									//4'b0001 substract
									//4'b0010 bitwise AND
									//4'b0011 bitwise OR
									//4'b0100 bitwise XNOR
									//4'b0101 compare
									//4'b0110 logic left-shift
									//4'b0111 logic right-shift
									//4'b1000 substring comparison
									//4'b1001 left-shift-then-compare(STC)
									//4'b1010 right-shift-then-compare(STC)
	input 		[63:0]	cmp_val, //value of STC
	
	input		clk,
	input		reset
	);
	
	reg		[63:0]	result;
	reg             overflow_nxt;
	
	//add&sub
	wire	[63:0]	b_input; // 'substract enable'
	wire			cin;
	wire	[63:0]	add_sub_result;
	wire			cout;
	wire            cin_msb;
	
	
	assign	b_input = (aluctrl == 4'b0001) ? ~B : B;
	assign	cin = (aluctrl == 4'b0001) ? 1'b1 : 1'b0;
	
	//substring comparison
	wire 	[SUB_WIDTH-1:0] sub_a;
	wire 	[SUB_WIDTH-1:0] sub_b;
	
	assign sub_a = A[SUB_START + SUB_WIDTH - 1 : SUB_START];
	assign sub_b = B[SUB_START + SUB_WIDTH - 1 : SUB_START];
	
	//shift-then-compare(STC)
	wire	[63:0]	shifted_data_left;
	wire	[63:0]	shifted_data_right;
	
	assign	shifted_data_left = A << B[5:0];
	assign	shifted_data_right = A >> B[5:0];
	
	//module instantiation
	cla_64 cla_adder(
		.a(A),
		.b(b_input),
		.cin(cin),
		.sum(add_sub_result),
		.cout(cout),
		.cin_msb(cin_msb)
	);
	
	
	//logic
	always@(posedge clk) begin
		if (reset) begin
			Z <= 64'b0;
			overflow <= 0;
		end
		else begin
			Z <= result;
			overflow <= overflow_nxt;
		end
	end
	
	
	always@(*) begin
		case(aluctrl)
			4'b0000: 
			 begin 
			     result = add_sub_result;
			     overflow_nxt = cin_msb ^ cout;
			 end
			4'b0001: 
			 begin 
			     result = add_sub_result;
			     overflow_nxt = cin_msb ^ cout;
			 end
			4'b0010: result = A & B;
			4'b0011: result = A | B;
			4'b0100: result = ~(A ^ B);
			4'b0101: result = {63'b0, (A == B)};
			4'b0110: result = A << B[5:0];
			4'b0111: result = A >> B[5:0];
			4'b1000: result = {63'b0, (sub_a == sub_b)};
			4'b1001: result = {63'b0, (shifted_data_left == cmp_val)};
			4'b1010: result = {63'b0, (shifted_data_right == cmp_val)};
			default: result = 64'b0;
		endcase
	end
endmodule