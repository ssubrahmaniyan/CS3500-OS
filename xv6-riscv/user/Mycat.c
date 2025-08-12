// custom implementation of cat program
//
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

char buf[256]; // buffer to store data read before printing out

void cat(int fd){
  // reads all data from the file descriptor and prints it out
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0){// the read is not end of file
    if(write(1, buf, n) != n){
      fprintf(2, "cat: writing error\n");
      exit(1);
    }
  }
  if(n < 0){
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}

int main(int argc, char *argv[]){
  // need to do the same cat functionality on every argument that is passed 
  
  if(argc <= 1){ // argc = 0 is not possible, when 1 keep printing input until kill
    cat(0);
    exit(0);
  }
  
  int fd;

  for(int i = 1; i < argc; i++){ // all values of i from 1 to argc - 1 are files to perform cat on
    if((fd = open(argv[i], O_RDONLY)) < 0){
      fprintf(2, "cat: file open error\n");
      exit(1);
    }
    cat(fd);
    close(fd); // close file descriptors whenever they are opened
  }
  exit(0);
}
