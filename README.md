# CS3500 - OPERATING SYSTEMS
Notes, assigments and solutions for operating systems course in Jul-Nov 2025

To run the code, follow these steps:
1. Pull a docker image of the riscv tools using the command
`docker pull svkv/riscv-tools:v1.0`
2. Run the docker image using
`docker run -it svkv/riscv-tools:v1.0`
3. Run the xv6 OS(along with the modifications done by me) using
`docker run -it -v
<path to xv6-riscv in your host system>/xv6-riscv:/home/os-iitm/xv6-riscv
svkv/riscv-tools:v1.0`
4. Inside the docker, run
`make clean && make qemu`
to boot into the OS in a qemu simulated environment

## Comments on repo structure
This repository(CS-3500) was initially used as the primary workspace and thus has multiple branches and merges. In due course of time, I have realised that using a submodule for the xv6-riscv repository would allow me to have multiple workflows there, but have a linear flow here. From after assignment 2, this repository is kept linear with just one branch. This means I update the commit pointer to the xv6-riscv repo here only when a meaningful milestone(completion of one assignment) is done, where I merge and update the inner repository as well. Cheers!

** All solutions can be found in dedicated folders inside the labs/ directory. The submodules also contain the changes. All assignment specifications as provided are in weekX_spec.pdf files**

## Assignment 1
Includes:
1. Boot the xv6 operating system on a qemu enviroment and print a hello world message.
The code to perform the required system calls is written with riscv assembly and can be found in (./xv6-riscv/user/HelloWorld.S)[HelloWorld.S]
The message can be printed by running `HelloWorld` on the xv6 shell.

## Assignment 2
Includes:
1. Add trace system call and kernel backtrace.
The programs for the same are found in the appropriate files. They can be tested with the `trace` command, and by running `bttest`

## Assignment 3
Includes:
1. Printing page table entries in a readable format along with physical page mappings,
2. Speeding up the getpid() system call using a page shared between the user and the kernel address spaces that contains process metadata,
3. Adding a pageaccess() system call to identify the pages that have been accessed(dirtied) in a given range of pages.
All appropriate programs are found in the folder for week3. Process to run and test the functionality along with observed outputs are documented in the report.

## Assignment 4
Includes:
1. Using user-level interrupts to periodically alert(alarm) a running process.
2. Using a system call to permit the interrupted process to continue execution after the alarm.
Programs can be found in the folder for week4. Execution flow and observed outputs are logged in the report.

## Assignment 5
Includes:
1. Extending the fork system call to support Copy-On-Write(COW) forking, leading to large savings in unnecessary memory copying during forking.
Programs can be found in the folder for week5. Results and key implementation details are logged in the report.

## Assignment 6
Includes:
1. Implement the receive and transmit functionality with the circular memory buffer for the E1000 network interface card's device driver.
Programs can be found in the folder for week6. Results and key implementation details are logged in the report.

## Assignment 7
Includes:
1. Adding mmap and munmap system calls to support memory operations on other virtual memory areas(VMAs).
Programs can be found in the folder for week7. Results and key implementation details are logged in the report.
