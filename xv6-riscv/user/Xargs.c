#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/param.h"

int main(int argc, char *argv[]){
  char *args[MAXARG];
  char argstore[MAXARG][64]; // storage for piped args

  // copy command and optional args
  args[0] = argv[1];
  int i;
  for(i = 2; i < argc; i++){
    strcpy(argstore[i-1], argv[i]);
    args[i-1] = argstore[i-1];
  }
  i = i - 1; // index where piped args will start

  //  read from stdin
  char buf;
  char argbuf[64];
  int ind = 0, n;

  while((n = read(0, &buf, sizeof(buf))) == sizeof(buf)){
    if(buf == '\n' || buf == ' '){
      if(ind > 0){
        argbuf[ind] = '\0';
        strcpy(argstore[i], argbuf);
        args[i] = argstore[i];
        i++;
        ind = 0;
      }
    } else {
      argbuf[ind++] = buf;
    }
  }

  // leftover arg if no newline at EOF
  if(ind > 0){
    argbuf[ind] = '\0';
    strcpy(argstore[i], argbuf);
    args[i] = argstore[i];
    i++;
  }

  args[i] = 0; // null terminate pointer array

  // exec
  if(fork() == 0){
    exec(argv[1], args);
    exit(0);
  } else {
    wait(0);
    exit(0);
  }
}

