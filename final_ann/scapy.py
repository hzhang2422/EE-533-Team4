from scapy.all import rdpcap, IP, TCP, UDP
import csv

# Input and output paths
pcap_file = "capture.pcap"
output_csv = "pcap_5tuple_payload.csv"
max_payload_len = 128  # Maximum payload length to retain (can be modified)

# Read PCAP
packets = rdpcap(pcap_file)

with open(output_csv, 'w', newline='') as f:
    writer = csv.writer(f)
    # Write header
    writer.writerow(['src_ip', 'dst_ip', 'src_port', 'dst_port', 'protocol', 'payload_hex'])

    for pkt in packets:
        if IP in pkt:
            ip = pkt[IP]
            proto = ip.proto

            # Check if it's TCP/UDP
            if proto == 6 and TCP in pkt:
                l4 = pkt[TCP]
            elif proto == 17 and UDP in pkt:
                l4 = pkt[UDP]
            else:
                continue  # Skip non-TCP/UDP packets

            # Extract 5-tuple
            src_ip = ip.src
            dst_ip = ip.dst
            src_port = l4.sport
            dst_port = l4.dport
            protocol = proto

            # Extract payload
            payload = bytes(l4.payload)[:max_payload_len]  # Truncate
            payload_hex = payload.hex()

            writer.writerow([src_ip, dst_ip, src_port, dst_port, protocol, payload_hex])

print(f"Extraction completed, saved to {output_csv}")
