
all: opt_benchmark standard_benchmark

opt_lib.o: opt_lib.c list_lib.h
	$(CC) opt_lib.c -c -o opt_lib.o -O3

opt_lib.s: opt_lib.c list_lib.h
	$(CC) opt_lib.c -S -o opt_lib.s -O3

standard_lib.o: standard_lib.c list_lib.h
	$(CC) standard_lib.c -c -o standard_lib.o -O3

standard_lib.s: standard_lib.c list_lib.h
	$(CC) standard_lib.c -S -o standard_lib.s -O3

region.o: region.c region.h
	$(CC) region.c -c -o region.o -O3

main.o: main.c benchmark_params.h
	$(CC) main.c -c -o main.o -O3

opt_benchmark: region.o main.o opt_lib.o 
	$(CC) region.o main.o opt_lib.o -o opt_benchmark 

standard_benchmark: region.o main.o standard_lib.o 
	$(CC) region.o main.o standard_lib.o -o standard_benchmark

clean:
	rm -f standard_benchmark
	rm -f opt_benchmark
	rm -f *.o
