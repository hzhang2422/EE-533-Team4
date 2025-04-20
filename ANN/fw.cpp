#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cmath>
using half = float;  // Simulate fp16 with float

inline half half_relu(half x)
{
    return (x > 0.0f) ? x : 0.0f;
}

int main()
{
    const int INPUT_SIZE = 13;   // 3 protocol + 4 src_ip + 4 dst_ip + 2 ports
    const int HIDDEN_SIZE = 3;
    const int OUTPUT_SIZE = 2;  // normal / malicious

    // Read input sample (13 float values)
    half input[INPUT_SIZE];
    std::cout << "Enter 13 input features (protocol[3], src_ip[4], dst_ip[4], src_port, dst_port):\n";
    for (int i = 0; i < INPUT_SIZE; ++i) {
        std::cin >> input[i];
    }

    // Read hidden layer weights (3x13)
    half hidden_weights[HIDDEN_SIZE][INPUT_SIZE];
    std::ifstream hw_file("hidden_weights.txt");
    if (!hw_file) {
        std::cerr << "Could not open hidden_weights.txt" << std::endl;
        return 1;
    }
    for (int h = 0; h < HIDDEN_SIZE; ++h) {
        for (int i = 0; i < INPUT_SIZE; ++i) {
            hw_file >> hidden_weights[h][i];
        }
    }
    hw_file.close();

    // Read output layer weights (2x3)
    half output_weights[OUTPUT_SIZE][HIDDEN_SIZE];
    std::ifstream ow_file("output_weights.txt");
    if (!ow_file) {
        std::cerr << "Could not open output_weights.txt" << std::endl;
        return 1;
    }
    for (int o = 0; o < OUTPUT_SIZE; ++o) {
        for (int h = 0; h < HIDDEN_SIZE; ++h) {
            ow_file >> output_weights[o][h];
        }
    }
    ow_file.close();

    // Forward pass - hidden layer
    half hidden[HIDDEN_SIZE];
    for (int h = 0; h < HIDDEN_SIZE; ++h) {
        float sum = 0.0f;
        for (int i = 0; i < INPUT_SIZE; ++i) {
            sum += hidden_weights[h][i] * input[i];
        }
        hidden[h] = half_relu(sum);
    }

    // Forward pass - output layer
    half output[OUTPUT_SIZE];
    for (int o = 0; o < OUTPUT_SIZE; ++o) {
        float sum = 0.0f;
        for (int h = 0; h < HIDDEN_SIZE; ++h) {
            sum += output_weights[o][h] * hidden[h];
        }
        output[o] = sum;
    }

    // Predict class (argmax)
    int predicted = (output[1] > output[0]) ? 1 : 0;
    std::cout << "Predicted: " << (predicted == 1 ? "Malicious" : "Normal") << std::endl;

    return 0;
}
