#import libraries
import numpy as np
import numba as numb
import nvidia_smi
import math
from numba import cuda, float32

#gpu code - note not optimized will get numba warning message

@cuda.jit
def matrix_mult(A,B,C):
    tx = cuda.threadIdx.x
    ty = cuda.threadIdx.y
    bw = cuda.gridDim.x
    pos = tx + ty * bw

    x,y = cuda.grid(2)

    sA = cuda.shared.array(shape=(TPB,TPB), dtype=float32)
    sB = cuda.shared.array(shape=(TPB, TPB), dtype=float32)

    if x >= C.shape[0]:
        return
    tmp = 0
    #Matrix multiplication
    for i in range(bw):
        sA[tx,ty] = A[x,ty + i *TPB]
        sB[tx,ty] = B[tx + i * TPB, y]
        cuda.syncthreads()
        for j in range(TPB):
            tmp += sA[tx,j] * sB[i,ty]
        cuda.syncthreads()
    C[x] = tmp


#cpu code
TPB = 64
A = np.random.random((1500,1500))
B = np.random.random((1500,1500))
C = np.zeros((1500))

blockspergrid = math.ceil(A.shape[0]/TPB)
matrix_mult[blockspergrid, TPB](A,B,C)
print(C)
