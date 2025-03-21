module reg_file(
    input rst, clk, write_reg,
    input [4: 0] rs1, rs2, target_reg,
    input [63: 0] write_rd_data,

    output reg [63: 0] read_rs1_data,
    output reg [63: 0] read_rs2_data
);

reg [63: 0] regs[31: 0];

always @(posedge clk) begin
    if(write_reg && target_reg != 5'h0) regs[target_reg] = write_rd_data;
end

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        regs[i] = 64'd0;
    end
    regs[5'd2] = 64'd128;
    
end

always @(rs1 or target_reg or write_reg or write_rd_data) begin
    if(rs1 == 5'h0)begin
        read_rs1_data = 64'h0000_0000;
    end else begin
        if(rs1 == target_reg && write_reg)begin
            read_rs1_data = write_rd_data;
        end else begin
            read_rs1_data = regs[rs1];
        end
    end
end

always @(rs2 or target_reg or write_reg or write_rd_data) begin
    if(rs2 == 5'h0)begin
        read_rs2_data = 64'h0000_0000;
    end else begin
        if(rs2 == target_reg && write_reg)begin
            read_rs2_data = write_rd_data;
        end else begin
            read_rs2_data = regs[rs2];
        end
    end
end

endmodule