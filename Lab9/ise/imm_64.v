module imm_64(
    input [31: 0] instr,
    input [2: 0] extOP,

    output reg [63: 0] imm_64
);

always @(*) begin
    case (extOP)
        //jalr/Load/I-type
        3'b000:begin
            imm_64 = {{52{instr[31]}}, instr[31:20]};
        end
        //lui/auipc
        3'b001:begin
            imm_64 = {{32{instr[31]}},instr[31:12], 12'b0};
        end
        //s-type
        3'b010:begin
            imm_64 = {{52{instr[31]}}, instr[31:25], instr[11:7]};
        end
        //Branch
        3'b011:begin
            imm_64 = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        end
        //jal
        3'b100:begin
            imm_64 = {{42{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        end
        3'b101:begin
            imm_64 = {{52{instr[31]}}, instr[31:20]};
            imm_64[10] = 0;
        end
        //R-type
        3'b111:begin
            imm_64 = 64'b0;
        end 
        default:begin
            
        end 
    endcase
end
endmodule