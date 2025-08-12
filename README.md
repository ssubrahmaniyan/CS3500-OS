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
