#ifndef MALLOC_H
#define MALLOC_H

union word {
  struct {
    union word *next;
    unsigned int size;
  } s;
  long x;
};

typedef union header Header;

static union word base;
static union word *freep;

#ifdef __cplusplus
extern "C" {
#endif

	void *malloc(unsigned int nbytes);
	void free(void *ptr);

#ifdef __cplusplus
};
#endif

#endif /* MALLOC_H */
