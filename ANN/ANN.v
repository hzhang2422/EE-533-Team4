// ann_module.v
// Feedforward ANN: 13 inputs -> 3 hidden neurons (ReLU) -> 2 outputs

module ann_module(
    input clk,
    input rst,
    input [15:0] in_data[12:0],  // 13 fp16 input features
    input [15:0] hidden_w[2:0][12:0], // 3 neurons x 13 weights
    input [15:0] output_w[1:0][2:0], // 2 output neurons x 3 hidden
    output reg [15:0] out_data[1:0], // raw output logits
    output reg predicted_class        // 1 = malicious, 0 = normal
);

    // Internal accumulators
    reg [31:0] hidden_sum[2:0];
    reg [15:0] hidden_out[2:0];
    reg [31:0] output_sum[1:0];

    integer i, j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 3; i = i + 1) begin
                hidden_sum[i] <= 0;
                hidden_out[i] <= 0;
            end
            for (j = 0; j < 2; j = j + 1) begin
                output_sum[j] <= 0;
                out_data[j] <= 0;
            end
            predicted_class <= 0;
        end else begin
            // Compute hidden layer
            for (i = 0; i < 3; i = i + 1) begin
                hidden_sum[i] = 0;
                for (j = 0; j < 13; j = j + 1) begin
                    // Simplified as binary input (0/1), emulate MUX behavior
                    if (in_data[j] != 0)
                        hidden_sum[i] = hidden_sum[i] + hidden_w[i][j];
                end
                // ReLU
                hidden_out[i] = (hidden_sum[i][31] == 1) ? 16'd0 : hidden_sum[i][15:0];
            end

            // Compute output layer
            for (i = 0; i < 2; i = i + 1) begin
                output_sum[i] = 0;
                for (j = 0; j < 3; j = j + 1) begin
                    output_sum[i] = output_sum[i] + hidden_out[j] * output_w[i][j];
                end
                out_data[i] = output_sum[i][15:0];
            end

            // Classification
            predicted_class = (output_sum[1] > output_sum[0]) ? 1'b1 : 1'b0;
        end
    end

endmodule