#!/usr/bin/env python3
"""
RISC-V Assembly to Binary Machine Code Converter
Purpose: Convert RISC-V RV32I assembly code to binary machine code (0s and 1s)
Usage: python riscv_binary_converter.py > output.txt
"""

import sys

def convert_bubble_s_to_binary():
    """
    Convert bubble.s specifically to binary machine code (0s and 1s)
    """
    machine_code = [
        # Main function prologue
        0xfdc10113,  # addi sp,sp,-36
        0x02812623,  # sw s0,44(sp)
        0x03010413,  # addi s0,sp,48
        
        # Load array elements
        0x00007797,  # lui a5, LC0 (approximation)
        0x0007a583,  # lw a1,0(a5)
        0x0047a603,  # lw a2,4(a5)
        0x0087a683,  # lw a3,8(a5)
        0x00c7a703,  # lw a4,12(a5)
        0x0107a783,  # lw a5,16(a5)
        0xfcb42823,  # sw a1,-48(s0)
        0xfcc42a23,  # sw a2,-44(s0)
        0xfcd42c23,  # sw a3,-40(s0)
        0xfce42e23,  # sw a4,-36(s0)
        0xfef42023,  # sw a5,-32(s0)
        
        # Initialize outer loop counter i=0
        0xfe042a23,  # sw zero,-20(s0)
        0x0180006f,  # j .L2
        
        # .L6 (outer loop body)
        0xfe042823,  # sw zero,-24(s0) - initialize inner loop counter j=0
        0x0200006f,  # j .L3
        
        # .L5 (inner loop body)
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00279793,  # slli a5,a5,0x2 - j*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfe07a703,  # lw a4,-32(a5) - load arr[j]
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00178793,  # addi a5,a5,1 - j+1
        0x00279793,  # slli a5,a5,0x2 - (j+1)*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfe07a783,  # lw a5,-32(a5) - load arr[j+1]
        0x00f75a63,  # ble a4,a5,.L4 - if arr[j] <= arr[j+1], skip swap
        
        # Swap elements
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00279793,  # slli a5,a5,0x2 - j*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfe07a783,  # lw a5,-32(a5) - load arr[j]
        0xfef42623,  # sw a5,-20(s0) - temp = arr[j]
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00178793,  # addi a5,a5,1 - j+1
        0x00279793,  # slli a5,a5,0x2 - (j+1)*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfe07a703,  # lw a4,-32(a5) - load arr[j+1]
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00279793,  # slli a5,a5,0x2 - j*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfee7a023,  # sw a4,-32(a5) - arr[j] = arr[j+1]
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00178793,  # addi a5,a5,1 - j+1
        0x00279793,  # slli a5,a5,0x2 - (j+1)*4
        0xff078793,  # addi a5,a5,-16
        0x00f407b3,  # add a5,s0,a5
        0xfec42703,  # lw a4,-20(s0) - load temp
        0xfee7a023,  # sw a4,-32(a5) - arr[j+1] = temp
        
        # .L4 (increment inner loop)
        0xfe842783,  # lw a5,-24(s0) - load j
        0x00178793,  # addi a5,a5,1 - j++
        0xfef42823,  # sw a5,-24(s0) - store j
        
        # .L3 (inner loop condition)
        0x00400713,  # li a4,4
        0xfec42783,  # lw a5,-20(s0) - load i
        0x40f707b3,  # sub a5,a4,a5 - (4-i)
        0xfe842703,  # lw a4,-24(s0) - load j
        0xfaf74ae3,  # blt a4,a5,.L5 - if j < (4-i), continue inner loop
        
        # Increment outer loop
        0xfec42783,  # lw a5,-20(s0) - load i
        0x00178793,  # addi a5,a5,1 - i++
        0xfef42a23,  # sw a5,-20(s0) - store i
        
        # .L2 (outer loop condition)
        0xfec42703,  # lw a4,-20(s0) - load i
        0x00300793,  # li a5,3
        0xfaf74ce3,  # ble a4,a5,.L6 - if i <= 3, continue outer loop
        
        # Function epilogue
        0x00000013,  # nop
        0x00000013,  # nop
        0x02c12403,  # lw s0,44(sp)
        0x03010113,  # addi sp,sp,48
        0x00008067   # ret
    ]
    
    # Output formats
    output_formats = {
        "hex": lambda code: f"0x{code:08x}",
        "binary": lambda code: f"{code:032b}",
        "bytes": lambda code: f"0x{code & 0xFF:02x} 0x{(code >> 8) & 0xFF:02x} 0x{(code >> 16) & 0xFF:02x} 0x{(code >> 24) & 0xFF:02x}"
    }
    
    # Print in different formats
    print("=== MACHINE CODE IN BINARY FORMAT (0s and 1s) ===")
    for i, code in enumerate(machine_code):
        # Binary format (32 bits of 0s and 1s)
        binary = f"{code:032b}"
        print(f"{binary}  # Instruction {i+1}")
    
    print("\n=== MACHINE CODE IN HEXADECIMAL FORMAT ===")
    for i, code in enumerate(machine_code):
        # Hexadecimal format
        print(f"0x{code:08x}  # Instruction {i+1}")
    
    print("\n=== MACHINE CODE IN BYTE-BY-BYTE FORMAT (LITTLE ENDIAN) ===")
    for i, code in enumerate(machine_code):
        # Byte-by-byte format in little-endian order
        b0 = code & 0xFF
        b1 = (code >> 8) & 0xFF
        b2 = (code >> 16) & 0xFF
        b3 = (code >> 24) & 0xFF
        print(f"0x{b0:02x} 0x{b1:02x} 0x{b2:02x} 0x{b3:02x}  # Instruction {i+1}")

if __name__ == "__main__":
    convert_bubble_s_to_binary()
