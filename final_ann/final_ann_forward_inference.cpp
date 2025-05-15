#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cstdint>
#include <cmath>
#include <iomanip>
#include <cstring>
#include <openssl/md5.h>
#include <functional>

#include "murmurhash3.h"  // Ensure this implementation is included

const int INPUT_SIZE = 256;
const int HIDDEN_SIZE = 3;
const int OUTPUT_SIZE = 1;
const int NGRAM_SIZE = 8;

int hash_ngram_to_bin(const std::string &ngram) {
    uint32_t hash_val = murmurhash3_32(ngram.data(), ngram.size());
    return static_cast<int>(hash_val % 256);  // Map to [0, 255]
}

// Generate a 256-dimensional feature vector from 5-tuple + payload
std::vector<float> extract_features(const std::string &src_ip, const std::string &dst_ip,
                                    int src_port, int dst_port, int protocol,
                                    const std::string &payload_hex) {
    std::vector<float> histogram(INPUT_SIZE, 0.0f);
    std::ostringstream oss;
    oss << src_ip << "," << dst_ip << "," << src_port << "," << dst_port << "," << protocol;
    std::string header = oss.str();

    std::string payload;
    for (size_t i = 0; i < payload_hex.size(); i += 2) {
        std::string byte_str = payload_hex.substr(i, 2);
        char byte = static_cast<char>(std::stoi(byte_str, nullptr, 16));
        payload.push_back(byte);
    }

    std::string data = header + payload;
    if (data.size() < NGRAM_SIZE) data += std::string(NGRAM_SIZE - data.size(), 0);

    for (size_t i = 0; i + NGRAM_SIZE <= data.size(); ++i) {
        std::string ngram = data.substr(i, NGRAM_SIZE);
        int bin = hash_ngram_to_bin(ngram);
        histogram[bin] += 1.0f;
    }

    float total = 0;
    for (float v : histogram) total += v;
    if (total > 0) for (float &v : histogram) v /= total;

    return histogram;
}

// Load model weights
std::vector<std::vector<float>> load_weights(const std::string &filename, int rows, int cols) {
    std::ifstream file(filename);
    std::vector<std::vector<float>> weights(rows, std::vector<float>(cols));
    for (int i = 0; i < rows; ++i)
        for (int j = 0; j < cols; ++j)
            file >> weights[i][j];
    return weights;
}

std::vector<float> load_vector(const std::string &filename, int size) {
    std::ifstream file(filename);
    std::vector<float> vec(size);
    for (int i = 0; i < size; ++i)
        file >> vec[i];
    return vec;
}

int main() {
    std::string line;
    std::cout << "Input format: src_ip,dst_ip,src_port,dst_port,protocol,payload_hex\n";
    std::cout << "Please enter: ";
    std::getline(std::cin, line);

    std::stringstream ss(line);
    std::string src_ip, dst_ip, src_port_str, dst_port_str, protocol_str, payload_hex;

    // Read comma-separated fields
    if (!std::getline(ss, src_ip, ',') ||
        !std::getline(ss, dst_ip, ',') ||
        !std::getline(ss, src_port_str, ',') ||
        !std::getline(ss, dst_port_str, ',') ||
        !std::getline(ss, protocol_str, ',') ||
        !std::getline(ss, payload_hex)) {
        std::cerr << "Invalid input format. Please check your entry." << std::endl;
        return 1;
    }

    // Convert strings to integers
    int src_port = std::stoi(src_port_str);
    int dst_port = std::stoi(dst_port_str);
    int protocol = std::stoi(protocol_str);

    // Default label (used for comparison if needed)
    int label = -1;

    std::vector<float> input = extract_features(src_ip, dst_ip, src_port, dst_port, protocol, payload_hex);

    auto hidden_weights = load_weights("hidden_weights_float32.txt", HIDDEN_SIZE, INPUT_SIZE);
    auto hidden_bias = load_vector("hidden_bias_float32.txt", HIDDEN_SIZE);
    auto output_weights = load_weights("output_weights_float32.txt", OUTPUT_SIZE, HIDDEN_SIZE);
    auto output_bias = load_vector("output_bias_float32.txt", OUTPUT_SIZE);

    std::vector<float> hidden(HIDDEN_SIZE, 0.0f);
    for (int i = 0; i < HIDDEN_SIZE; ++i) {
        for (int j = 0; j < INPUT_SIZE; ++j)
            hidden[i] += hidden_weights[i][j] * input[j];
        hidden[i] += hidden_bias[i];
        hidden[i] = std::max(0.0f, hidden[i]); // ReLU activation
    }

    float output = 0.0f;
    for (int i = 0; i < HIDDEN_SIZE; ++i)
        output += output_weights[0][i] * hidden[i];
    output += output_bias[0];

    std::cout << "Model output (logit): " << output << std::endl;
    std::cout << "Predicted class: " << (output > 0 ? 1 : 0) << std::endl;

    return 0;
}
