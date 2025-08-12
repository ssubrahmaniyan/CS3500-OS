#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

int main(){
  // this creates a file and writes something to it 
  char* message = "this is so cool";
  int fd = open("out.txt", O_CREATE | O_WRONLY);
  printf("Obtained fd handle %d\n", fd);
  write(fd, message, 32);
  exit(0);
}
