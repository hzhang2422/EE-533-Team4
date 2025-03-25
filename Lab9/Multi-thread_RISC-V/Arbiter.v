module Arbiter(
    input				clk,
    input 				rst,
    input		[3:0]   req,
    output reg	[1:0]	ts_threadID
);
    reg [3:0] grant;
    reg [1:0] pointer;
    wire [3:0] mask;
    wire [3:0] masked_req;
    wire [3:0] grant_raw;

    always @(posedge clk or posedge rst) begin
        if(rst)
            pointer <= 0;
        else if 
            (|req)  pointer <= pointer + 1;
    end

    assign mask = (1'b1 << pointer) - 1;

    assign masked_req = req & ~mask;

    assign grant_raw = masked_req ? masked_req & -masked_req : req & -req;

    always @(posedge clk or posedge rst) begin
        if (rst)
            grant <= 0;
        else
            grant <= grant_raw;
    end


    always @(*) begin
    case (grant)
        4'b0001: ts_threadID = 2'b00;
        4'b0010: ts_threadID = 2'b01;
        4'b0100: ts_threadID = 2'b10;
        4'b1000: ts_threadID = 2'b11;
        default: ts_threadID = 2'b00; 
    endcase
    end


endmodule
