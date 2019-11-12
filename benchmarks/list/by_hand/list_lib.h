#ifndef LIST_MAX_H_INCLUDED
#define LIST_MAX_H_INCLUDED 1

#include "region.h"

#define NIL_TAG 0
#define CONS_TAG 1

struct cell;

struct cell* range(long curr, struct cell* acc, region* r);
long list_max(long curr, struct cell* l);

#define make_nil() ((struct cell*)(NIL_TAG))

long list_length(long curr, struct cell* l);

#endif
