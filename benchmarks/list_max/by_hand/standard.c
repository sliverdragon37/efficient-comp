#include <stdio.h>
#include <stdlib.h>
#include "region.h"


//in order to represent a list efficiently we're going to use the fact
//that pointers are always aligned to store the tag along with the pointer
#define NIL_TAG 0
#define CONS_TAG 1

struct cell {
    char tag;
    long data;
    struct cell* next;
};

#define TAG(l) ((l) ? (l)->tag : NIL_TAG)
#define REF(l) (l)
#define FST(l) (((struct cell*)(REF(l)))->data)
#define RST(l) (((struct cell*)(REF(l)))->next)
#define make_nil() ((struct cell*)(NIL_TAG))

/* long TAG(struct cell* l) { */
/*     return (((long)l) & 0x1); */
/* } */

/* struct cell* REF(struct cell* l) { */
/*     return (struct cell*)(((long)l) & (~0x1)); */
/* } */

/* long FST(struct cell* l) { */
/*     return (REF(l))->data; */
/* } */

/* struct cell* RST(struct cell* l) { */
/*     return (REF(l))->next; */
/* } */

/* struct cell* make_nil() { */
/*     return (struct cell*)NIL_TAG; */
/* } */


inline struct cell* make_cons(long fst, struct cell* rst, region* r) {
    //make 16 byte heap cell
    struct cell* res = (struct cell*)allocate(r,sizeof(struct cell));
    //write fst to it
    res->data = fst;
    //write rst to it
    res->next = rst;
    res->tag = CONS_TAG;
    
    return res;
	
}

struct cell* range(long curr, struct cell* acc, region* r) {
    struct cell* n = make_cons(curr,acc,r);
    if (curr <= 0){
	return n;
    } else {
	return range(curr-1,n,r);
    }
}

inline struct cell* malloc_make_cons(long fst, struct cell* rst, region* r) {
    //make 16 byte heap cell
    struct cell* res = (struct cell*)malloc(sizeof(struct cell));
    //write fst to it
    res->data = fst;
    //write rst to it
    res->next = rst;
    res->tag = CONS_TAG;
    return res;
	
}

struct cell* malloc_range(long curr, struct cell* acc, region* r) {
    struct cell* n = malloc_make_cons(curr,acc,r);
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

int main() {

    int bound = 100000000;
    //int bound = 2000000;
    
    
    for (int i = 1; i < 11; i++) {
	region* r = new_region();
	struct cell* l = range(bound-i,make_nil(),r);
	long m = list_max(0,l);
	printf("%ld\n", m);
	free_region(r);
    }
    return 0;
}
