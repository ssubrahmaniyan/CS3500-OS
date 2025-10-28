#include "types.h"
#include "spinlock.h"
#include "file.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

#define NSHARED 64

struct shared_entry {
  struct file *f;
  uint64 offset;
  void *pa;
  int refcount;
};

static struct {
  struct spinlock lock;
  struct shared_entry entries[NSHARED];
} shared_registry;

void
shared_init(void)
{
  initlock(&shared_registry.lock, "shared_registry");
  for (int i = 0; i < NSHARED; i++) {
    shared_registry.entries[i].f = 0;
    shared_registry.entries[i].offset = 0;
    shared_registry.entries[i].pa = 0;
    shared_registry.entries[i].refcount = 0;
  }
}

struct shared_entry*
shared_find_or_create(struct file *f, uint64 offset, int create)
{
  acquire(&shared_registry.lock);

  for (int i = 0; i < NSHARED; i++) {
    struct shared_entry *e = &shared_registry.entries[i];
    if (e->f == f && e->offset == offset && e->refcount > 0) {
      e->refcount++;
      release(&shared_registry.lock);
      return e;
    }
  }

  if (create) {
    for (int i = 0; i < NSHARED; i++) {
      struct shared_entry *e = &shared_registry.entries[i];
      if (e->refcount == 0) {
        e->f = f;
        e->offset = offset;
        e->pa = kalloc();
        if (!e->pa) {
          release(&shared_registry.lock);
          return 0;
        }
        memset(e->pa, 0, PGSIZE);
        e->refcount = 1;
        release(&shared_registry.lock);
        return e;
      }
    }
  }

  release(&shared_registry.lock);
  return 0;
}

void
shared_decref(struct shared_entry *e)
{
  if (!e)
    return;

  acquire(&shared_registry.lock);
  if (--e->refcount == 0) {
    kfree(e->pa);
    e->pa = 0;
    e->f = 0;
    e->offset = 0;
  }
  release(&shared_registry.lock);
}

