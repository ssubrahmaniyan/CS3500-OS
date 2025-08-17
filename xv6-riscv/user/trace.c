#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

void main(int argc, char *argv[]){
  if(argc <= 2){
    fprintf(2, "Usage: trace <mask for calls to trace> <command to run>\n");
    exit(1);
  }

  int n;
  if((n = trace(atoi(argv[1]))) == 0){// trace mask set correctly
    // close(1); // close stdout to only display trace outputs
    exec(argv[2], argv+2); // run process to trace
    exit(0);
  }
}

