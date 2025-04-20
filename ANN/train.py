import torch
import torch.nn as nn
import torch.optim as optim
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from torch.utils.data import TensorDataset, DataLoader
import pandas as pd
import glob
import ipaddress

# Find the latest dataset file
dataset_files = glob.glob("network_traffic_dataset_*.csv")
if not dataset_files:
    raise FileNotFoundError("No network_traffic_dataset CSV files found")

latest_file = max(dataset_files)
print(f"Using dataset: {latest_file}")

# Load the network traffic dataset
df = pd.read_csv(latest_file)

# Convert label to binary (0 for normal, 1 for malicious)
df['label_binary'] = df['label'].apply(lambda x: 1 if x == 'malicious' else 0)

# One-hot encode protocol (3 values)
protocol_map = {'tcp': [1, 0, 0], 'udp': [0, 1, 0], 'icmp': [0, 0, 1]}
df['protocol_encoded'] = df['protocol'].apply(lambda x: protocol_map.get(x, [0, 0, 0]))

# IP segment extraction
def ip_to_segments(ip):
    try:
        parts = [int(part)/255.0 for part in ip.split('.')]
        if len(parts) == 4:
            return parts
    except:
        pass
    return [0.0, 0.0, 0.0, 0.0]

df[['src_ip1', 'src_ip2', 'src_ip3', 'src_ip4']] = df['src_ip'].apply(ip_to_segments).to_list()
df[['dst_ip1', 'dst_ip2', 'dst_ip3', 'dst_ip4']] = df['dst_ip'].apply(ip_to_segments).to_list()

# Prepare features array
X = np.zeros((len(df), 13), dtype=np.float32)  # 13 features

for i, row in df.iterrows():
    X[i, 0:3] = row['protocol_encoded']
    X[i, 3:7] = [row['src_ip1'], row['src_ip2'], row['src_ip3'], row['src_ip4']]
    X[i, 7:11] = [row['dst_ip1'], row['dst_ip2'], row['dst_ip3'], row['dst_ip4']]
    X[i, 11] = row['src_port'] / 65535
    X[i, 12] = row['dst_port'] / 65535

y = df['label_binary'].values.astype(np.long)
indices = np.arange(len(X))

# Split data and indices
X_train, X_test, y_train, y_test, idx_train, idx_test = train_test_split(
    X, y, indices, test_size=0.2, random_state=42
)

# Convert to tensors
X_train = torch.tensor(X_train, dtype=torch.float32)
y_train = torch.tensor(y_train, dtype=torch.long)
X_test = torch.tensor(X_test, dtype=torch.float32)
y_test = torch.tensor(y_test, dtype=torch.long)

# Create data loaders
train_loader = DataLoader(TensorDataset(X_train, y_train), batch_size=32, shuffle=True)
test_loader = DataLoader(TensorDataset(X_test, y_test), batch_size=32, shuffle=False)

# Define the neural network model (updated input size to 13)
class MinimalFNN(nn.Module):
    def __init__(self):
        super(MinimalFNN, self).__init__()
        self.hidden = nn.Linear(13, 3, bias=False)  # 3 neurons in hidden layer
        self.output = nn.Linear(3, 2, bias=False)   # 2 output classes (normal/malicious)

    def forward(self, x):
        x = torch.relu(self.hidden(x))
        x = self.output(x)
        return x

# Instantiate model
model = MinimalFNN()

criterion = nn.CrossEntropyLoss()
optimizer = optim.SGD(model.parameters(), lr=0.5)

# Train
num_epochs = 70
for epoch in range(num_epochs):
    for inputs, labels in train_loader:
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

    if (epoch + 1) % 10 == 0:
        print(f"Epoch {epoch+1}/{num_epochs} completed")

# Evaluate accuracy
correct, total = 0, 0
with torch.no_grad():
    for inputs, labels in test_loader:
        outputs = model(inputs)
        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

print(f"Test Accuracy = {100 * correct / total:.2f}%")

# Show 10 random test predictions
num_images = 10
fig, axes = plt.subplots(2, 5, figsize=(15, 6))
axes = axes.ravel()

for i in range(num_images):
    rand_idx = np.random.randint(0, len(X_test))
    original_idx = idx_test[rand_idx]

    sample = X_test[rand_idx].view(1, -1)
    with torch.no_grad():
        output = model(sample)
        predicted_label = torch.argmax(output).item()

    original_data = df.iloc[original_idx]

    text = f"Protocol: {original_data['protocol']}\n"
    text += f"Src IP: {original_data['src_ip']}\n"
    text += f"Dst IP: {original_data['dst_ip']}\n"
    text += f"Src Port: {int(original_data['src_port'])}\n"
    text += f"Dst Port: {int(original_data['dst_port'])}\n"
    text += f"Pred: {'Malicious' if predicted_label == 1 else 'Normal'}\n"
    text += f"Actual: {'Malicious' if original_data['label_binary'] == 1 else 'Normal'}"

    axes[i].text(0.5, 0.5, text, ha='center', va='center', fontsize=9)
    axes[i].axis('off')

plt.tight_layout()
plt.savefig('traffic_predictions.png')
plt.show()

# Save weights
hidden_weights = model.hidden.weight.detach().cpu().numpy()
output_weights = model.output.weight.detach().cpu().numpy()

np.savetxt("hidden_weights.txt", hidden_weights, fmt="%.5f")
np.savetxt("output_weights.txt", output_weights, fmt="%.5f")

print("Hidden layer weights saved to hidden_weights.txt")
print("Output layer weights saved to output_weights.txt")
