#include "kernel/types.h"
#include "kernel/defs.h"

int main(){
  printf("Hi I am the parent\n");

  if(fork() == 0){
    printf("Hi I am the child\n");
    exit(0);
  }
  else {
    wait();
    printf("Child received\n");
  }
  return 0;
}
