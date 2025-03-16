# Thread0: Initialization and check current status
# Thread1: Modified the IPv4 Datagram Header checksum to 0
# Thread2: Modified the UDP Header checksum to 0
# Thread3: Modified the UDP payload to 4


# Memory location 1: mode
	# mode 0 - instruction read
	# mode 1 - instruction write
	# mode 2 - data read
	# mode 3 - data write
	# mode 4 - CPU execute
# Memory location 2: segment of the packet which needs to be manipulate
# Memory location 3: flag of end of current packet processing
# Memory location 4: flag of end of thread 1, set to 1 when thread 1 complete
# Memory location 5: flag of end of thread 2, set to 2 when thread 2 complete
# Memory location 6: flag of end of thread 3, set to 3 when thread 3 complete
# Memory location 7: flag of current executing thread

# Each thread has a seperate register file which contains 8 register from x0 to x7
# Each thread shared a same data memory.

# Thread0
sd x0 7(0)
li x1 6 # 1+2+3
.waitForStart:
## If the CPU is ready to execute
 ld x2 1(zero)
 li x3 4
 blt x3 x2 .waitForStart

##load the header
 ld x4 1(zero)
 addi x5 x4
 ld x6 0(x5)
 andi x6 x6 255
 li x7 17
 beq x7 x6 .findUDPPacket
 j .currentPacketComplete

.findUDPPacket:
 li x1 0
.waitForComplete:
 sub x1 x1 a5
 sub x1 x1 s7
 sub x1 x1 t6
 beq x1 x0 .currentPacketComplete
 j.waitForComplete 

.currentPacketComplete:
 sd 0 4(0) 
 sd 0 5(0)
 sd 0 6(0)
 sd 0 7(0)
 sd 1 3(0)
 j.waitForStart

 # Thread 1
 ld x1 7(0)
 li x2 1
.waitForStart1:
 beq x1 x2 .modifiedIPHeader
 j.waitForStart1

.modifiedIPHeader:
# Make the upper 16 bits into all 1 and then use and to mask
 ld x1 2(zero)
 addi x1 x1 4
 ld x2 0(x1)
 li x3            
 slli x3 x3 39
 addi x3 x3 -1
 and x2 x2 x3
 sd 1 4(0)
 j.waitForStart1
 
# Thread 2
 ld x1 7(0)
 li x2 2
.waitForStart2:
 beq x1 x2 .modifiedUDPHeader
 j.waitForStart2

.modifiedUDPHeader:
# Make the upper 16 bits into all 1 and then use and to mask
 ld x1 2(zero)
 addi x1 x1 4
 ld x2 0(x1)
 li x3            
 slli x3 x3 39
 addi x3 x3 -1
 and x2 x2 x3
 sd 2 5(0)
 j.waitForStart2

 # Thread 3
 ld x1 7(0)
 li x2 3
.waitForStart2:
 beq x1 x2 .modifiedUDPPayload
 j.waitForStart2
 
.modifiedUDPPayload:
# Modified the payload into 4
 ld x1 2(zero)
 addi x2 x0 4
 sd x2 0(x1)
 sd 3 6(0)
 j.waitForStart2