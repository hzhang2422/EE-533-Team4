////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 10.1
//  \   \         Application : sch2verilog
//  /   /         Filename : comparator.vf
// /___/   /\     Timestamp : 01/31/2025 11:12:18
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: C:\Xilinx\10.1\ISE\bin\nt\unwrapped\sch2verilog.exe -intstyle ise -family virtex2p -w "C:/Documents and Settings/student/lab3_sch/comparator.sch" comparator.vf
//Design Name: comparator
//Device: virtex2p
//Purpose:
//    This verilog netlist is translated from an ECS schematic.It can be 
//    synthesized and simulated, but it should not be modified. 
//
`timescale 1ns / 1ps

module COMP8_MXILINX_comparator(A, 
                                B, 
                                EQ);

    input [7:0] A;
    input [7:0] B;
   output EQ;
   
   wire AB0;
   wire AB1;
   wire AB2;
   wire AB3;
   wire AB4;
   wire AB5;
   wire AB6;
   wire AB7;
   wire AB03;
   wire AB47;
   
   AND4 I_36_32 (.I0(AB7), 
                 .I1(AB6), 
                 .I2(AB5), 
                 .I3(AB4), 
                 .O(AB47));
   XNOR2 I_36_33 (.I0(B[6]), 
                  .I1(A[6]), 
                  .O(AB6));
   XNOR2 I_36_34 (.I0(B[7]), 
                  .I1(A[7]), 
                  .O(AB7));
   XNOR2 I_36_35 (.I0(B[5]), 
                  .I1(A[5]), 
                  .O(AB5));
   XNOR2 I_36_36 (.I0(B[4]), 
                  .I1(A[4]), 
                  .O(AB4));
   AND4 I_36_41 (.I0(AB3), 
                 .I1(AB2), 
                 .I2(AB1), 
                 .I3(AB0), 
                 .O(AB03));
   XNOR2 I_36_42 (.I0(B[2]), 
                  .I1(A[2]), 
                  .O(AB2));
   XNOR2 I_36_43 (.I0(B[3]), 
                  .I1(A[3]), 
                  .O(AB3));
   XNOR2 I_36_44 (.I0(B[1]), 
                  .I1(A[1]), 
                  .O(AB1));
   XNOR2 I_36_45 (.I0(B[0]), 
                  .I1(A[0]), 
                  .O(AB0));
   AND2 I_36_50 (.I0(AB47), 
                 .I1(AB03), 
                 .O(EQ));
endmodule
`timescale 1ns / 1ps

module AND7_MXILINX_comparator(I0, 
                               I1, 
                               I2, 
                               I3, 
                               I4, 
                               I5, 
                               I6, 
                               O);

    input I0;
    input I1;
    input I2;
    input I3;
    input I4;
    input I5;
    input I6;
   output O;
   
   wire I36;
   wire O_DUMMY;
   
   assign O = O_DUMMY;
   AND4 I_36_69 (.I0(I3), 
                 .I1(I4), 
                 .I2(I5), 
                 .I3(I6), 
                 .O(I36));
   AND4 I_36_85 (.I0(I0), 
                 .I1(I1), 
                 .I2(I2), 
                 .I3(I36), 
                 .O(O_DUMMY));
   FMAP I_36_98 (.I1(I0), 
                 .I2(I1), 
                 .I3(I2), 
                 .I4(I36), 
                 .O(O_DUMMY));
   // synthesis attribute RLOC of I_36_98 is "X0Y0"
   FMAP I_36_110 (.I1(I3), 
                  .I2(I4), 
                  .I3(I5), 
                  .I4(I6), 
                  .O(I36));
   // synthesis attribute RLOC of I_36_110 is "X0Y0"
endmodule
`timescale 1ns / 1ps

module comparator(a, 
                  amask, 
                  b, 
                  match);

    input [55:0] a;
    input [6:0] amask;
    input [55:0] b;
   output match;
   
   wire XLXN_1;
   wire XLXN_2;
   wire XLXN_4;
   wire XLXN_5;
   wire XLXN_6;
   wire XLXN_7;
   wire XLXN_14;
   wire XLXN_82;
   wire XLXN_83;
   wire XLXN_84;
   wire XLXN_85;
   wire XLXN_86;
   wire XLXN_87;
   wire XLXN_88;
   
   COMP8_MXILINX_comparator XLXI_1 (.A(a[55:48]), 
                                    .B(b[55:48]), 
                                    .EQ(XLXN_1));
   // synthesis attribute HU_SET of XLXI_1 is "XLXI_1_6"
   COMP8_MXILINX_comparator XLXI_2 (.A(a[47:40]), 
                                    .B(b[47:40]), 
                                    .EQ(XLXN_2));
   // synthesis attribute HU_SET of XLXI_2 is "XLXI_2_3"
   COMP8_MXILINX_comparator XLXI_3 (.A(a[39:32]), 
                                    .B(b[39:32]), 
                                    .EQ(XLXN_4));
   // synthesis attribute HU_SET of XLXI_3 is "XLXI_3_4"
   COMP8_MXILINX_comparator XLXI_4 (.A(a[31:24]), 
                                    .B(b[31:24]), 
                                    .EQ(XLXN_5));
   // synthesis attribute HU_SET of XLXI_4 is "XLXI_4_5"
   COMP8_MXILINX_comparator XLXI_5 (.A(a[23:16]), 
                                    .B(b[23:16]), 
                                    .EQ(XLXN_6));
   // synthesis attribute HU_SET of XLXI_5 is "XLXI_5_1"
   COMP8_MXILINX_comparator XLXI_6 (.A(a[15:8]), 
                                    .B(b[15:8]), 
                                    .EQ(XLXN_7));
   // synthesis attribute HU_SET of XLXI_6 is "XLXI_6_7"
   COMP8_MXILINX_comparator XLXI_7 (.A(a[7:0]), 
                                    .B(b[7:0]), 
                                    .EQ(XLXN_14));
   // synthesis attribute HU_SET of XLXI_7 is "XLXI_7_0"
   OR2B1 XLXI_8 (.I0(amask[6]), 
                 .I1(XLXN_1), 
                 .O(XLXN_83));
   OR2B1 XLXI_9 (.I0(amask[5]), 
                 .I1(XLXN_2), 
                 .O(XLXN_85));
   OR2B1 XLXI_10 (.I0(amask[4]), 
                  .I1(XLXN_4), 
                  .O(XLXN_86));
   OR2B1 XLXI_11 (.I0(amask[3]), 
                  .I1(XLXN_5), 
                  .O(XLXN_88));
   OR2B1 XLXI_12 (.I0(amask[2]), 
                  .I1(XLXN_6), 
                  .O(XLXN_84));
   OR2B1 XLXI_13 (.I0(amask[1]), 
                  .I1(XLXN_7), 
                  .O(XLXN_82));
   OR2B1 XLXI_14 (.I0(amask[0]), 
                  .I1(XLXN_14), 
                  .O(XLXN_87));
   AND7_MXILINX_comparator XLXI_35 (.I0(XLXN_88), 
                                    .I1(XLXN_87), 
                                    .I2(XLXN_86), 
                                    .I3(XLXN_82), 
                                    .I4(XLXN_85), 
                                    .I5(XLXN_84), 
                                    .I6(XLXN_83), 
                                    .O(match));
   // synthesis attribute HU_SET of XLXI_35 is "XLXI_35_2"
endmodule
