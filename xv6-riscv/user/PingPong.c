#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(){
// ping pong a message

  int p1[2];
  int p2[2];
  pipe(p1);
  pipe(p2);
  
  char buf1[64];
  char buf2[64];

  // in parent space 
  printf("Parent: sending message: Hi!\n");
  close(0);
  dup(p1[1]);
  write(0, "Hi!\n", 4);
  
  // close the unused ends
  if(fork() == 0){
    // child space
    close(0);
    dup(p1[0]);
    read(0, buf1, 4);
    printf("Child: received message: %s", buf1);
    close(0);
    dup(p2[1]);
    printf("Child: sending message: %s", buf1);
    write(0, buf1, 4);
    exit(0);
  }
  else{
    wait(0);
    close(0);
    dup(p2[0]);
    read(0, buf2, 4);
    printf("Parent: received message: %s", buf2);
    exit(0);
  }
}
