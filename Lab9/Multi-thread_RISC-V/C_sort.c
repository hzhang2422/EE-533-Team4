
#include <stdio.h>

void sortThreeNumbers(int *a, int *b, int *c) {
    int temp;
    if (*a > *b) {
        temp = *a;
        *a = *b;
        *b = temp;
    }
    if (*a > *c) {
        temp = *a;
        *a = *c;
        *c = temp;
    }
    if (*b > *c) {
        temp = *b;
        *b = *c;
        *c = temp;
    }
}

int main() {
    int group1[3] = {45, 23, 78};
    int group2[3] = {9, 32, 17};
    int group3[3] = {63, 41, 22};
    int group4[3] = {50, 50, 30};
    
    sortThreeNumbers(&group1[0], &group1[1], &group1[2]);
    sortThreeNumbers(&group2[0], &group2[1], &group2[2]);
    sortThreeNumbers(&group3[0], &group3[1], &group3[2]);
    sortThreeNumbers(&group4[0], &group4[1], &group4[2]);
    return 0;
}