`timescale 1ns / 1ps

module cla_4(
    input	[3:0]	a,
	input	[3:0]	b,
	input			cin,
	output	[3:0]	sum,
	output			cout
	);
	
	wire	[3:0]	p; //propagate
	wire	[3:0]	g; //generate
	wire	c1, c2, c3, c4;
	
	assign	p = a ^ b;
	assign	g = a & b;
	
	assign	c1 = g[0] | (p[0] & cin);
	assign	c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin);
	assign	c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin);
	assign	c4 = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & cin);
	
	assign  sum = p ^ {c3, c2, c1, cin};
	assign  cout = c4;
endmodule
	