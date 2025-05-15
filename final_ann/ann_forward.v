module ann_forward #(
    parameter INPUT_SIZE = 256,
    parameter HIDDEN_SIZE = 3
)(
    input clk,
    input rst_n,
    input start,
    input [31:0] input_vec [0:INPUT_SIZE-1],  // 256-dimensional input, each is IEEE-754 single-precision float
    input [31:0] w1 [0:HIDDEN_SIZE-1][0:INPUT_SIZE-1],  // Weights for hidden layer
    input [31:0] b1 [0:HIDDEN_SIZE-1],                 // Biases for hidden layer
    input [31:0] w2 [0:HIDDEN_SIZE-1],                 // Weights for output layer
    input [31:0] b2,                                   // Bias for output layer
    output reg done,
    output reg [31:0] output_val  // Final logit output
);

    // State definition
    typedef enum logic [1:0] {
        IDLE,
        CALC_HIDDEN,
        CALC_OUTPUT,
        DONE
    } state_t;

    state_t state;
    integer i, j;
    reg [31:0] hidden [0:HIDDEN_SIZE-1];
    reg [31:0] acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            done <= 0;
            output_val <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        i <= 0;
                        state <= CALC_HIDDEN;
                    end
                end

                CALC_HIDDEN: begin
                    if (i < HIDDEN_SIZE) begin
                        acc = b1[i];
                        for (j = 0; j < INPUT_SIZE; j = j + 1) begin
                            acc = acc + w1[i][j] * input_vec[j];  // Floating-point multiply-accumulate (replace with hardware module)
                        end
                        hidden[i] = (acc > 0) ? acc : 32'd0;  // ReLU activation
                        i = i + 1;
                    end else begin
                        i <= 0;
                        acc <= b2;
                        state <= CALC_OUTPUT;
                    end
                end

                CALC_OUTPUT: begin
                    for (i = 0; i < HIDDEN_SIZE; i = i + 1) begin
                        acc = acc + w2[i] * hidden[i];  // Floating-point multiply-accumulate
                    end
                    output_val <= acc;
                    state <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
