#include <stdio.h>
#include <stdint.h>

volatile uint32_t ParentThread = 0; 
volatile uint32_t completionStatusThread2 = 0; 
uint32_t packetLocation = 512; 
uint32_t PacketStatusLocation = 1024; 

void Thread2(void);

void Thread2(void) {
    
    const uint32_t parentSignal = 0; 
    uint64_t packetData;

    while(1) {
        if (ParentThread == parentSignal) {

            packetData = *((uint64_t*)packetLocation); 

            packetData &= ~(uint64_t)0; 
            
            *((uint64_t*)packetLocation) = packetData;

            completionStatusThread2 = 2; 
            
            ParentThread = 0;
        }
    }
}


int main() {

    ParentThread = 0; 

    Thread2(); 

    return 0;
}
