`timescale 1ns/1ps

module Multi_thread(
   input clk,
   input reset,
   input [2:0] mode,
   output [1:0] thread_num_out,
   output [8:0] pc0_out,
   output [8:0] pc1_out,
   output [8:0] pc2_out,
   output [8:0] pc3_out,
   output regfile_wena0,
   output regfile_wena1,
   output regfile_wena2,
   output regfile_wena3,
   output done
);
reg [1:0] t;
reg [8:0] p0,p1,p2,p3;
reg d;
reg [5:0] cnt;
assign thread_num_out = t;
assign pc0_out        = p0;
assign pc1_out        = p1;
assign pc2_out        = p2;
assign pc3_out        = p3;
assign regfile_wena0  = (t==2'b00);
assign regfile_wena1  = (t==2'b01);
assign regfile_wena2  = (t==2'b10);
assign regfile_wena3  = (t==2'b11);
assign done           = d;
always @(posedge clk) begin
   if(reset) begin
      t   <= 0;
      p0  <= 0;
      p1  <= 0;
      p2  <= 0;
      p3  <= 0;
      d   <= 0;
      cnt <= 0;
   end else begin
      cnt <= cnt + 1;
      case(t)
         2'b00: p0 <= p0 + 1;
         2'b01: p1 <= p1 + 1;
         2'b10: p2 <= p2 + 1;
         2'b11: p3 <= p3 + 1;
      endcase
      if(cnt==6'd15) d <= 1;
      t <= t + 1;
   end
end
endmodule

module tb;
reg clk;
reg reset;
reg [2:0] mode;
wire [1:0] thread_num;
wire [8:0] pc0, pc1, pc2, pc3;
wire w0, w1, w2, w3;
wire dn;
Multi_thread dut(
 .clk(clk),
 .reset(reset),
 .mode(mode),
 .thread_num_out(thread_num),
 .pc0_out(pc0),
 .pc1_out(pc1),
 .pc2_out(pc2),
 .pc3_out(pc3),
 .regfile_wena0(w0),
 .regfile_wena1(w1),
 .regfile_wena2(w2),
 .regfile_wena3(w3),
 .done(dn)
);
initial begin
 clk = 0; forever #5 clk = ~clk;
end
initial begin
 $dumpfile("tb.vcd");
 $dumpvars(0,tb);
 reset = 1;
 mode  = 3'b000;
 #20;
 reset = 0;
 #50;
 mode = 3'b100;
 #500;
 $finish;
end
initial begin
 $monitor("%t clk=%b rst=%b mode=%b thr=%d pc0=%d pc1=%d pc2=%d pc3=%d w0=%b w1=%b w2=%b w3=%b done=%b",
  $time, clk, reset, mode, thread_num, pc0, pc1, pc2, pc3, w0, w1, w2, w3, dn);
end
endmodule
