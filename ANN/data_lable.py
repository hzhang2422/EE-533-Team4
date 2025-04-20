import pandas as pd

# Load your raw CSV traffic data
df = pd.read_csv("your_raw_data.csv")  # Make sure it contains: protocol, src_ip, dst_ip, src_port, dst_port

# Clean missing values (common in ICMP/UDP without port data)
df.fillna({'src_port': 0, 'dst_port': 0, 'src_ip': '', 'dst_ip': ''}, inplace=True)

# Normalize protocol column to lowercase
df["protocol"] = df["protocol"].str.lower()

# Define rule sets based on alert_rules.pl
malicious_ips = {
    "45.83.64.1", "103.27.202.112", "185.220.101.4", "91.240.118.129", "222.186.30.11",
    "89.248.167.131", "185.107.56.215", "198.144.121.93"
}

malicious_ports = {
    0, 1, 21, 22, 23, 69, 135, 137, 1433, 1900, 3389, 445, 593, 8080, 8443, 161, 19, 123
}

malicious_protocols = {
    "icmp"  # Multiple rules targeting ICMP, treat all as malicious
}

# Label each row: if it matches any rule category -> malicious, else normal
def classify(row):
    if (
        row["src_ip"] in malicious_ips or
        row["dst_ip"] in malicious_ips or
        row["dst_port"] in malicious_ports or
        row["protocol"] in malicious_protocols
    ):
        return "malicious"
    return "normal"

df["label"] = df.apply(classify, axis=1)

# Save the labeled dataset
df.to_csv("labeled_dataset.csv", index=False)
print("✅ Labeling complete. Output saved to labeled_dataset.csv")
