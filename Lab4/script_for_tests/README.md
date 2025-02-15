## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| -b | Bitfile type (nic or router) | nic |
| -t | Packet size in bytes | 512 |
| -l | Test duration in seconds | 30 |
| -i | Test interval in seconds | 2 |
| -u | Use UDP mode (TCP if not specified) | TCP |
| -r | Enable RKD | disable |

## Examples
```bash
# Basic test with default settings (TCP mode)
./network_test_nsnc.sh

# UDP test with router bitfile, UDP mode, enable rkd
./network_test_nsnc.sh -b router -u -r

# Custom test with 1KB packets for 60 seconds, interval 5 seconds
./network_test_nsnc.sh -t 1024 -l 60 -i 5
```

Test results will be saved to `bandwidth_test_results.md`.

## Code Improvement

- Change the test plan to: traverse all nodes.

-  Add the parameter `rkd`.

  ````sh
  # Start RKD if enabled
  RKD_PID=""
  if [ $RKD_ENABLE -eq 1 ]; then
      echo "Starting RKD on nf$M0..."
      RKD_PID=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "rkd > /dev/null 2>&1 & echo \$!")
      echo "RKD started with PID: $RKD_PID"
      sleep 2  # Wait for RKD to initialize
  fi
  
  ...
  
  # Kill RKD if it was started
  if [ ! -z "$RKD_PID" ]; then
      echo "Stopping RKD on nf$M0 (PID: $RKD_PID)..."
      sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "kill $RKD_PID"
  fi
  ````
  
- At the end of each loop, use the PID to kill all `iperf` servers.

  ```` sh
  echo "Stopping iperf server on nf$target_node (PID: ${SERVER_PIDS[$target_node]})"
      sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$target_node.usc.edu "kill ${SERVER_PIDS[$target_node]}"
  ````

  



