import numpy as np
import numba
from numba import cuda, float32
import math

# GPU Kernel
@cuda.jit
def matrix_mult(A, B, C):
    tx = cuda.threadIdx.x
    ty = cuda.threadIdx.y
    x, y = cuda.grid(2)

    TPB = 16
    sA = cuda.shared.array(shape=(TPB, TPB), dtype=float32)
    sB = cuda.shared.array(shape=(TPB, TPB), dtype=float32)

    if x >= C.shape[0] or y >= C.shape[1]:
        return

    tmp = 0

    for i in range(0, A.shape[1], TPB):
        if i + tx < A.shape[1] and x < A.shape[0]:
            sA[ty, tx] = A[x, i + tx]
        else:
            sA[ty, tx] = 0

        if i + ty < B.shape[0] and y < B.shape[1]:
            sB[ty, tx] = B[i + ty, y]
        else:
            sB[ty, tx] = 0

        cuda.syncthreads()

        for j in range(TPB):
            tmp += sA[ty, j] * sB[j, tx]

        cuda.syncthreads()

    C[x, y] = tmp

# CPU Code
TPB = 16
A = np.random.random((15000, 15000)).astype(np.float32)
B = np.random.random((15000, 15000)).astype(np.float32)
C = np.zeros((15000, 15000), dtype=np.float32)

dA = cuda.to_device(A)
dB = cuda.to_device(B)
dC = cuda.device_array(C.shape, dtype=C.dtype)

blockspergrid_x = math.ceil(A.shape[0] / TPB)
blockspergrid_y = math.ceil(B.shape[1] / TPB)
blockspergrid = (blockspergrid_x, blockspergrid_y)
threadsperblock = (TPB, TPB)

matrix_mult[blockspergrid, threadsperblock](dA, dB, dC)
dC.copy_to_host(C)

print(C)

