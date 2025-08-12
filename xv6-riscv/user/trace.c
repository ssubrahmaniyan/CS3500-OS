#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

// user.h provides prototype for trace
int main(int argc, char *argv[]){
  if(argc <= 2){
    fprintf(2, "Error! Use: trace <calls_to_trace> <process>\n");
    exit(1);
  }

  int n;
  if((n = trace(atoi(argv[1]))) == 0){ // proc is set
    close(1);
    exec(argv[2], argv+2); // run process to be traced
    exit(0);
  }
} 

