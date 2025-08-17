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

## Assignment 1
Boot the xv6 operating system on a qemu enviroment and print a hello world message.
The code to perform the required system calls is written with riscv assembly and can be found in (./xv6-riscv/user/HelloWorld.S)[HelloWorld.S]
The message can be printed by running `HelloWorld` on the xv6 shell.

## Assignment 2
Add trace system call and kernel backtrace.
The codes for the same are found in the appropriate files. They can be tested with the `trace` command, and by running `bttest`


