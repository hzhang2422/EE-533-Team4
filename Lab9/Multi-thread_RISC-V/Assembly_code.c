main:
    # Save return address
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Sort first group - using t0, t1, t2 registers
    la a0, group1        # Load address of first group
    jal ra, load_group1  # Call load function
    jal ra, sort_group1  # Call sort function
    
    
    # Sort second group - using s1, s2, s3 registers
    la a0, group2        # Load address of second group
    jal ra, load_group2  # Call load function
    jal ra, sort_group2  # Call sort function
    
    # Sort third group - using a1, a2, a3 registers
    la a0, group3        # Load address of third group
    jal ra, load_group3  # Call load function
    jal ra, sort_group3  # Call sort function
    
    # Sort fourth group - using s4, s5, s6 registers
    la a0, group4        # Load address of fourth group
    jal ra, load_group4  # Call load function
    jal ra, sort_group4  # Call sort function
    
    # Restore return address and return
    lw ra, 0(sp)
    addi sp, sp, 4
    
    li a0, 0  # Return value 0
    ret

# Load first group data into registers t0, t1, t2
load_group1:
    lw t0, 0(a0)   # Load first number into t0
    lw t1, 4(a0)   # Load second number into t1
    lw t2, 8(a0)   # Load third number into t2
    ret

# Sort first group data (t0, t1, t2)
sort_group1:
    # If t0 > t1, swap t0 and t1
    ble t0, t1, check1_t0_t2
    mv t3, t0
    mv t0, t1
    mv t1, t3
    
check1_t0_t2:
    # If t0 > t2, swap t0 and t2
    ble t0, t2, check1_t1_t2
    mv t3, t0
    mv t0, t2
    mv t2, t3
    
check1_t1_t2:
    # If t1 > t2, swap t1 and t2
    ble t1, t2, sort1_done
    mv t3, t1
    mv t1, t2
    mv t2, t3
    
sort1_done:
    ret

# Load second group data into registers s1, s2, s3
load_group2:
    lw s1, 0(a0)   # Load first number into s1
    lw s2, 4(a0)   # Load second number into s2
    lw s3, 8(a0)   # Load third number into s3
    ret

# Sort second group data (s1, s2, s3)
sort_group2:
    # If s1 > s2, swap s1 and s2
    ble s1, s2, check2_s1_s3
    mv t3, s1
    mv s1, s2
    mv s2, t3
    
check2_s1_s3:
    # If s1 > s3, swap s1 and s3
    ble s1, s3, check2_s2_s3
    mv t3, s1
    mv s1, s3
    mv s3, t3
    
check2_s2_s3:
    # If s2 > s3, swap s2 and s3
    ble s2, s3, sort2_done
    mv t3, s2
    mv s2, s3
    mv s3, t3
    
sort2_done:
    ret

# Load third group data into registers a1, a2, a3
load_group3:
    lw a1, 0(a0)   # Load first number into a1
    lw a2, 4(a0)   # Load second number into a2
    lw a3, 8(a0)   # Load third number into a3
    ret

# Sort third group data (a1, a2, a3)
sort_group3:
    # If a1 > a2, swap a1 and a2
    ble a1, a2, check3_a1_a3
    mv t3, a1
    mv a1, a2
    mv a2, t3
    
check3_a1_a3:
    # If a1 > a3, swap a1 and a3
    ble a1, a3, check3_a2_a3
    mv t3, a1
    mv a1, a3
    mv a3, t3
    
check3_a2_a3:
    # If a2 > a3, swap a2 and a3
    ble a2, a3, sort3_done
    mv t3, a2
    mv a2, a3
    mv a3, t3
    
sort3_done:
    ret

# Load fourth group data into registers s4, s5, s6
load_group4:
    lw s4, 0(a0)   # Load first number into s4
    lw s5, 4(a0)   # Load second number into s5
    lw s6, 8(a0)   # Load third number into s6
    ret

# Sort fourth group data (s4, s5, s6)
sort_group4:
    # If s4 > s5, swap s4 and s5
    ble s4, s5, check4_s4_s6
    mv t3, s4
    mv s4, s5
    mv s5, t3
    
check4_s4_s6:
    # If s4 > s6, swap s4 and s6
    ble s4, s6, check4_s5_s6
    mv t3, s4
    mv s4, s6
    mv s6, t3
    
check4_s5_s6:
    # If s5 > s6, swap s5 and s6
    ble s5, s6, sort4_done
    mv t3, s5
    mv s5, s6
    mv s6, t3
    
sort4_done:
    ret

# Function to print a string (via environment call)
print_string:
    li a7, 4       # System call number - print string
    ecall
    ret

# Function to print an integer (via environment call)
print_int:
    li a7, 1       # System call number - print integer
    ecall
    ret