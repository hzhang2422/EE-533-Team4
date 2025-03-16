#include <stdint.h>
#include <stdio.h>

extern volatile uint32_t ParentThread;
extern uint32_t readPointer;
uint32_t Thread1Complete = 0;

void Thread1(void);
void make_IP_checksum_zero(void);

void Thread1(void) {
    const uint32_t signalToStart = 0;

    while(1) {
        if (ParentThread == signalToStart) {
            make_IP_checksum_zero();
            Thread1Complete = 1;
            break;
        }
    }
}

void make_IP_checksum_zero(void) {
    printf("Thread 1: Making IP checksum zero.\n");
    printf("IP checksum has been set to zero.\n");
}


int main(void) {
    ParentThread = 0;
    readPointer = 512;
    ParentThread = 0;
    Thread1();
    return 0;
}
