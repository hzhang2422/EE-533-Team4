## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| -b | Bitfile type (nic or router) | nic |
| -t | Packet size in bytes | 512 |
| -l | Test duration in seconds | 30 |
| -i | Test interval in seconds | 2 |
| -u | Use UDP mode (TCP if not specified) | TCP |

## Examples
```bash
# Basic test with default settings (TCP mode)
./network_test_nsnc.sh

# UDP test with router bitfile
./network_test_nsnc.sh -b router -u

# Custom test with 1KB packets for 60 seconds, interval 5 seconds
./network_test_nsnc.sh -t 1024 -l 60 -i 5
```

Test results will be saved to `bandwidth_test_results.md`.
