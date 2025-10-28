# Implementing Copy On Write in xv6

The idea of COW is to not always copy all memory from parent to child when a process forks.
This is because a lot of that memory is freed anyway and is thus not good for performance.
The idea of COW is to allow multiple processes to hold references to the same physical pages, albeit with read-only permissions.
When a process wishes to write something to one of such shared pages, a new copy with the same contents is made for the process.

