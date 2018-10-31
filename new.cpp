#include "malloc.h"

void* operator new(unsigned size)
{
  return malloc(size);
}

void* operator new[](unsigned size)
{
  return malloc(size);
}

void* operator new(unsigned size, void* ptr)
{
    return ptr;
}

void* operator new[](unsigned size, void* ptr)
{
    return ptr;
}

void operator delete(void* ptr)
{
  if(ptr){free(ptr);}
}

void operator delete[](void* ptr)
{
  if(ptr){free(ptr);}
}
