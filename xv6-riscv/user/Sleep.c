#include "kernel/types.h"
#include "user/user.h"

// program to sleep for specified number of ticks 

int main(int argc, char * argv[]){
  if(argc != 2){
    fprintf(2, "incorrect calling\n");
    exit(1); //exit with error 
  }
  sleep(atoi(argv[1]));
  exit(0);
}
