#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

uint32_t stateVariable = 0;
uint32_t readPointer = 0;
uint32_t currentPacketComplete = 0;
uint32_t ParentThread = 0;

extern uint32_t Thread1Complete;
extern uint32_t Thread2Complete;
extern uint32_t Thread3Complete;

void Thread0(void);

void Thread0(void) {

    const uint32_t desiredState = 3;
    const uint32_t udpProtocol = 17;

    while (1) {
        if (stateVariable == desiredState) {
            if ((readPointer & 0xFF) == udpProtocol) {
                ParentThread = 0;

                while (Thread1Complete == 0 || Thread2Complete == 0 || Thread3Complete == 0) {
                    sleep(1);
                }

                printf("Thread 0: All child Threads completed their tasks.\n");
                currentPacketComplete = 1;

                Thread1Complete = Thread2Complete = Thread3Complete = 0;
                ParentThread = 0;
            }
        }

        sleep(1);
    }
}


int main(void) {

    Thread0();
    
    return 0;
}
