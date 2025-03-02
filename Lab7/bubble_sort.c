#include <stdio.h>
int main() {
   int arr[5] = {3, 2, 5, 1, 4};
   int len = 5;
   int i, j, temp;
   for(i = 0; i < len - 1; i++) {
       for(j = 0; j < len - i - 1; j++) {
           if(arr[j] > arr[j+1]) {
               temp = arr[j];
               arr[j] = arr[j+1];
               arr[j+1] = temp;
           }
       }
   }
   printf("Sorted array: ");
   for(i = 0; i < len; i++) {
       printf("%d ", arr[i]);
   }
   printf("\n");
   return 0;
}
