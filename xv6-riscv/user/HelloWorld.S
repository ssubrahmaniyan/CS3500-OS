.global main    // effectively makes this function available to the compiler and linker

main:   li a0, 1        // choosing stdout(display) as the file descriptor
        la a1, saddr    // pointer to the string to be printed
        li a2, 34       // length of the printed string
        li a7, 16       // index for the write sys call
        ecall           // changes the privilege of the cpu to handle the syscall

        li a0, 0        // return status for the exit syscall - 0 for success
        li a7, 2        // index for the exit sys call
        ecall

.data   // directive to place the string in data memory
saddr:     .ascii "Hello EE23B102! Welcome to CS3500\n"
// string to be printed, in ascii format
