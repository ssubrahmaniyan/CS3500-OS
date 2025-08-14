// pingpong problem 
//

#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(int argc, char *argv[]){
  int p1[2], p2[2];
  char buf1[4], buf2[4];

  pipe(p1);
  pipe(p2);
  
  int n;
  if((n = fork()) == 0){// child here 
    close(p1[1]);
    close(p2[0]);

    read(p1[0], buf1, sizeof(buf1));
    printf("%d: received %s from parent\n", getpid(), buf1);

    close(p1[0]);

    write(p2[1], "Pong", 4);
    close(p2[1]);
    exit(0);
  }
  else{// parent here
    // closing unused ends of the two pipes
    close(p1[0]);
    close(p2[1]);
    // putting data on pipe 1
    write(p1[1], "Ping", 4);
    close(p1[1]);

    read(p2[0], buf2, sizeof(buf2));
    printf("%d: received %s from child\n", getpid(), buf2);
    close(p2[0]);
    wait(0);
    exit(0);
  }
}
