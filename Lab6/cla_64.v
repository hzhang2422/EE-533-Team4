`timescale 1ns / 1ps

module cla_64(
	input	[63:0]	a,
	input	[63:0]	b,
	input 			cin,
	output	[63:0]	sum,
	output			cout,
	output          cin_msb
	);
	
	wire c4, c8, c12, c16, c20, c24, c28, c32, c36, c40, c44, c48, c52, c56, c60;
	
	cla_4 cla0 	(.a(a[3:0]),	.b(b[3:0]),		.cin(cin), 	.sum(sum[3:0]),		.cout(c4));
	cla_4 cla1 	(.a(a[7:4]), 	.b(b[7:4]),		.cin(c4) , 	.sum(sum[7:4]),		.cout(c8));
	cla_4 cla2 	(.a(a[11:8]), 	.b(b[11:8]),	.cin(c8) , 	.sum(sum[11:8]),	.cout(c12));
	cla_4 cla3 	(.a(a[15:12]), 	.b(b[15:12]),	.cin(c12) , .sum(sum[15:12]),	.cout(c16));
	cla_4 cla4 	(.a(a[19:16]), 	.b(b[19:16]), 	.cin(c16) , .sum(sum[19:16]), 	.cout(c20));
	cla_4 cla5 	(.a(a[23:20]), 	.b(b[23:20]), 	.cin(c20) , .sum(sum[23:20]), 	.cout(c24));
	cla_4 cla6 	(.a(a[27:24]), 	.b(b[27:24]), 	.cin(c24) , .sum(sum[27:24]), 	.cout(c28));
	cla_4 cla7 	(.a(a[31:28]), 	.b(b[31:28]), 	.cin(c28) , .sum(sum[31:28]),	.cout(c32));
	cla_4 cla8 	(.a(a[35:32]), 	.b(b[35:32]), 	.cin(c32) , .sum(sum[35:32]), 	.cout(c36));
	cla_4 cla9 	(.a(a[39:36]), 	.b(b[39:36]), 	.cin(c36) , .sum(sum[39:36]), 	.cout(c40));
	cla_4 cla10 (.a(a[43:40]), 	.b(b[43:40]), 	.cin(c40) , .sum(sum[43:40]), 	.cout(c44));
	cla_4 cla11 (.a(a[47:44]), 	.b(b[47:44]), 	.cin(c44) , .sum(sum[47:44]), 	.cout(c48));
	cla_4 cla12 (.a(a[51:48]), 	.b(b[51:48]), 	.cin(c48) , .sum(sum[51:48]), 	.cout(c52));
	cla_4 cla13 (.a(a[55:52]), 	.b(b[55:52]), 	.cin(c52) , .sum(sum[55:52]), 	.cout(c56));
	cla_4 cla14 (.a(a[59:56]), 	.b(b[59:56]), 	.cin(c56) , .sum(sum[59:56]),	.cout(c60));
	cla_4 cla15 (.a(a[63:60]), 	.b(b[63:60]), 	.cin(c60) , .sum(sum[63:60]), 	.cout(cout));
	
	assign cin_msb = c60;
endmodule