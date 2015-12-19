require(devtools)
require(dplyr)
require(parallel)

pkgConflicts <- read.csv('../../Data/pkg_conflicts_nomethods.csv',
                         stringsAsFactors = FALSE)
names(pkgConflicts) <- c('fn', 'pkg1', 'pkg2')
pkgConflicts$isIdentical <- rep(NA, nrow(pkgConflicts))
## sort to have as few require() statements as possible
pkgConflicts <- pkgConflicts %>% dplyr::arrange(pkg1, pkg2)

## number of rows in a chunk
chunkSize <- 30
nChunks <- ceiling(nrow(pkgConflicts)/chunkSize)

chunkList <- as.list(1:nChunks)
out <- mclapply(chunkList, FUN = function(i){
    chunkStart <- i * chunkSize
    if(i == nChunks){
        chunkEnd <- nrow(pkgConflicts)
    } else {
        chunkEnd <- chunkStart + chunkSize - 1
    }
    system(paste('Rscript removeIdenticalChunk.R',
                 chunkStart, chunkEnd))
}, mc.cores = 4, mc.silent = TRUE)


pkgConflictsNew <- read.table('../../Data/pkg_conflicts_isIdentical.csv',
                              header = FALSE, sep = ',',
                              stringsAsFactors = FALSE)
names(pkgConflictsNew) <- c('fn', 'pkg1', 'pkg2', 'isIdentical')

## remove all rows with identical functions
dplyr::filter(pkgConflictsNew, isIdentical == FALSE) %>%
    select(-isIdentical) %>%
    write.csv('../../Data/pkg_conflicts_nomethods_noidentical.csv',
              row.names = FALSE, quote = FALSE)
