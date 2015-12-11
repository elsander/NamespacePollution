trueConflict <- function(fn, pkg1, pkg2){
    initialEnvs <- c(".GlobalEnv", "package:stats", "package:graphics",
                     "package:grDevices", "package:utils", "package:datasets",
                     "package:methods", "Autoloads", "package:base")
    require(pkg1, character.only = TRUE)
    numMethods <- length(methods(paste(pkg1,fn, sep = '::')))
    return (numMethods > 0)*1
}

pkgConflicts <- read.csv('../../Data/pkg_conflicts_uniq.csv',
                         header = FALSE)
names(pkgConflicts) <- c('fn', 'p1', 'p2')
pkgConflicts$hasMethods <- sapply(pkgConflicts$fn, hasMethods)

#We need to call a session of R, see if the function is a method when that one package is installed, then see if it's a method when the other package is installed. If it is a method for both, remove the line. Possible approach: call a session of R within R, write the result to file, and read it in to get the result?
