#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "region.h" //region based allocator
#include "benchmark_params.h" //define parameters here
#include "list_lib.h" //list implementation

int main() {

    int bound = BENCHMARK_LIST_LENGTH;
    region* r = new_region();
    struct cell* l = range(bound,make_nil(),r);
    
    clock_t t = clock();
    for (int i = 0; i < BENCHMARK_NUM_ITERS; i++) {
	long m = list_max(0,l);
    }
    t = clock() - t;
    printf("list_max time: %ld\n", t);
    t = clock();
    for (int i = 0; i < BENCHMARK_NUM_ITERS; i++) {
	long m = list_length(0,l);
    }
    t = clock() - t;
    printf("list_length time: %ld\n", t);
    free_region(r);
    return 0;
}


