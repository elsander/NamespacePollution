myArgs <- commandArgs(trailingOnly = TRUE)

chunkStart <- myArgs[1]
chunkEnd <- myArgs[2]

pkgConflicts <- read.csv('../../Data/pkg_conflicts_nomethods.csv',
                         stringsAsFactors = FALSE)

chunk <- pkgConflicts[chunkStart:chunkEnd,]
chunk$isIdentical <- rep(NA, nrow(chunk))

for(i in 1:nrow(chunk)){
    ## load packages
    base::require(chunk$pkg1[i], character.only = TRUE)
    base::require(chunk$pkg2[i], character.only = TRUE)

    ## check if function is identical
    fn1 <- base::paste(chunk$pkg1[i], chunk$fn[i], sep = '::')
    fn2 <- base::paste(chunk$pkg2[i], chunk$fn[i], sep = '::')
    chunk$isIdentical[i] <-
        base::identical(eval(parse(text = fn1)),
                        eval(parse(text = fn2)))
}

write.table(chunk, '../../Data/pkg_conflicts_isIdentical.csv',
            append = TRUE, sep = ',', quote = FALSE,
            col.names = FALSE, row.names = FALSE)
