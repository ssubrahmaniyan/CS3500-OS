# Concurrency

Required to permit multi-threaded applications to run without problems. Nicely summmarised as the case where there are a lot of peaches and a lot of people. If there was no order or protocol, a bunch of people are going to reach for the same peach and lead to inefficient distribution. 

The operating system itself is also a multi-threaded application and it needs to carefully handle shared resources like memory. It also must support multi-threaded applications with appropriate primitives to ensure proper and efficient processing.

## Introduction

Threads are like processes, but with shared address spaces. One thread can access the memory space of another thread of the same process.
Each thread has its own context - separate program counter to fetch and execute instructions and registers for processing. To run different threads on a CPU core, context switches between the threads is done. This is very similar to process context switches, except that a new page table is not installed for threads of the same process.
Each thread has its own stack for working on data. Thread level data is then in thread-local storage. This causes a problem where stacks and heaps cannot grow nicely from opposing sides, but stacks are usually small and fixed in size so nevermind.

### Why use threads?
1. for SIMD operations use all the cpus together
2. can basically make use of times like IO blocked intervals to perform operations inside the specific process only.

The important idea then is that you need multiple processes only when they perform logically exclusive operation and require no sharing of data.

results of multi-threaded applications may be non-deterministic if not implemented properly.
two threads which add 100 one at a time to a counter may not always produce 200 at the end of both the runs.
this could be because the critical section where the memory location is read into the register, updated and stored back may be interrupted by another thread causing violations in the execution result. this causes the indeterminancy. the part of code which must necessarily never be concurrently accessed by multiple threads is called critical section(part of code that accesses a shared resource) and blocking such accesses is called mutual exclusion. 

data race is when two threads enter critical section at nearly the same time, both updating a common shared resource leading to unpredictable and wrong outcomes.
when the program contains race conditions, the output is non-deterministic. mutex primitives can guarantee that races are removed and only one thread can ever enter a critical section.

atomic operations can solve this problem - they do all or nothing (come on you spurs) - the whole problem can be solved if the isa provided an instruction which performed the whole critical section in one atomic operation. but this would be inefficient. the hardware then provides other useful instructions and we build synchronisation primitives, which together help us solve the synchrony problem.

all kernel data structures must have mutual exclusion primitives supported - page tables, process lists, files systems etc.

## Thread API 
POSIX threads pthreads library provides the pthread_create function. It takes as arguments:
1. a structure of type pthread_t which can store metadata about the thread.
2. attributes for the thread - scheduling priority, stack size etc. Separately initialized with another function.
3. a function pointer to the thread function.
4. the arguments to the thread function.

In most cases, the function pointer is defined as a void*, the return type as void* and the arguement type as void*. This allows the use of any data type by simply casting it to the appropriate data type.

The return values of the thread function must necessarily be allocated on the heap and returned. Returning values on the stack would lead to nonsense as the thread-local stack space is deallocated after the thread is run executing. So it is always good practice to first allocate space for the variable on the heap and return it in it. 

the pthread_join function makes the main thread wait for a thread to complete.

### pthread mutexes
pthread library also provides mutexes for critical sections that are accessed by multiple programs. the locks must be properly initialized and acquired and released carefully around the critical section. when the lock is done being used, it must also be destroyed. 

it is recommended to use the functions along with wrappers that check for clean and error free exits. pthread lock acquire can be done in busy-wait, try-once and timeout versions, which can be chosen based on preference.

**FOLLOW BASIC RULES WHILE WRITING MULTITHREADED CODE**

## Locks 
POSIX threads library uses locks/mutexes as the standard case for providing mutual exclusion. 
Locks have two methods - lock() and unlock().
a lock can be held by only one thread at a time.
if another thread attempts to acquire a lock that is being held by another process, it just 'spins' and waits for it to be freed. 
a fine-grained locking approach involves using multiple different locks to control access to different data structures/critial sections.
a coarse-grained locking approach is to have one global lock that ensures mutual exclusion.
locks may hold other info such as the thread that is holding it, how  long it has been held - all of which are usually hidden from the user.

#### Criteria to evaluate locks 
1. provide mutual exclusion
2. ensure fairness and prevent starvation among contending threads
3. performance overheads - are they significant when there is no contention at all? are the problematic when there is a lot of contention?

##### disabling interrupts 
1. for single-processor systems, interrupts can be disabled before the critical section and enabled after - no interruption in between means the critical section is atomic
2. has many problems - you have to trust the user developer to perform privileged instructions controlling interrupts - can be malicious - does not work on multiprocessor systems because even if interrupts were disabled in one processor, another thread could run on another - interrupts could be missed and lead to errant system state when interrupts are disabled for long periods.

##### single flag control 
1. does not provide mutual-exclusion - context switches can happen after the spinning loops in both the cases, two processes acquire the lock and use the critical section at the same time.
2. performance issues - spin waiting wastes a lot of time - specially on uniprocessor where the waiting process unnecessarily stalls the cpu until a context switch occurs.

##### single flag control spin locks with test and set atomic primitives 
1. the same system above can be made to provide mutual exclusion correctly when the test and set atomic exchange is used in the spinning loop. 
2. there is no way for two threads to then enter the critical section at the same time 
3. performance issues still persist - spin locks waste a lot of time - worse yet, if the uniprocessor system does not have a pre-emptive scheduler the spinning process may never leave the cpu and monopolize it. 

performance analysis:
1. guarantees mutual exclusion due to the atomicity of the checks
2. provides no guarantee about fairness for the most simple implementation - there is a possibility that one of the threads just spins forever
3. performance overheads are huge in uniprocessor systems(especially if the scheduler is going to cycle through all possible processes before coming back to this after an interruption). on multiprocessor systems the wait time is relatively lower.

##### single flag control with compare and swap 
1. very similar to test and set for simple locking purposes.
2. can provide extra features such as lock-free synchronisation.


##### load linked and store conditional 
1. very similar to the above as well. no guarantee on the atomicity of the load and store operations - can drastically simplify microarchitecture and speed. after a load verifies that the lock is free, a store(to acquire the lock) can only occur if there has been a guarantee that no one else has accessed that memory location again(provided by hardware). 

##### ticket lock 
1. uses an idea of tickets and turns. everytime someone wants to acquire a lock, they read the present ticket and increment its value. the present ticket is the process's turn. 
2. when the turn reaches a value matching that of a process, the process runs.
3. during unlocking, the turn variable is incrmemented.
4. this is slightly better than the other implementations because of the gurantee of progress - if a process gets a ticket, it will definitely run.

##### yield when cannot get lock
1. resource(cpu time) wastage can be reduced by yielding the cpu when an attempt is made to get a lock but is unable to acquire - lets the other processes take over and finish their execution and free the lock - better than sleep locks, yet can have too much overhead - for 100 processes, there would be 100 context switches(yields) and an immense waste of time.

##### queues 
All of the methods above(except the ticketing version) leave a lot to chance - there may be wrong decisions made by the scheduler which can lead to either a spin wait or sleep wait of a wrong process. Instead, a queue of processes is maintained, and when a process releases its lock, it only wakes up the process that is at the front of the queue and ready to acquire the lock next. 
