!pip install mmh3

import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import matplotlib.pyplot as plt
from torch.utils.data import TensorDataset, DataLoader
from sklearn.model_selection import train_test_split
import hashlib
import pandas as pd
import binascii
import mmh3

# Function: extract n-gram features from 5-tuple and payload
def extract_features_from_flow(src_ip, dst_ip, src_port, dst_port, protocol, payload_hex, ngram_size=8):
    """
    Extract features using an 8-byte n-gram sliding window,
    mapped to a 256-bin histogram with 1-byte step size.
    
    Args:
        src_ip: Source IP address
        dst_ip: Destination IP address
        src_port: Source port
        dst_port: Destination port
        protocol: Protocol
        payload_hex: Payload in hex string format
        ngram_size: Size of n-gram window (default: 8 bytes)
    
    Returns:
        A 256-dimensional feature vector (histogram)
    """
    histogram = np.zeros(256, dtype=np.float32)
    
    five_tuple = f"{src_ip},{dst_ip},{src_port},{dst_port},{protocol}".encode()
    
    try:
        payload_str = str(payload_hex).replace(" ", "")
        payload_bytes = binascii.unhexlify(payload_str)
    except (binascii.Error, ValueError):
        payload_bytes = b''

    packet_data = five_tuple + payload_bytes

    if len(packet_data) < ngram_size:
        packet_data = packet_data + b'\x00' * (ngram_size - len(packet_data))
    
    for i in range(len(packet_data) - ngram_size + 1):
        ngram = packet_data[i:i+ngram_size]
        hash_value = mmh3.hash(ngram) % 256
        histogram[hash_value] += 1

    if np.sum(histogram) > 0:
        histogram = histogram / np.sum(histogram)
    
    return histogram

# Function: Load network traffic dataset from CSV
def load_dataset_from_csv(csv_file):
    """
    Load network traffic data from CSV and extract features
    
    CSV format: src_ip,dst_ip,src_port,dst_port,protocol,payload_hex,label
    
    Args:
        csv_file: Path to CSV file
    
    Returns:
        X: Feature matrix
        y: Label vector (0=normal, 1=malicious)
    """
    print(f"Loading dataset from: {csv_file}")
    df = pd.read_csv(csv_file)
    
    required_columns = ['src_ip', 'dst_ip', 'src_port', 'dst_port', 'protocol', 'payload_hex', 'label']
    for col in required_columns:
        if col not in df.columns:
            raise ValueError(f"Missing required column in CSV: {col}")
    
    features = []
    labels = []
    
    print(f"Processing {len(df)} network flow records...")
    
    for idx, row in df.iterrows():
        if idx % 1000 == 0:
            print(f"Processed {idx}/{len(df)} records")
        
        feature = extract_features_from_flow(
            row['src_ip'],
            row['dst_ip'],
            row['src_port'],
            row['dst_port'],
            row['protocol'],
            row['payload_hex']
        )
        
        features.append(feature)
        labels.append(int(row['label']))
    
    print("Dataset loaded successfully!")
    return np.array(features, dtype=np.float32), np.array(labels, dtype=np.int64)

# Neural network model
class NetworkClassifier(nn.Module):
    def __init__(self):
        super(NetworkClassifier, self).__init__()
        self.hidden = nn.Linear(256, 3)
        self.output = nn.Linear(3, 1)
    
    def forward(self, x):
        x = torch.relu(self.hidden(x))
        x = self.output(x)
        return x

# Function: Quantize float32 weights to int8
def quantize_to_int8(weights, bias=None):
    """
    Quantize float32 weights to int8 and return scale factors
    
    Args:
        weights: float32 weight tensor
        bias: float32 bias tensor (optional)
    
    Returns:
        quantized_weights: int8 weights
        quantized_bias: int8 bias (if provided)
        scale_factor: scale factors
    """
    abs_max = np.max(np.abs(weights))
    scale_factor = abs_max / 127.0
    quantized_weights = np.round(weights / scale_factor).astype(np.int8)
    
    quantized_bias = None
    if bias is not None:
        bias_abs_max = np.max(np.abs(bias))
        bias_scale = bias_abs_max / 127.0
        quantized_bias = np.round(bias / bias_scale).astype(np.int8)
        return quantized_weights, quantized_bias, (scale_factor, bias_scale)
    
    return quantized_weights, scale_factor

# Main function
def main():
    # 1. Load and preprocess data
    csv_file = "Final_ANN_Dataset.csv"
    X, y = load_dataset_from_csv(csv_file)
    
    normal_count = np.sum(y == 0)
    malicious_count = np.sum(y == 1)
    print(f"Dataset stats: {normal_count} normal, {malicious_count} malicious")

    # 2. Split into train/test sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Train set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    # 3. Convert to PyTorch tensors
    X_train = torch.tensor(X_train, dtype=torch.float32)
    y_train = torch.tensor(y_train, dtype=torch.float32).reshape(-1, 1)
    X_test = torch.tensor(X_test, dtype=torch.float32)
    y_test = torch.tensor(y_test, dtype=torch.float32).reshape(-1, 1)
    
    # 4. Create DataLoaders
    train_loader = DataLoader(TensorDataset(X_train, y_train), batch_size=64, shuffle=True)
    test_loader = DataLoader(TensorDataset(X_test, y_test), batch_size=64, shuffle=False)
    
    # 5. Initialize model, loss, optimizer
    model = NetworkClassifier()
    criterion = nn.BCEWithLogitsLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    # 6. Train model
    num_epochs = 50
    train_losses = []
    test_accuracies = []
    best_accuracy = 0.0
    
    print("\nTraining started...")
    for epoch in range(num_epochs):
        model.train()
        epoch_loss = 0.0
        
        for inputs, labels in train_loader:
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            epoch_loss += loss.item()
        
        avg_loss = epoch_loss / len(train_loader)
        train_losses.append(avg_loss)
        
        model.eval()
        correct = 0
        total = 0
        all_preds = []
        all_labels = []
        
        with torch.no_grad():
            for inputs, labels in test_loader:
                outputs = model(inputs)
                predicted = (torch.sigmoid(outputs) > 0.5).float()
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
                all_preds.extend(predicted.cpu().numpy())
                all_labels.extend(labels.cpu().numpy())
        
        accuracy = correct / total
        test_accuracies.append(accuracy)
        
        if accuracy > best_accuracy:
            best_accuracy = accuracy
            torch.save(model.state_dict(), "best_model.pth")
        
        if (epoch+1) % 5 == 0:
            tp = np.sum((np.array(all_preds) == 1) & (np.array(all_labels) == 1))
            fp = np.sum((np.array(all_preds) == 1) & (np.array(all_labels) == 0))
            fn = np.sum((np.array(all_preds) == 0) & (np.array(all_labels) == 1))
            
            precision = tp / (tp + fp) if tp + fp > 0 else 0
            recall = tp / (tp + fn) if tp + fn > 0 else 0
            f1 = 2 * precision * recall / (precision + recall) if precision + recall > 0 else 0
            
            print(f"Epoch {epoch+1}/{num_epochs}, Loss: {avg_loss:.4f}, Accuracy: {accuracy:.4f}")
            #print(f"Precision: {precision:.4f}, Recall: {recall:.4f}, F1-Score: {f1:.4f}")
        else:
            print(f"Epoch {epoch+1}/{num_epochs}, Loss: {avg_loss:.4f}, Accuracy: {accuracy:.4f}")
    
    print(f"\nTraining complete! Best test accuracy: {best_accuracy:.4f}")
    
    # 7. Extract float32 weights
    model.load_state_dict(torch.load("best_model.pth"))
    hidden_weights = model.hidden.weight.detach().cpu().numpy()
    hidden_bias = model.hidden.bias.detach().cpu().numpy()
    output_weights = model.output.weight.detach().cpu().numpy()
    output_bias = model.output.bias.detach().cpu().numpy()
    
    print("\nOriginal float32 weight summary:")
    print(f"Hidden weights: shape={hidden_weights.shape}, range=[{np.min(hidden_weights):.6f}, {np.max(hidden_weights):.6f}]")
    print(f"Hidden bias: shape={hidden_bias.shape}, range=[{np.min(hidden_bias):.6f}, {np.max(hidden_bias):.6f}]")
    print(f"Output weights: shape={output_weights.shape}, range=[{np.min(output_weights):.6f}, {np.max(output_weights):.6f}]")
    print(f"Output bias: shape={output_bias.shape}, range=[{np.min(output_bias):.6f}, {np.max(output_bias):.6f}]")
    
    # 8. Quantize to int8 and save
    print("\nQuantizing weights...")
    
    hidden_weights_int8, hidden_bias_int8, (hidden_w_scale, hidden_b_scale) = quantize_to_int8(
        hidden_weights, hidden_bias
    )
    output_weights_int8, output_bias_int8, (output_w_scale, output_b_scale) = quantize_to_int8(
        output_weights, output_bias
    )
    
    print("\nQuantized int8 weight summary:")
    print(f"Hidden weights: shape={hidden_weights_int8.shape}, range=[{np.min(hidden_weights_int8)}, {np.max(hidden_weights_int8)}]")
    print(f"Hidden bias: shape={hidden_bias_int8.shape}, range=[{np.min(hidden_bias_int8)}, {np.max(hidden_bias_int8)}]")
    print(f"Output weights: shape={output_weights_int8.shape}, range=[{np.min(output_weights_int8)}, {np.max(output_weights_int8)}]")
    print(f"Output bias: shape={output_bias_int8.shape}, range=[{np.min(output_bias_int8)}, {np.max(output_bias_int8)}]")
    
    np.savetxt("hidden_weights_int8.txt", hidden_weights_int8, fmt="%d")
    np.savetxt("hidden_bias_int8.txt", hidden_bias_int8, fmt="%d")
    np.savetxt("output_weights_int8.txt", output_weights_int8, fmt="%d")
    np.savetxt("output_bias_int8.txt", output_bias_int8, fmt="%d")
    
    scales = {
        "hidden_weights_scale": hidden_w_scale,
        "hidden_bias_scale": hidden_b_scale,
        "output_weights_scale": output_w_scale,
        "output_bias_scale": output_b_scale
    }
    with open("scales.txt", "w") as f:
        for name, scale in scales.items():
            f.write(f"{name}: {scale}\n")
    
    np.savetxt("hidden_weights_float32.txt", hidden_weights, fmt="%.6f")
    np.savetxt("hidden_bias_float32.txt", hidden_bias, fmt="%.6f")
    np.savetxt("output_weights_float32.txt", output_weights, fmt="%.6f")
    np.savetxt("output_bias_float32.txt", output_bias, fmt="%.6f")
    
    print("\nAll weights have been saved:")
    print("- hidden_weights_int8.txt")
    print("- hidden_bias_int8.txt")
    print("- output_weights_int8.txt")
    print("- output_bias_int8.txt")
    print("- scales.txt")
    print("- hidden_weights_float32.txt (for reference)")
    print("- hidden_bias_float32.txt (for reference)")
    print("- output_weights_float32.txt (for reference)")
    print("- output_bias_float32.txt (for reference)")
    
    # 9. Verify quantization effect
    #print("\nVerifying quantization effect...")
    
    def inference_with_quantized_weights(x):
        hidden_out = np.zeros(3)
        for i in range(3):
            for j in range(256):
                hidden_out[i] += x[j] * (hidden_weights_int8[i, j] * hidden_w_scale)
            hidden_out[i] += hidden_bias_int8[i] * hidden_b_scale
            hidden_out[i] = max(0, hidden_out[i])
        
        output = 0
        for i in range(3):
            output += hidden_out[i] * (output_weights_int8[0, i] * output_w_scale)
        output += output_bias_int8[0] * output_b_scale
        return output
    
    num_samples = min(10, len(X_test))
    model.eval()
    
    #print(f"\nComparing original vs quantized model on {num_samples} test samples:")
    #print("Sample\tActual\tOriginal\tQuantized")
    
    with torch.no_grad():
        for i in range(num_samples):
            original_output = model(X_test[i:i+1]).item()
            original_pred = 1 if original_output > 0 else 0
            
            quantized_output = inference_with_quantized_weights(X_test[i].numpy())
            quantized_pred = 1 if quantized_output > 0 else 0
            
            actual = y_test[i].item()
            
            #print(f"{i+1}\t{int(actual)}\t{original_pred}\t{quantized_pred}")
    


if __name__ == "__main__":
    main()
