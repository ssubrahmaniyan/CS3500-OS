# Practice problem takeaways
** Indicates that complete code has not been written on my own yet
\*  Indicates code is written on my own, but can be cleaned
## PingPong
The whole idea is to be able to write from one process into another process using pipes, read it and return it back using another pipe.
The solution idea is to create two pipes - one for parent to child and another for child to parent.
`fork()` is used to create the child process.
Closing unused descriptors, connecting pipe ends to file descriptors and waiting for the child are concepts covered.

## Find**
The solution is very similar to what ls.c uses to list all the files in the directory.
The solution can infact be made by simply modifying the ls function a little.
The process is to start with a path, open a file descriptor to the path, and then stat it.
Stating a file descriptor provides the `stat` struct, holding metadata about the file/directory/device
If the `stat.type` is a file, check if it matches target and print.
If it is a directory, create a path to the contents of the directory and iterate over it. 
Recursively call find again with new paths to find the target directory.

## Xargs*
The idea is basically to read inputs from STDIN which are piped to the command that is being Xarged.
Very simple implementation.

