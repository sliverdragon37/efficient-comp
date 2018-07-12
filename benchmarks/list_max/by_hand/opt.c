#include <stdio.h>
#include "region.h"


//in order to represent a list efficiently we're going to use the fact
//that pointers are always aligned to store the tag along with the pointer
#define NIL_TAG 0
#define CONS_TAG 1

struct cell {
    long data;
    struct cell* next;
};

/* #define TAG(l) (((long)(l)) & 0x1) */
/* #define REF(l) (((long)(l)) & (~0x1)) */
/* #define SFT(l) (((struct cell*)(REF(l)))->data) */
/* #define RST(l) (((struct cell*)(REF(l)))->next) */

long TAG(struct cell* l) {
    return (((long)l) & 0x1);
}

struct cell* REF(struct cell* l) {
    return (struct cell*)(((long)l) & (~0x1));
}

long FST(struct cell* l) {
    return (REF(l))->data;
}

struct cell* RST(struct cell* l) {
    return (REF(l))->next;
}

struct cell* make_nil() {
    return (struct cell*)NIL_TAG;
}


 struct cell* make_cons(long fst, struct cell* rst, region* r) {
    //make 16 byte heap cell
    struct cell* x = (struct cell*)allocate(r,sizeof(struct cell));
    //write fst to it
    x->data = fst;
    //write rst to it
    x->next = rst;

    struct cell* res = ((struct cell*) ( ((long) x) | CONS_TAG));
    return res;
	
}

struct cell* range(long bound, long curr, struct cell* acc, region* r) {
    struct cell* n = make_cons(curr,acc,r);
    if (curr >= bound){
	return n;
    } else {
	return range(bound,curr+1,n,r);
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
    
    region* r = new_region();
    
    struct cell* l = range(bound-1,0,make_nil(),r);
    printf("Made list l: %p\n", l);
    printf("FST(l) = %ld, RST(l) = %p\n", FST(l), RST(l));
    long m = list_max(0,l);
    printf("%max is: %ld\n", m);
    return 0;
}
