import random
import ipaddress
import csv
from datetime import datetime

# Define malicious IPs from rules 1-8
MALICIOUS_IPS = [
    "45.83.64.1",
    "103.27.202.112",
    "185.220.101.4",
    "91.240.118.129",
    "222.186.30.11",
    "89.248.167.131",
    "185.107.56.215",
    "198.144.121.93"
]

# Define suspicious ports from rules 9-16 and 17-24
SUSPICIOUS_PORTS = [
    23, 445, 69, 21, 22, 3389, 161, 1433,  # Rules 9-16
    0, 1, 135, 593, 137, 8080, 8443, 1900  # Rules 17-24
]

# ICMP types that are considered suspicious (rules 25-32)
SUSPICIOUS_ICMP_TYPES = [8, 13]  # Echo request, Timestamp request

def generate_random_ip(exclude_ips=None):
    """Generate a random IP address not in the exclude list."""
    if exclude_ips is None:
        exclude_ips = []
    
    while True:
        # Generate a random private IP (more realistic for normal traffic)
        if random.random() < 0.7:  # 70% chance of private IP
            # Choose a private IP range
            private_ranges = [
                ("10.0.0.0", "10.255.255.255"),
                ("172.16.0.0", "172.31.255.255"),
                ("192.168.0.0", "192.168.255.255")
            ]
            start, end = random.choice(private_ranges)
            start_int = int(ipaddress.IPv4Address(start))
            end_int = int(ipaddress.IPv4Address(end))
            ip_int = random.randint(start_int, end_int)
        else:
            # Generate any valid IP (excluding private and reserved ranges)
            ip_int = random.randint(1, 0xFFFFFFFF)
            # Skip private and reserved ranges
            if (0x0A000000 <= ip_int <= 0x0AFFFFFF or  # 10.0.0.0 to 10.255.255.255
                0xAC100000 <= ip_int <= 0xAC1FFFFF or  # 172.16.0.0 to 172.31.255.255
                0xC0A80000 <= ip_int <= 0xC0A8FFFF or  # 192.168.0.0 to 192.168.255.255
                0x7F000000 <= ip_int <= 0x7FFFFFFF):   # 127.0.0.0 to 127.255.255.255
                continue
        
        ip = str(ipaddress.IPv4Address(ip_int))
        if ip not in exclude_ips:
            return ip

def generate_random_port():
    """Generate a random port number (1-65535)."""
    return random.randint(1, 65535)

def generate_malicious_traffic(count):
    """Generate malicious traffic based on the rules."""
    records = []
    
    # Calculate how many records to generate for each rule type
    rule_counts = {
        "malicious_ips": count // 4,
        "suspicious_ports": count // 4,
        "port_scans": count // 4,
        "protocol_abuse": count - (count // 4) * 3  # Remaining records
    }
    
    # 1. Generate traffic from known malicious IPs (rules 1-8)
    for _ in range(rule_counts["malicious_ips"]):
        malicious_ip = random.choice(MALICIOUS_IPS)
        protocol = "tcp" if random.random() < 0.7 else ("udp" if random.random() < 0.85 else "icmp")
        src_port = generate_random_port() if protocol != "icmp" else 0
        dst_port = generate_random_port() if protocol != "icmp" else 0
        records.append({
            "protocol": protocol,
            "src_ip": malicious_ip,
            "dst_ip": generate_random_ip(exclude_ips=MALICIOUS_IPS),
            "src_port": src_port,
            "dst_port": dst_port,
            "label": "malicious"
        })
    
    # 2. Generate traffic to suspicious ports (rules 9-16)
    for _ in range(rule_counts["suspicious_ports"]):
        protocol = "tcp" if random.random() < 0.7 else "udp"
        suspicious_port = random.choice(SUSPICIOUS_PORTS)
        records.append({
            "protocol": protocol,
            "src_ip": generate_random_ip(exclude_ips=MALICIOUS_IPS),
            "dst_ip": generate_random_ip(),
            "src_port": generate_random_port(),
            "dst_port": suspicious_port,
            "label": "malicious"
        })
    
    # 3. Generate port scan patterns (rules 17-24)
    for _ in range(rule_counts["port_scans"]):
        protocol = "tcp" if random.random() < 0.7 else "udp"
        src_ip = generate_random_ip(exclude_ips=MALICIOUS_IPS)
        dst_ip = generate_random_ip()
        suspicious_port = random.choice(SUSPICIOUS_PORTS)
        records.append({
            "protocol": protocol,
            "src_ip": src_ip,
            "dst_ip": dst_ip,
            "src_port": generate_random_port(),
            "dst_port": suspicious_port,
            "label": "malicious"
        })
    
    # 4. Generate protocol abuse (rules 25-32)
    for _ in range(rule_counts["protocol_abuse"]):
        if random.random() < 0.5:  # ICMP traffic
            records.append({
                "protocol": "icmp",
                "src_ip": generate_random_ip(exclude_ips=MALICIOUS_IPS),
                "dst_ip": generate_random_ip(),
                "src_port": 0,  # ICMP doesn't use ports, but we'll set 0 for consistency
                "dst_port": 0,
                "label": "malicious"
            })
        else:  # TCP/UDP abuse
            protocol = "tcp" if random.random() < 0.6 else "udp"
            dst_port = random.choice([0, 19, 123, 1900])  # Suspicious UDP/TCP ports
            records.append({
                "protocol": protocol,
                "src_ip": generate_random_ip(exclude_ips=MALICIOUS_IPS),
                "dst_ip": generate_random_ip(),
                "src_port": generate_random_port(),
                "dst_port": dst_port,
                "label": "malicious"
            })
    
    return records

def generate_normal_traffic(count):
    """Generate normal traffic that doesn't match the rules."""
    records = []
    
    # Define common normal ports
    normal_ports = [80, 443, 8000, 8888, 53, 67, 68, 5000, 5001, 9000, 9001, 25, 587, 143, 993]
    
    for _ in range(count):
        # For normal traffic, avoid using malicious IPs and suspicious ports
        protocol = random.choice(["tcp", "udp", "icmp"])
        
        if protocol == "icmp":
            src_port = 0
            dst_port = 0
        else:
            # Normal traffic typically uses well-known ports
            if random.random() < 0.7:  # 70% chance of using common ports
                dst_port = random.choice(normal_ports)
            else:
                # Generate a random port that's not in the suspicious list
                while True:
                    port = generate_random_port()
                    if port not in SUSPICIOUS_PORTS:
                        dst_port = port
                        break
            
            src_port = generate_random_port()
        
        # Generate IPs that are not in the malicious list
        src_ip = generate_random_ip(exclude_ips=MALICIOUS_IPS)
        dst_ip = generate_random_ip(exclude_ips=MALICIOUS_IPS)
        
        records.append({
            "protocol": protocol,
            "src_ip": src_ip,
            "dst_ip": dst_ip,
            "src_port": src_port,
            "dst_port": dst_port,
            "label": "normal"
        })
    
    return records

def generate_traffic_dataset(output_file, malicious_count=867, normal_count=9227):
    """Generate and save a dataset of network traffic."""
    # Get current timestamp for the filename
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"{output_file}_{timestamp}.csv"
    
    # Generate malicious and normal traffic
    malicious_traffic = generate_malicious_traffic(malicious_count)
    normal_traffic = generate_normal_traffic(normal_count)
    
    # Combine and shuffle the data
    all_traffic = malicious_traffic + normal_traffic
    random.shuffle(all_traffic)
    
    # Write to CSV
    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=["protocol", "src_ip", "dst_ip", "src_port", "dst_port", "label"])
        writer.writeheader()
        writer.writerows(all_traffic)
    
    print(f"Generated {len(all_traffic)} traffic records ({malicious_count} malicious, {normal_count} normal)")
    print(f"Dataset saved to {output_file}")

if __name__ == "__main__":
    generate_traffic_dataset("network_traffic_dataset", malicious_count=867, normal_count=9227)
