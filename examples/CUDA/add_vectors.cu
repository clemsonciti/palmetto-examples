#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <assert.h>

__global__ void add(int *a, int *b, int *c) {
    int idx = blockDim.x*blockIdx.x + threadIdx.x;
    c[idx] = a[idx] + b[idx];
    __syncthreads();
}


void random_ints(int* a, int N) {
    for (int i=0; i<N; i++){
        a[i] = rand() % 1000;
    }
}

#define N (2048*2048)
#define THREADS_PER_BLOCK 512

int main(){
    int *a, *b, *c;
    int *a_d, *b_d, *c_d;
    int size = sizeof(int)*N;

    cudaMalloc((void **) &a_d, size);
    cudaMalloc((void **) &b_d, size);
    cudaMalloc((void **) &c_d, size);

    // setup initial values:
    a = (int*)malloc(size); random_ints(a, N);
    b = (int*)malloc(size); random_ints(b, N);
    c = (int*)malloc(size);

    cudaMemcpy(a_d, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(b_d, b, size, cudaMemcpyHostToDevice);

    add<<<N/THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(a_d, b_d, c_d);
    cudaMemcpy(c, c_d, size, cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++)
        assert(a[i] + b[i] == c[i]);

    free(a); free(b); free(c);
    cudaFree(a_d);
    cudaFree(b_d);
    cudaFree(c_d);
}
