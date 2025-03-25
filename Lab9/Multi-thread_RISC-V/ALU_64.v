`include "constants.vh"

module ALU_64(
	input		[`DATA_WIDTH-1:0]	A,
	input		[`DATA_WIDTH-1:0]	B,
	input		[3:0]				Alu_Ctrl,
	
	output 	reg	[`DATA_WIDTH-1:0]	Z
);
	
	localparam ADD = 4'b0001;
	localparam SUB = 4'b0010;
	localparam AND = 4'b0011;
	localparam OR = 4'b0100;
	localparam XOR = 4'b0101;
	localparam SLL = 4'b0110; // shift left logically
	localparam SLT = 4'b0111; // signed less than
	localparam SLTU = 4'b1000; // unsigned less than
	localparam SRL = 4'b1001; // shift right logically
	localparam SRA = 4'b1010; // shift right arithmatical
	localparam EQ = 4'b1011;

	wire	[`DATA_WIDTH-1:0]	B_invert; // 'substract enable'
	
	assign	B_invert = (Alu_Ctrl == 4'b0010) ? ~B+1'b1 : B;

	
	always@(*) begin
		case(Alu_Ctrl)
			4'b0001:	Z = A + B_invert;
			4'b0010:	Z = A + B_invert;
			4'b0011:	Z = A & B;
			4'b0100:	Z = A | B;
			4'b0101:	Z = A ^ B;
			4'b0110:	Z = A << B[5:0];
			4'b0111:	Z = $signed(A)<$signed(B) ? 64'b1 : 64'b0;
			4'b1000:	Z = A < B ? 64'b1 : 64'b0;
			4'b1001:	Z = A >> B[5:0];
			4'b1010:	Z = $signed(A) >>> B[5:0];
			default:	Z = 64'b0;
		endcase
	end
endmodule