# Operating Systems Notes

## xv6 booting process
- When power on reset is called, all registers are initialised to zero except PC=0x1000
- The qemu is programmed such that the instruction at 0x1000 is a jump to the location 0x80000000
### Machine mode 
- this location contains the _entry(entry.S) function 
- this function performs the basic tasks of setting up kernel stacks for each of the CPUs
- it then calls the start function on each of the cpu cores 
- the function of start(start.c) is to configure the cpus which are presently in machine mode to appear like they had entered here from the supervisor mode
- this would allow the mret instruction to be used to take the cpus to a specified entry point and simulataneously set the privilege level of the cpu to the supervisor mode
- in this function:
1. the previous privilege is set to supervisor mode using the mstatus register 
2. main is specified as the entry point through mepc. When mret is run, main runs 
3. paging is disabled as all of the further code run in kernel mode with direct mapping 
4. all interrupts are delegated to the supervisor mode as machine mode will not be used after booting
5. supervisor mode is given full access to all of the memory(can literally do anything with anything)
6. sets up the timer, loads the tp register on each cpu with the cpu id and calls mret

- mret brings the privilege level down to what is specfied in mstatus(supervisor level at the moment) and runs the code specified at the entry point in mepc, which is the main function

### Supervisor mode
- The main function runs in the supervisor mode and does the following:
1. initialises the console to access uart through the emulator 
2. initialises the printf functionality to permit printing of boot messages
3. calls kinit() which frees all pages from the end of the kernel code(specified in kernel.ld) all the way until PHYSTOP. the freeing is done by initialising all memory to 1(to catch dangling references) pagewise, and adding an entry to the freelist tracking the free memory. at the end of this process, all of the memory is available in freelist and ready to be used. note that no address translation was done as paging has been disabled.
4. calls kvminit() which creates the pagetable for the kernel. it first allocates a page of memory using kalloc() for the page table(all that kalloc does is it pulls the top entry from the freelist and removes it from that list, and returns the PHYSICAL ADDRESS of the start of the allocated page along with setting all memory in the page to 5 to help in debugging. then, the uart0, virtio, plic, kernbase, etext and trampoline are directly mapped on the kernel pagetables. the implication is this: because the kernel can directly access these using a direct-mapping, they can also use a kernel page table. this is done by walking the existing page table with the allocation setting turned on and thus making entries in the kernel page table for each of those things. the walk would in the end return the leaf page table entry which does not point to anything yet. now the leaf page table entry is set to hold the virtual address corresponding to the true physical address of each of those segments. then it calls proc_mapstacks() which maps the kernel stacks for each of the processes in locations below the trampoline(trapframe does not exist yet) guarded with pages. these entries are also installed in the kernel page table. note that each of the stack has a RW permission.
5. calls kvminithart() which turns on paging here on. it first uses the sfence_vma() to finish any previous writes to the page table memory, then put the physical address of the kernel page table in the satp register and again call sfence_vma to flush all entries from the TLB.
6. calls procinit() which initialises the process table. all that is done is each proc in the list proc[NPROC] is taken and its state is set to UNUSED. the PCB of each of the process is also updated with the locations of the kernel stack corresponding to the process(which are the direct physical addresses). these are also mapped correctly through the page tables as well. so using those address to access even when paging is turned on will work correctly.
7. calls trapinit() which just initialises the lock for ticks.
8. calls trapinithart() in which kernelvec is loaded onto each of the stvec registers. the stvec(supervisor trap vector register) holds the address of the code that must be executed when an interrupt or exception happens while in the supervisor mode.
9. it then calls plicinit(), plicinithart(), binit(), iinit(), fileinit() and virtio_disk_init() which initialise other requirements.
10. it finally calls userinit() which sets up the first user process. here, a new process is allocated with pid 1 for the init process. it is allocated a trapframe page, and the trapframe and trampoline pages are mapped on a newly allocated user page table for that process. the trapframe and pagetable locations are updated in the process, along with its pid and its state set to USED. finally the context of the process is updated with the return address to be forkret and the stack pointer holds the kernel stack for that process(top of the stack).
11. now the scheduler is run on each of the CPU. the scheduler will identify only one process in a runnable state and set it to running. it will set the context to the context of the runnable process(in this context switch, the scheduler's context, which is the values of the registers is stored in the CPUs context struct, while the new context of the process is loaded into the register). now because the ra is set to forkret, it runs. in the forkret, because it is the first time the process is called, the /init function is executed through the exec() system call. after this, the prepare_return() function is called to set the stvec register to trampoline_uservec. then the kernel registers(the satp, kernel stack pointer, kernel trap handler and thread pointer) are stored in the process' trapframe. note that trapframe is allocated in kernel space and is invalid in user space. these would be used in the trampoline handler to restore context about the kernel for handling the traps. after the the sstatus register is set to return to user mode, and the sepc is set to trapframe's epc which was recorded while the switch happened from user to supervisor. initially it is set to 0 where init will run. then the make_satp is done with process' page table's address which basically encodes the variable satp with the value of the base address. then the userret handler's address is loaded and the function is called with satp as its argument. here, the user page table is written into satp, so all further memory translations are done with the user page table. then the previous context is restored from the trapframe of the process and an sret is done. now epc points to 0 from where the init program runs. note that this was setup by the exec(/init) that is run when the first time forkret is called, which sets up the memory to be able to do this.
12. in init the shell is booted and runs forever waiting for inputs and actions.

## xv6 Trap handling process(from user space)
### User mode 
When a trap from user space happens, which is due to either an ecall instruction or an invalid operation(think, divide by zero) or a device interrupt. When such a trap happens, the CPU takes actions to perform some hardware operations. These include:
1. If the SIE bit in the sstatus bit is already disabled(no interrupts) and the exception is a device interrupt, do none of the following.
2. Clear the SIE bit otherwise to prevent interrupts in trap handling code.
3. Copy the pc to sepc. This will let us restore execution from where the trap happened after the handling.
4. save the current mode through in the SPP bit in the sstatus register.
5. set the scause register with the cause of the trap.
6. elevate the CPU's mode to supervisor.
7. copy uservec into pc.
8. continue executing from pc.
Note that changing the page tables or saving other registers are not done by this hardware. This is to allow maximum flexibility for the software to handle this the way it wants.

After these, the entry point would be uservec with the CPU in supervisor mode. In this part of the code(trampoline.S), the user registers are first stored into the trapframe. After this, the kernel_sp, kernel_tp, kernel_satp and the address of usertrap() are loaded from the process' trapframe. These were placed here when the process was created through the fork. Then the new page table is installed after a sfence instruction. From here on the system is in kernel mode.

### Kernel mode
Because epc was loaded with the address of usertrap(), that executes next. In usertrap(), the kernel checks if the trap started from the user space and otherwise panics. It then installs kernelvec into the stvec register. this is because traps when inside the kernel must be handled by a separate piece of code. Then, the sepc is copied into the trapframe of the process. Note that this is done only now because in user mode there is no access to the trapframe. this storing of the epc is required to be able to continue execution from where the code was interrupted. After this, the kernel identifies the cause of the interrupt and accordingly updates the epc if it was a system call(as then we must return to the instruction after the ecall). if this was a system call, it calls the syscall() function which further processes the system call. if it instead is a device interrupt(timer in our case), then the alarm functionality is run). if it wasnt either, then it flags it as unexpected.
If the interrupt was a timer interrupt, it further yields the cpu by setting itself to runnable and the scheduler handles it further. when it returns back to this code after the scheduling round, it prepares to return. for this, it again delegates all interrupts to uservec by writing it into stvec. then, it stores the kernel_sp, kernel_satp, kernel_trap and kernel_hartid into the trapframe, sets the previous privilege to user mode. finally, it loads the stored epc from the trapframe(which holds the user process instruction id) into the sepc, installs the user page table and returns to trampoline handler. 

here, an sfence is run to wait for tlb flushes and the new(user) satp is installed. then the registers are copied over from the trapframe in which they were stored and the sret intsruction is called. this jumps to sepc, which holds the user instruction that was interrupted and continues running.

