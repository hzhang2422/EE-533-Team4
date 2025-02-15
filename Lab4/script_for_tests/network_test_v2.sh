# chmod a+x network_test_nsnc.sh
#!/bin/bash

# Function to show usage
usage() {
    echo "Usage: $0 [-b <nic|router>] [-t <packet_size>] [-l <test_duration>] [-i <interval>] [-u] [-r]"
    echo "Options:"
    echo "  -b    : Bitfile type (nic or router), default: nic"
    echo "  -t    : Packet size in bytes, default: 512"
    echo "  -l    : Test duration in seconds, default: 30"
    echo "  -i    : Test interval in seconds, default: 2"
    echo "  -u    : Use UDP mode (default: TCP)"
    echo "  -r    : Enable RKD (default: disabled)"
    exit 1
}

# Default values
TEAM_NUM=4
PASSWORD="REDACTED"
BITFILE_TYPE="nic"
PACKET_SIZE=512
TEST_DURATION=30
INTERVAL=2
UDP_MODE=0
RKD_ENABLE=0

# Parse optional parameters
while getopts "b:k:t:l:i:ur" opt; do
    case $opt in
        b) BITFILE_TYPE=$OPTARG ;;
        t) PACKET_SIZE=$OPTARG ;;
        l) TEST_DURATION=$OPTARG ;;
        i) INTERVAL=$OPTARG ;;
        u) UDP_MODE=1 ;;
        r) RKD_ENABLE=1 ;;
        *) usage ;;
    esac
done

OUTPUT_FILE="bandwidth_test_results.md"

# Compute node numbers
ND=$(($TEAM_NUM % 5))
CL=$(( $(($TEAM_NUM / 5)) * 5))
M0=$(($ND + $CL))  # netfpga node
M1=$(( $(( $(($ND + 1)) % 5)) + $CL))
M2=$(( $(( $(($ND + 2)) % 5)) + $CL))
M3=$(( $(( $(($ND + 3)) % 5)) + $CL))
M4=$(( $(( $(($ND + 4)) % 5)) + $CL))

# Create array of nodes
NODES=($M1 $M2 $M3 $M4)

# Create test results file
echo "# Network Bandwidth Test Results" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "## Test Information" >> $OUTPUT_FILE
echo "* Date: $(date)" >> $OUTPUT_FILE
echo "* Team Number: $TEAM_NUM" >> $OUTPUT_FILE
echo "* Bitfile Type: $BITFILE_TYPE" >> $OUTPUT_FILE
echo "* Protocol: $([ $UDP_MODE -eq 1 ] && echo "UDP" || echo "TCP")" >> $OUTPUT_FILE
echo "* Packet Size: $PACKET_SIZE bytes" >> $OUTPUT_FILE
echo "* Test Duration: $TEST_DURATION seconds" >> $OUTPUT_FILE
echo "* Test Interval: $INTERVAL seconds" >> $OUTPUT_FILE
echo "* RKD Enabled: $([ $RKD_ENABLE -eq 1 ] && echo "Yes" || echo "No")" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "## Test Results" >> $OUTPUT_FILE

# Set bitfile path based on type
if [ "$BITFILE_TYPE" = "router" ]; then
    BITFILE="/home/netfpga/bitfiles/reference_router.bit"
else
    BITFILE="/home/netfpga/bitfiles/reference_nic.bit"
fi

# Download bit file on nf4
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "nf_download $BITFILE"

# Start RKD if enabled
RKD_PID=""
if [ $RKD_ENABLE -eq 1 ]; then
    echo "Starting RKD on nf$M0..."
    RKD_PID=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "rkd > /dev/null 2>&1 & echo \$!")
    echo "RKD started with PID: $RKD_PID"
    sleep 2  # Wait for RKD to initialize
fi

# Wait for bit file download to complete
sleep 5

# Associate array to store server PIDs
declare -A SERVER_PIDS

# Start iperf servers on all nodes and store PIDs
UDP_FLAG=""
[ $UDP_MODE -eq 1 ] && UDP_FLAG="-u"

for node in "${NODES[@]}"; do
    # Start server and get PID
    SERVER_PID=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$node.usc.edu "iperf -s $UDP_FLAG > /dev/null 2>&1 & echo \$!")
    SERVER_PIDS[$node]=$SERVER_PID
    echo "Started iperf server on nf$node with PID: $SERVER_PID"
    sleep 1
done

# Function to extract bandwidth from iperf output
extract_bandwidth() {
    local output=$1
    if [ $UDP_MODE -eq 1 ]; then
        echo "$output" | grep -i "Server Report" -A 1 | tail -n 1 | awk '{print $7}'
    else
        echo "$output" | tail -n 1 | awk '{print $7}'
    fi
}

# Create temporary files for results
TEMP_DIR=$(mktemp -d)
BW_FILE="$TEMP_DIR/bandwidth.txt"

# Test function for client
run_iperf_client() {
    local server_node=$1
    local client_node=$2
    local output_file=$3
    local bw_file=$4
    
    echo "" >> $output_file
    echo "### Test: nf$client_node → nf$server_node" >> $output_file
    echo "" >> $output_file
    echo "\`\`\`" >> $output_file
    
    local PROTO_PARAMS=""
    [ $UDP_MODE -eq 1 ] && PROTO_PARAMS="-u -w 256K -l $PACKET_SIZE -b 1G"
    
    local result=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$client_node.usc.edu \
        "iperf -c nf$server_node.usc.edu $PROTO_PARAMS -i $INTERVAL -t $TEST_DURATION")
    echo "$result" >> $output_file
    
    local bw=$(extract_bandwidth "$result")
    echo "$bw" >> $bw_file
    
    echo "\`\`\`" >> $output_file
    echo "Completed: nf$client_node → nf$server_node (${bw} Mbits/sec)"
}

# Run tests for each server node
for target_node in "${NODES[@]}"; do
    echo "Testing connections to server nf$target_node..."
    
    # Create array of client nodes (excluding target node)
    client_nodes=()
    for node in "${NODES[@]}"; do
        [ "$node" != "$target_node" ] && client_nodes+=($node)
    done
    
    # Start clients in parallel
    for client_node in "${client_nodes[@]}"; do
        TEMP_FILE="$TEMP_DIR/result_${client_node}_to_${target_node}.txt"
        run_iperf_client $target_node $client_node $TEMP_FILE $BW_FILE &
    done
    
    # Wait for all clients to complete
    wait
    
    # Kill the server on target node
    echo "Stopping iperf server on nf$target_node (PID: ${SERVER_PIDS[$target_node]})"
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$target_node.usc.edu "kill ${SERVER_PIDS[$target_node]}"
done

# Combine all result files
for f in $TEMP_DIR/result_*.txt; do
    [ -f "$f" ] && cat "$f" >> $OUTPUT_FILE
done

# Calculate average bandwidth
total=0
count=0
while read bw; do
    if [ ! -z "$bw" ]; then
        total=$(echo "$total + $bw" | bc)
        count=$((count + 1))
    fi
done < $BW_FILE

if [ $count -gt 0 ]; then
    average=$(echo "scale=2; $total / $count" | bc)
    echo "" >> $OUTPUT_FILE
    echo "## Average Bandwidth" >> $OUTPUT_FILE
    echo "Average bandwidth across all tests: $average Mbits/sec" >> $OUTPUT_FILE
    echo "Average bandwidth across all tests: $average Mbits/sec"
    echo "" >> $OUTPUT_FILE
fi

# Kill RKD if it was started
if [ ! -z "$RKD_PID" ]; then
    echo "Stopping RKD on nf$M0 (PID: $RKD_PID)..."
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "kill $RKD_PID"
fi

# Clean up
rm -rf $TEMP_DIR
echo "All tests completed. Results saved in $OUTPUT_FILE"