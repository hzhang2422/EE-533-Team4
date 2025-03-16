`timescale 1ns/1ps

// This is a two input round robin bus arbiter (with enable signal)
module bus_arbiter (
	input req0,
	input req1,
	input clk, 
	input rst,
//	input enable,
	output gnt0,
	output gnt1
);
parameter GRANT0 = 1'b0;
parameter GRANT1 = 1'b1;

// The state determines which 'req' is granted. 
// State '0' grants req0 and state '1' grants req1.
reg gnt_state;
reg next_state;

//assign gnt0 = req0 && !gnt_state && enable;
//assign gnt1 = req1 && gnt_state && enable;
assign gnt0 = req0 && !gnt_state;
assign gnt1 = req1 && gnt_state;

// The next state logic implements round robin fairness
// for two inputs. When both reqs are asserted, we grant req0 first;

always @(*) begin
	case (gnt_state)
	GRANT0: begin
		if (req0) begin
			next_state = 0;
		end else if (req1) begin
			next_state = 1;
		end else begin
			next_state = 0;
		end
	end
	GRANT1: begin
		if (req1) begin
			next_state = 1;
		end else begin
			next_state = 0;
		end
	end
	endcase
end // always @(*)

// State registers with asynchronous reset
always @(posedge clk, posedge rst) begin
	if (rst) begin
		gnt_state <= 0;
	end else begin
		gnt_state <= next_state;
	end
end

endmodule
