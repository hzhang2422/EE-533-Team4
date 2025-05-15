import csv

# Input file paths
packet_csv = 'pcap_5tuple_payload.csv'
snort_alert_file = 'snort.alert.fast'
output_csv = 'labeled_packets.csv'

# Parse 5-tuples from Snort alert log
malicious_flows = set()

with open(snort_alert_file, 'r') as f:
    for line in f:
        if '->' in line:
            try:
                proto_part = line.split('{')[-1].split('}')[0].strip()
                proto = 6 if proto_part == 'TCP' else 17 if proto_part == 'UDP' else 1  # ICMP = 1
                ip_part = line.strip().split('{')[1].split('}')[1].strip()
                src, dst = ip_part.split('->')
                src_ip, src_port = src.strip().split(':')
                dst_ip, dst_port = dst.strip().split(':')
                flow_key = (src_ip, dst_ip, int(src_port), int(dst_port), proto)
                malicious_flows.add(flow_key)
            except Exception as e:
                continue  # Some lines may not match the expected format

print(f"Extracted {len(malicious_flows)} malicious 5-tuples")

# Label each packet
with open(packet_csv, 'r') as infile, open(output_csv, 'w', newline='') as outfile:
    reader = csv.DictReader(infile)
    fieldnames = reader.fieldnames + ['label']
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()

    for row in reader:
        try:
            key = (row['src_ip'], row['dst_ip'],
                   int(row['src_port']), int(row['dst_port']),
                   int(row['protocol']))
            label = 1 if key in malicious_flows else 0
            row['label'] = label
            writer.writerow(row)
        except:
            continue
