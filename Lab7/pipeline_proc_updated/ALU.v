module ALU (
    input [63:0] a,
    input [63:0] b,
    input [2:0] op,
	 input sub,
	 input [1:0] branch,
    output reg [63:0] z,
    output reg zero,
    output reg uslt,
    output reg slt,
    output reg eq,
    output reg neq
);
    parameter ADD = 3'b000;
    parameter SUB = 3'b110;
    parameter AND = 3'b010;
    parameter OR  = 3'b011;
    parameter XNOR = 3'b100;
    parameter COMP = 3'b101;
    parameter SLL = 3'b001;
    parameter SRL = 3'b111;

    wire [64:0] sum; 
    wire [63:0] sub_b; 
    wire cin; 
    wire slt_internal; 

    assign cin = (op == SUB); 
    assign sub_b = (sub) ? ~b + 1'b1 : b; 
    assign sum = a + sub_b + cin; 
    assign slt_internal = sum[64] ^ sum[63];

    always @(*) begin
		if(branch == 2'b01) begin
			eq = (a == b);
		end
		else if (branch == 2'b10) begin
			uslt = a < b;
		end
		else
		begin
        case(op)
            ADD: z = sum[63:0];
            SUB: z = sum[63:0];
            AND: z = a & b;
            OR: z = a | b;
            XNOR: z = ~(a ^ b);
            COMP: begin
                eq = (a == b);
                neq = (a != b);
                slt = slt_internal;
                uslt = a < b; 
            end
            SLL: z = a << b; 
            SRL: z = a >> b; 
            default: z = 63'b0;
        endcase

        zero = (z == 0);
        if (op != COMP) begin 
            eq = 0;
            neq = 0;
            slt = 0;
            uslt = 0;
        end
		end
    end
endmodule
