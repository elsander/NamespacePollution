args <- base::commandArgs(trailingOnly = TRUE)
outfname <- base::as.character(args[1])

pkgvec <- base::vector(mode = "character",
                       length = base::length(args) - 1)
for(i in 2:base::length(args)){
    pkgvec[i] <- base::as.character(args[i])
    base::library(pkgvec[i], character.only = TRUE)
}
print('hooray1')
confListNoDet <- base::unique(base::as.list(base::conflicts()))
confListDet <- base::conflicts(detail = TRUE)
pkgNames <- base::names(confListDet)
print('hooray2')

## lapply over vector of conflicting functions:
## get a vector of package names which contain the function
DoesPkgContainFunction <- function(pkgFns, fn){
    return(base::`%in%`(fn, pkgFns))
}

pkgConflicts <- base::lapply(confListNoDet, function(fn, pkgnames = pkgNames){
    ## get T/F list
    containsFn <- base::lapply(confListDet,
                               DoesPkgContainFunction, fn = fn)
    ## extract matching package names
    return(pkgNames[base::which(base::unlist(containsFn))])
})

## convert variable-length lists to pairwise adjacency list
MakeAdjList <- function(pkgVec, fn){
    ## strip "package:" from package name
    pkgVec <- base::unlist(base::lapply(base::as.list(pkgVec), function(pkg){
        tmp <- base::strsplit(pkg, 'package:')[[1]]
        return(tmp[base::length(tmp)])
    }))
    ## get pairwise combinations of packages
    pkgPairs <- base::t(utils::combn(pkgVec, 2))
    for(i in 1:base::nrow(pkgPairs)){
        pkgPairs[i,] <- base::sort(pkgPairs[i,])
    }
    ## convert to data frame
    pkgdf <- base::data.frame(fn = base::rep(fn, base::nrow(pkgPairs)),
                        p1 = pkgPairs[,1],
                        p2 = pkgPairs[,2])
    return(pkgdf)
}
tmp <- base::mapply(MakeAdjList,
                    pkgVec = pkgConflicts,
                    fn = confListNoDet,
                    SIMPLIFY = FALSE)

pkgAdjList <- base::Reduce(rbind,
                           tmp,
                           init = base::data.frame(fn = base::character(0),
                                                   p1 = base::character(0),
                                                   p2 = base::character(0)))

utils::write.table(pkgAdjList, outfname, sep = ',', row.names = FALSE,
                   append = TRUE, col.names = !base::file.exists(outfname),
                   quote = FALSE)
