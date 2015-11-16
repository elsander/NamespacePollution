require(parallel)
packages <- sort(row.names(as.data.frame(installed.packages())))

## hardcoded
nToBundle <- 15
outfname <- '../../Data/pkg_conflicts.csv'

## split vector of packages into vector of strings
## strings will have nToBundle packages listed with a space
## between each, to pass to Rscript
nBundles <- ceiling(length(packages)/nToBundle) 
pkgvec <- vector(mode = "character", length = nBundles)
for(i in 1:nBundles){
    tmpPkgs <- packages[((i-1)*nToBundle+1):(i*nToBundle)]
    pkgvec[i] <- paste(tmpPkgs, collapse = ' ')
}

## make matrix of pairs of package sets
pkgSetPairs <- as.list(as.data.frame(combn(pkgvec, m=2)))
pkgSetPairs <- lapply(pkgSetPairs, as.character)
## convert to list of rows for mclapply
print(pkgSetPairs[[1]])

## look for conflicts in a separate R session
## for each pair of sets of bundles
print('############################################')
print('############################################')
print(paste('Looking for conflicts in', nBundles,
            'sets of packages, for a total of',
            nBundles*(nBundles-1)/2, 'comparison sets.'))
print('############################################')
print('############################################')
mclapply(pkgSetPairs, function(x){
    system(paste("Rscript conflicts_one_pair.R",
                 outfname, x[1], x[2]))},
    mc.cores = 4,
    mc.preschedule = TRUE,
    mc.silent = TRUE
)
