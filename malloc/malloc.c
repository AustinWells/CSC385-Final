#ifndef __linux__
#define NULL ((void*)(0))

void*
sbrk(unsigned int sz)
{
  if (__heap_bottom <= HEAP_SIZE) {
    return NULL;
  }
  __heap_bottom += sz;
  return (void*)(__heap_start) + (__heap_bottom);
}
extern union block* __heap_start;
#endif

#ifdef __linux__
#define malloc my_malloc
#include <unistd.h>
union block* __heap_start;
#endif

#include "malloc.h"

// offset from __heap_start, that the heap is current at
static unsigned int __heap_bottom = 0;

void
mem_init()
{
  __heap_start = sbrk(0);
  __heap_bottom = 0;
  __heap_start = 0;
}

/**
  splits the given block into 2 blocks, one of size sz
  and the other with the remaining size, returns pointer
  to the block of size sz(and removes it from freelist)
  returns null if block is too small
**/
Block*
split_block(Block* blk, unsigned int sz)
{
  if (blk->size < sz + sizeof(Block)) {
    return NULL;
  }
  blk->size = blk->size - (sz + sizeof(Block));
  if (blk->next) {
    blk->next->prev_size = blk->size;
  }
  return (Block*)(blk + (blk->size + sizeof(blk)));
}

Block* allocate_block(unsigned int sz){

  if(freep == NULL){
    freep = sbrk();
  }

  Block *curr = freep;
  //find end of freelist
  for(;curr->next != NULL;curr=curr->next){}

}


void*
malloc(unsigned int sz)
{

  Block* curr;
  for (curr = freep; curr != NULL; curr = curr->next) {
    // first fit TODO: improve algorithm
    if (curr->size == sz) {
      // found perfectly fit block
      curr->prev->next = curr->next;
      if (curr->next != NULL)
        curr->next->prev = curr->prev;
    }
    if (curr->size + sizeof(Block) > sz) {
      return split_block(curr, sz);
    }
  }
  return curr;
}

void
free(void* ptr)
{

  Block* curr = freep;

  for (; curr != NULL; curr = curr->next) {
    // found adjacent block, we should merge them
    if ((curr + curr->size) == ptr) {
      curr->size = curr->size + ((Block*)ptr)->size + sizeof(Block);
      if (curr->next != NULL) {
        curr->next->prev_size = curr->size;
      }
    }
  }
}

int
main()
{
  char* s;
  for (int i = 1; i < 100; i++) {
    s = malloc(i);
    printf("alloc: %d\n", i);
    for (int j = 0; j < i; j++) {
      printf("index: %d\n", j);
      s[j] = 'A';
    }
    free(s);
  }
  return 0;
}
