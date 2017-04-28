library(dplyr)
library(RSpectra)

pkg <- read.csv('../../Data/package.csv', stringsAsFactors = FALSE)
npkgs <- nrow(pkg)

pkgfn <- read.csv('../../Data/package_function.csv', stringsAsFactors = FALSE) %>%
    filter(is_conflict == 1)

pkgmat <- matrix(0, npkgs, npkgs)
rownames(pkgmat) <- pkg %>% select(package_id) %>% as.matrix %>% as.vector
colnames(pkgmat) <- pkg %>% select(package_id) %>% as.matrix %>% as.vector

conflist <- pkg %>% select(package_id) %>% as.matrix %>% as.vector %>% as.list
conflist <- lapply(conflist, function(x){
    filter(pkgfn, package_id == pkg$package_id[x]) %>%
        select(function_id) %>% as.matrix %>% as.vector
})

## matrix is symmetric
for(i in 1:(nrow(pkgmat)-1)){
    print(i)
    for(j in (i+1):nrow(pkgmat)){
        pkgmat[i,j] <- length(intersect(conflist[[i]], conflist[[j]]))
    }
}

## add the transpose to get the lower triangular of the matrix
## this is a symmetric matrix
pkgmat <- pkgmat + t(pkgmat)

## save to file
write.csv(pkgmat, "../../Data/package_matrix.csv", quote = FALSE)

## k-means
pkgmat <- read.csv('../../Data/package_matrix.csv', row.names = 1) %>%
    as.matrix %>% apply(MARGIN = 1, as.numeric)

eigs <- RSpectra::eigs_sym(pkgmat, k = 100, which = 'LM')
## eigs <- eigen(pkgmat, symmetric = TRUE)
## eigs <- igraph::arpack(func = function(x, A) return(as.vector(A %*% x)),
##                       extra = pkgmat,
##                       sym = TRUE,
##                       options = list(n = nrow(pkgmat),
##                       which = "LM",
##                       nev = 100,
##                       ncv = 102))
## Returns:
## Error in A %*% x : requires numeric/complex matrix/vector arguments

pdf('../../Results/First_100_eigs_pkg.pdf')
plot(abs(eigs$values), rep(1,100) + rnorm(100))
dev.off()

## 10 clusters, maybe?
kout <- kmeans(eigs$vectors[,2:11], 10, nstart=2500)

pkg$cluster_10 <- kout$cluster

fn <- read.csv('../../Data/function.csv', stringsAsFactors = FALSE)

FnConflictsFromCluster <- function(num, pkg, pkg_fn, fn){
    pids <- pkg %>% filter(cluster_10 == num) %>% select(package_id) %>%
        as.matrix %>% as.vector
    fids <- pkg_fn %>% filter(package_id %in% pids) %>%
        select(function_id) %>% as.matrix %>% as.vector
    fn_rows <- fn %>% filter(function_id %in% fids)
    return(fn_rows)
}
