module if_id(
    input clk, rst, pause, flush,
    input [63: 0] if_pc,
    input [31: 0] if_instr,
    input pipeline_en,

    output reg [63: 0] id_pc,
    output reg [31: 0] id_instr
);

/*always @(posedge clk) begin
    if(rst || flush) begin
        id_pc = 64'd0;
        id_instr = {12'h0, 5'b0, 3'b000, 5'b0, 7'b0010011}; //addi,x0,x0,0=> NOOP
    end else if(pause) begin
        // empty
    end else begin
        id_pc <= if_pc;
        id_instr <= if_instr;
    end
end*/

always @(posedge clk) begin
    if(rst || flush) begin
        id_pc <= 64'd0;
        id_instr <= {12'h0, 5'b0, 3'b000, 5'b0, 7'b0010011}; //addi,x0,x0,0=> NOOP
    end else if(pipeline_en) begin
          if(pause) begin
              // empty
          end else begin
            id_pc <= if_pc;
            id_instr <= if_instr;
          end
    end
end

endmodule