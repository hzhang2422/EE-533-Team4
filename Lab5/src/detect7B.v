////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : detect7B.vf
// /___/   /\     Timestamp : 01/31/2025 19:37:05
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w C:/yzhou477/lab3_beta/detect7B.sch detect7B.vf
//Design Name: detect7B
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module detect7B(ce, 
                clk, 
                hwregA, 
                match_en, 
                mrst, 
                pipe1, 
                match);

    input ce;
    input clk;
    input [63:0] hwregA;
    input match_en;
    input mrst;
    input [71:0] pipe1;
   output match;
   
   wire [71:0] pipe0;
   wire XLXN_12;
   wire XLXN_17;
   wire XLXN_27;
   wire [111:0] XLXN_36;
   wire match_DUMMY;
   
   assign match = match_DUMMY;
   reg9B XLXI_3 (.ce(clk), 
                 .clk(ce), 
                 .clr(XLXN_17), 
                 .d(pipe1[71:0]), 
                 .q(pipe0[71:0]));
   wordmatch XLXI_4 (.datacomp(hwregA[55:0]), 
                     .datain(XLXN_36[111:0]), 
                     .wildcard(hwregA[62:56]), 
                     .match(XLXN_27));
   AND3B1 XLXI_5 (.I0(match_DUMMY), 
                  .I1(match_en), 
                  .I2(XLXN_27), 
                  .O(XLXN_12));
   FD XLXI_6 (.C(clk), 
              .D(mrst), 
              .Q(XLXN_17));
   defparam XLXI_6.INIT = 1'b0;
   FDCE XLXI_7 (.C(clk), 
                .CE(XLXN_12), 
                .CLR(XLXN_17), 
                .D(XLXN_12), 
                .Q(match_DUMMY));
   defparam XLXI_7.INIT = 1'b0;
   busmerge XLXI_8 (.da(pipe0[47:0]), 
                    .db(pipe1[63:0]), 
                    .q(XLXN_36[111:0]));
endmodule
