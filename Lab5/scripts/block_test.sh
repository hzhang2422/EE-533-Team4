#!/bin/bash

# Function to show usage
usage() {
    echo "Usage: $0 [-t <packet_size>] [-l <test_duration>] [-i <interval>] [-p <pattern>]"
    echo "Options:"
    echo "  -t    : Packet size in bytes, default: 1400"
    echo "  -l    : Test duration in seconds, default: 30"
    echo "  -i    : Test interval in seconds, default: 2"
    echo "  -p    : Pattern for idsreg, default: ABCDEFG"
    exit 1
}

# Default values
TEAM_NUM=4
PASSWORD="REDACTED"
PACKET_SIZE=1400
TEST_DURATION=30
INTERVAL=2
PATTERN="ABCDEFG"
BASE_PORT=5001

# Parse optional parameters
while getopts "b:k:t:l:i:p:r" opt; do
    case $opt in
        t) PACKET_SIZE=$OPTARG ;;
        l) TEST_DURATION=$OPTARG ;;
        i) INTERVAL=$OPTARG ;;
        p) PATTERN=$OPTARG ;;
        *) usage ;;
    esac
done

OUTPUT_FILE="block_test_results.md"

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
echo "# Network Test Results" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "## Test Information" >> $OUTPUT_FILE
echo "* Date: $(date)" >> $OUTPUT_FILE
echo "* Team Number: $TEAM_NUM" >> $OUTPUT_FILE
echo "* Node Information:" >> $OUTPUT_FILE
echo "  - NetFPGA Node: nf$M0" >> $OUTPUT_FILE
echo "  - Test Nodes: nf$M1, nf$M2, nf$M3, nf$M4" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Step 1: Download bit file
echo "[Step 1/6] Downloading bit file on NetFPGA node..."
echo "### Bit File Download" >> $OUTPUT_FILE
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "nf_download /home/netfpga/bitfiles/lab5.bit" >> $OUTPUT_FILE 2>&1

# Step 2: Start RKD
echo "[Step 2/6] Starting RKD..."
RKD_PID=""
echo "### RKD Startup" >> $OUTPUT_FILE
RKD_PID=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "rkd > /dev/null 2>&1 & echo \$!")
echo "RKD started with PID: $RKD_PID" >> $OUTPUT_FILE
sleep 2

# Step 3: Setup idsreg
echo "[Step 3/6] Setting up idsreg..."
echo "### IDS Configuration" >> $OUTPUT_FILE
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "\
    /home/netfpga/scripts/idsreg reset && \
    /home/netfpga/scripts/idsreg pattern $PATTERN && \
    /home/netfpga/scripts/idsreg allregs" >> $OUTPUT_FILE 2>&1

sleep 5

# Associate array to store server PIDs
declare -A SERVER_PIDS

# Function to run iperf client with specific message
run_iperf_client() {
    local source_node=$1
    local target_node=$2
    local msg_type=$3
    local udp_mode=$4
    local port=$5
    
    local PROTO_PARAMS=""
    [ $udp_mode -eq 1 ] && PROTO_PARAMS="-u -w 256K -b 1G"
    
    echo "### Test: nf$source_node -> nf$target_node ($msg_type)" >> $OUTPUT_FILE
    echo "* Protocol: $([ $udp_mode -eq 1 ] && echo "UDP" || echo "TCP")" >> $OUTPUT_FILE
    echo "* Port: $port" >> $OUTPUT_FILE
    echo "#### Client Output" >> $OUTPUT_FILE
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$source_node.usc.edu \
        "iperf -c nf$target_node.usc.edu $PROTO_PARAMS -i $INTERVAL -t $TEST_DURATION -p $port" >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE
}

# Step 4: Run tests for both TCP and UDP
echo "[Step 4/6] Starting network tests..."
for protocol in 0 1; do
    echo "" >> $OUTPUT_FILE
    proto_name=$([ $protocol -eq 1 ] && echo "UDP" || echo "TCP")
    echo "## $proto_name Tests" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
    echo "Running $proto_name tests..."

    UDP_FLAG=""
    [ $protocol -eq 1 ] && UDP_FLAG="-u"

    # Start iperf servers and create test files
    echo "### Server Startup" >> $OUTPUT_FILE
    port=$BASE_PORT
    for node in "${NODES[@]}"; do
        # Create test files
        sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$node.usc.edu "echo '123456789' > goodmsg.txt && echo '1234ABCDEFG5678' > badmsg.txt" || {
            echo "Failed to create test files on nf$node" >> $OUTPUT_FILE
            continue
        }
        
        # Start iperf server
        echo "#### Server on nf$node" >> $OUTPUT_FILE
        SERVER_PID=$(sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$node.usc.edu "iperf -s $UDP_FLAG -p $port > server_output_$node.txt 2>&1 & echo \$!") || {
            echo "Failed to start iperf server on nf$node" >> $OUTPUT_FILE
            continue
        }
        
        SERVER_PIDS[$node]=$SERVER_PID
        echo "Started iperf server on nf$node (PID: $SERVER_PID, Port: $port)" >> $OUTPUT_FILE
        ((port++))
        sleep 1
    done

    # Run tests for each node
    for source_node in "${NODES[@]}"; do
        echo "Testing from node nf$source_node..."
        
        target_nodes=()
        for node in "${NODES[@]}"; do
            [ "$node" != "$source_node" ] && target_nodes+=($node)
        done
        
        port=$BASE_PORT
        # Send good messages to first two targets
        for ((i=0; i<2; i++)); do
            if [ $i -lt ${#target_nodes[@]} ]; then
                run_iperf_client $source_node ${target_nodes[$i]} "goodmsg" $protocol $port &
                ((port++))
            fi
        done
        # Send bad message to last target
        if [ ${#target_nodes[@]} -gt 2 ]; then
            run_iperf_client $source_node ${target_nodes[2]} "badmsg" $protocol $port &
        fi
    done

    wait

    # Collect and save server outputs
    echo "### Server Outputs" >> $OUTPUT_FILE
    for node in "${NODES[@]}"; do
        echo "#### Server nf$node Output" >> $OUTPUT_FILE
        sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$node.usc.edu "cat server_output_$node.txt" >> $OUTPUT_FILE 2>&1
        echo "" >> $OUTPUT_FILE
    done

    # Cleanup servers and files
    for node in "${NODES[@]}"; do
        if [ ! -z "${SERVER_PIDS[$node]}" ]; then
            sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no node$ND@nf$node.usc.edu "kill ${SERVER_PIDS[$node]} 2>/dev/null; rm -f goodmsg.txt badmsg.txt server_output_$node.txt"
        fi
    done
done

# Step 5: Check IDS results
echo "[Step 5/6] Checking IDS results..."
echo "" >> $OUTPUT_FILE
echo "## Final IDS Results" >> $OUTPUT_FILE
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "/home/netfpga/scripts/idsreg matches" >> $OUTPUT_FILE 2>&1

# Step 6: Cleanup
echo "[Step 6/6] Cleaning up..."
if [ ! -z "$RKD_PID" ]; then
    echo "### Cleanup" >> $OUTPUT_FILE
    echo "Stopping RKD (PID: $RKD_PID)" >> $OUTPUT_FILE
    sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no netfpga@nf$M0.usc.edu "kill $RKD_PID"
fi

echo "All tests completed. Results saved in $OUTPUT_FILE"