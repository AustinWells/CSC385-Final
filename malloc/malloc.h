#ifndef MALLOC_H
#define MALLOC_H

#define HEAP_SIZE (0x803FFFF - 0x8000000)

union block
{
  struct
  {
    union block* next;
    unsigned int size;
    union block* prev;
    unsigned int prev_size;
  };
  long x; // force blocks to be at least sizeof(long)
};

// assert(sizeof(long) % 4, "BAD, MISALIGNED BLOCKS");

typedef union block Block;

// base address for the heap
static union block base;
// linked list to free blocks
static union block* freep = NULL;

#ifdef __cplusplus
extern "C"
{
#endif

  void* malloc(unsigned int nbytes);
  void free(void* ptr);

#ifdef __cplusplus
};
#endif

#endif /* MALLOC_H */
