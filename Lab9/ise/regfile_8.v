`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// vim:set shiftwidth=3 softtabstop=3 expandtab:
// $Id: module_template 2008-03-13 gac1 $
//
// Module: regfile.v
// Update: 3/31/2016
///////////////////////////////////////////////////////////////////////////////

module regfile8(
	input [3:0] r0addr,
	input [3:0] r1addr,
	
    input [71:0] wdata,
	//*************
	input read_en,
	//*************
	
    input wena,
    input [3:0] waddr,
	input CLK,
	
	input reset,
	
    output reg [71:0] r0data,
    output reg [71:0] r1data
    );
	
	reg [71:0] R0;
	reg [71:0] R1;
	reg [71:0] R2;
	reg [71:0] R3;
	reg [71:0] R4;
	reg [71:0] R5;
	reg [71:0] R6;
	reg [71:0] R7;
	always @(posedge CLK) begin
		
		if (reset)
		begin   /*******Modified*******/
			R0 <= 0;
			R1 <= 0;
			R2 <= 0;
			R3 <= 0;
			R4 <= 0;
			R5 <= 0;
			R6 <= 0;
			R7 <= 0;
		end
		else
		begin			
			if (wena)
			begin
				case(waddr)
					4'b0000: 
						begin
							R0 <= 72'b0;
						end
					4'b0001: 
						begin
							R1 <= wdata;
						end
					4'b0010:
						begin
							R2 <= wdata;
						end
					4'b0011: 
						begin
							R3 <= wdata;
						end
					4'b0100:
						begin
							R4 <= wdata;
						end
					4'b0101:
						begin
							R5 <= wdata;
						end
					4'b0110:
						begin
							R6 <= wdata;
						end
					4'b0111:
						begin
							R7 <= wdata;
						end
					default:
					    begin
						    R0 <= 72'b0;
							R1 <= 72'bX;
							R2 <= 72'bX;
							R3 <= 72'bX;
							R4 <= 72'bX;
							R5 <= 72'bX;
							R6 <= 72'bX;
							R7 <= 72'bX;
						end
				endcase
			end
		end
	end // always
	
	always @(*) begin
			if (read_en) begin
				case(r0addr)
				4'b0000:  
					begin
						r0data = R0;
					end
				4'b0001: 
					begin
						r0data = R1;
					end
				4'b0010:
					begin
						r0data = R2;
					end
				4'b0011: 
					begin
						r0data = R3;
					end
				4'b0100:
					begin
						r0data = R4;
					end
				4'b0101:
					begin
						r0data = R5;
					end
				4'b0110:
					begin
						r0data = R6;
					end
				4'b0111:
					begin
						r0data = R7;
					end
			    default:
				    begin
					    r0data = 72'bX;
					end
			endcase
			
			case(r1addr)
				4'b0000:  
					begin
						r1data = R0;
					end
				4'b0001: 
					begin
						r1data = R1;
					end
				4'b0010:
					begin
						r1data = R2;
					end
				4'b0011: 
					begin
						r1data = R3;
					end
				4'b0100:
					begin
						r1data = R4;
					end
				4'b0101:
					begin
						r1data = R5;
					end
				4'b0110:
					begin
						r1data = R6;
					end
				4'b0111:
					begin
						r1data = R7;
					end
				default:
				    begin
					    r1data = 72'bX;
					end
			endcase
	
		end else begin
			r0data = 72'bX;
			r1data = 72'bX;
		end
	end
	 
endmodule