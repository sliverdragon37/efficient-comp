#include "list_lib.h"

//in order to represent a list efficiently we're going to use the fact
//that pointers are always aligned to store the tag along with the pointer

/* Begin Interesting Bits */
struct cell {
    char tag;
    long data;
    struct cell* next;
};

#define TAG(l) ((l) ? (l)->tag : NIL_TAG)
#define REF(l) (l)
#define FST(l) (((struct cell*)(REF(l)))->data)
#define RST(l) (((struct cell*)(REF(l)))->next)

inline struct cell* make_cons(long fst, struct cell* rst, region* r) {
    //make 16 byte heap cell
    struct cell* res = (struct cell*)allocate(r,sizeof(struct cell));
    //write fst to it
    res->data = fst;
    //write rst to it
    res->next = rst;

    //store the tag in the struct with the pointer
    res->tag = CONS_TAG;
    
    return res;
	
}
/* End Interesting Bits */

struct cell* range(long curr, struct cell* acc, region* r) {
    struct cell* n = make_cons(curr,acc,r);
    if (curr <= 0){
	return n;
    } else {
	return range(curr-1,n,r);
    }
}

long max(long a, long b) {
    return a>b ? a : b;
}

long list_max(long curr, struct cell* l) {
    switch (TAG(l)) {
    case NIL_TAG:
	return curr;
	break;
    case CONS_TAG:
	return list_max(max(FST(l),curr),RST(l));
	break;
    }
    return 0;
}

long list_length(long curr, struct cell* l) {
    switch (TAG(l)) {
    case NIL_TAG:
	return curr;
	break;
    case CONS_TAG:
	return list_length(1+curr,RST(l));
	break;
    }
    return 0;
}

/* inline struct cell* malloc_make_cons(long fst, struct cell* rst, region* r) { */
/*     //make 16 byte heap cell */
/*     struct cell* res = (struct cell*)malloc(sizeof(struct cell)); */
/*     //write fst to it */
/*     res->data = fst; */
/*     //write rst to it */
/*     res->next = rst; */
/*     res->tag = CONS_TAG; */
/*     return res; */
	
/* } */

/* struct cell* malloc_range(long curr, struct cell* acc, region* r) { */
/*     struct cell* n = malloc_make_cons(curr,acc,r); */
/*     if (curr <= 0){ */
/* 	return n; */
/*     } else { */
/* 	return range(curr-1,n,r); */
/*     } */
/* } */

