% size of the matrix
n=10;

% create a random matrix 
A = rand(n);

% symmetrize matrix 
B = A*A';

% singular value decomposition of B
D=svd(B);

% print D
D

exit

