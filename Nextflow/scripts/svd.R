#https://rpubs.com/aaronsc32/image-compression-svd

if(!require("jpeg"))install.packages("jpeg")

args <- commandArgs(trailingOnly=TRUE)

#read in Tilman.png
tillman <- args[1]
tillman <- readJPEG(tillman)

#separate out color matricies
r <- tillman[,,1]
g <- tillman[,,2]
b <- tillman[,,3]

#perform svd
r.svd <- svd(r)
g.svd <- svd(g)
b.svd <- svd(b)

#recombine color matricies
tillman.svds <- list(r.svd,g.svd,b.svd)

#rebuild image
a <- sapply(tillman.svds, function(i){
                    tillman.compressed <- i$u[,1:45] %*% diag(i$d[1:45]) %*% t(i$v[,1:45])
}, simplify = 'array')

invert = max(a) - a

writeJPEG(invert, paste('tillman_svd.jpg', sep=''))
