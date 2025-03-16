#include <stdint.h>
#include <stdio.h>

extern volatile uint32_t ParentThread; 
uint32_t Thread3Complete = 0; 
uint32_t currentPacketComplete = 0;


void Thread3(void);
void manipulate_payload(void);

void Thread3(void) {
    const uint32_t signalToStart = 0; 

    while(1) {
        if (ParentThread == signalToStart) {
            manipulate_payload();

            ParentThread = 0; 
            Thread3Complete = 1; 
            break; 
        }
    }
}

void manipulate_payload(void) {
    printf("Thread 3: Manipulating payload data.\n");

    uint32_t* payloadDataLocation = (uint32_t*)512; 
    uint32_t encodedValue;
    
    encodedValue = 4;

    *payloadDataLocation = encodedValue;
    
    printf("Payload manipulation completed.\n");

    currentPacketComplete = 1;
}


int main(void) {

    ParentThread = 0; 

    Thread3(); 
    
    return 0;
}
