module data_mem(
    input clk, rst, 
    input [1: 0] write_mem, 
    input [2: 0] read_mem,

    input [31: 0] address, write_data,

    output reg [31: 0] out_mem
);

reg [7: 0] data [127: 0];

wire [31:0] data_word0 = {data[3], data[2], data[1], data[0]};
wire [31:0] data_word1 = {data[7], data[6], data[5], data[4]};
wire [31:0] data_word2 = {data[11], data[10], data[9], data[8]};
wire [31:0] data_word3 = {data[15], data[14], data[13], data[12]};
wire [31:0] data_word4 = {data[19], data[18], data[17], data[16]};
wire [31:0] data_word5 = {data[23], data[22], data[21], data[20]};
wire [31:0] data_word6 = {data[27], data[26], data[25], data[24]};
wire [31:0] data_word7 = {data[31], data[30], data[29], data[28]};
wire [31:0] data_word8 = {data[35], data[34], data[33], data[32]};
wire [31:0] data_word9 = {data[39], data[38], data[37], data[36]};
//wire [31:0] data_word10 = {data[43], data[42], data[41], data[40]};
// wire [31:0] data_word0 = {data[3], data[2], data[1], data[0]};

always @(*) begin
    case (read_mem[1: 0])
        2'b00:begin
            out_mem = 32'b0;
        end
        2'b01:begin
            out_mem = {data[address + 3], data[address + 2], data[address + 1], data[address]};
        end
        2'b10:begin
            if(read_mem[2]) out_mem = {{16{data[address + 1][7]}}, data[address + 1], data[address]};
            else out_mem = {16'b0, data[address + 1], data[address]};
        end
        2'b11:begin
            if(read_mem[2]) out_mem = {{24{data[address][7]}}, data[address]};
            else out_mem = {24'b0, data[address]};
        end 
        default:begin
            out_mem = 32'b0;
        end
    endcase
end

always @(posedge clk) begin
    case (write_mem)
        2'b01:begin
            data[address + 3] = write_data[31: 24];
            data[address + 2] = write_data[23: 16];
            data[address + 1] = write_data[15: 8];
            data[address] = write_data[7: 0];
        end
        2'b10:begin
            data[address + 1] = write_data[15: 8];
            data[address] = write_data[7: 0];
        end
        2'b11:begin
            data[address] = write_data[7: 0];
        end 
        default: begin
            
        end
    endcase
end

initial begin
    // 1. 数字 323 (0x00000143) - 存储在 data[0]~data[3]
    data[0]  = 8'h43;  // 低字节
    data[1]  = 8'h01;
    data[2]  = 8'h00;
    data[3]  = 8'h00;  // 高字节
    
    // 2. 数字 123 (0x0000007B) - 存储在 data[4]~data[7]
    data[4]  = 8'h7B;
    data[5]  = 8'h00;
    data[6]  = 8'h00;
    data[7]  = 8'h00;
    
    // 3. 数字 -455 (0xFFFFFE39) - 存储在 data[8]~data[11]
    data[8]  = 8'h39;
    data[9]  = 8'hFE;
    data[10] = 8'hFF;
    data[11] = 8'hFF;
    
    // 4. 数字 2 (0x00000002) - 存储在 data[12]~data[15]
    data[12] = 8'h02;
    data[13] = 8'h00;
    data[14] = 8'h00;
    data[15] = 8'h00;
    
    // 5. 数字 98 (0x00000062) - 存储在 data[16]~data[19]
    data[16] = 8'h62;
    data[17] = 8'h00;
    data[18] = 8'h00;
    data[19] = 8'h00;
    
    // 6. 数字 125 (0x0000007D) - 存储在 data[20]~data[23]
    data[20] = 8'h7D;
    data[21] = 8'h00;
    data[22] = 8'h00;
    data[23] = 8'h00;
    
    // 7. 数字 10 (0x0000000A) - 存储在 data[24]~data[27]
    data[24] = 8'h0A;
    data[25] = 8'h00;
    data[26] = 8'h00;
    data[27] = 8'h00;
    
    // 8. 数字 65 (0x00000041) - 存储在 data[28]~data[31]
    data[28] = 8'h41;
    data[29] = 8'h00;
    data[30] = 8'h00;
    data[31] = 8'h00;
    
    // 9. 数字 -56 (0xFFFFFFC8) - 存储在 data[32]~data[35]
    data[32] = 8'hC8;
    data[33] = 8'hFF;
    data[34] = 8'hFF;
    data[35] = 8'hFF;
    
    // 10. 数字 0 (0x00000000) - 存储在 data[36]~data[39]
    data[36] = 8'h00;
    data[37] = 8'h00;
    data[38] = 8'h00;
    data[39] = 8'h00;
end
endmodule