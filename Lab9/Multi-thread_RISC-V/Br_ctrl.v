`include "constants.vh"

module Br_ctrl (
	input		[`DATA_WIDTH-1:0]	rs1,
	input		[`DATA_WIDTH-1:0]	rs2,
	input		[2:0]				func3,
	
	output	reg						Br_ctrl
);

	always @(*) begin
    case (func3)
        3'b000: Br_ctrl = (rs1 == rs2);  // BEQ
        3'b001: Br_ctrl = (rs1 != rs2);  // BNE
        3'b100: Br_ctrl = ($signed(rs1) < $signed(rs2));  // BLT
        3'b101: Br_ctrl = ($signed(rs1) >= $signed(rs2));  // BGE
        3'b110: Br_ctrl = (rs1 < rs2);  // BLTU
        3'b111: Br_ctrl = (rs1 >= rs2);  // BGEU
        default: Br_ctrl = 0;
    endcase
end

endmodule