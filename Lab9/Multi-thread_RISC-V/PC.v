module PC (
	input				clk,
	input				rst,
	input				stall,
	input		[31:0]	pc_next,
	output	reg	[31:0]	pc
);

	always @(posedge clk or posedge rst) begin
		if (rst)
			pc <= 32'h0000_0000;
		else if (stall == 1'b0)
			pc <= pc_next;
	end
endmodule