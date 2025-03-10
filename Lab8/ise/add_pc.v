module add_pc(
//    input [31: 0] pc,
//    input [31: 0] imm32,
//    input [31: 0] rs1Data,
    input [63: 0] pc,
    input [63: 0] imm64,
    input [63: 0] rs1Data,

//    output reg [31: 0] pcImm,
//    output reg [31: 0] rs1Imm
    output reg [63: 0] pcImm,
    output reg [63: 0] rs1Imm
);

always @(*) begin
    pcImm = pc + imm64;
    rs1Imm = rs1Data + imm64;
end
endmodule