myArgs <- commandArgs(trailingOnly = TRUE)
fn <- myArgs[1]
pkg <- myArgs[2]

## it's unfortunate that we need the methods package,
## but we can't check for S4 methods without it
require(methods)
nmeth <- length(.S4methods(fn))
nmeth <- nmeth + tryCatch({
    length(.S3methods(fn))
}, warning = function(cond) {
    system(paste0('printf "before loading:', fn, ' ', pkg,
                  '\n" >> problem_methods.log'))
    system(paste0('printf "', cond, '\n" >> problem_methods.log'))
    return(0)
}, error = function(cond) {
    return(0)
}, finally = function() {})

if(pkg %in% c('methods', (.packages()))) {
    ## we want to count all core package functions
    ## as methods because it's common to write methods
    ## for these common functions. It may remove some true
    ## conflicts, but that will be almost impossible to
    ## avoid unless the removal is done manually.
    isMethod <- 1
} else {
    require(pkg, character.only = TRUE)
    nmeth2 <- length(.S4methods(fn))
    nmeth2 <- nmeth2 + tryCatch({
        length(.S3methods(fn))
    }, warning = function(cond) {
        ## if there's a warning, it almost certainly means that there is
        ## a function named like a method for a function that isn't
        ## an S3 generic.
        system(paste0('printf "after loading:', fn, ' ', pkg,
                      '\n" >> problem_methods.log'))
        system(paste0('printf "', cond, '\n" >> problem_methods.log'))
        return(0)
    }, error = function(cond) {
        ## if there's an error, it's probably because there aren't any
        ## methods. Annoyingly, .S3methods() throws an error in this
        ## case but .S4methods() does not.
        system(paste0('printf "', fn, ' ', pkg, '\n" >> problem_methods.log'))
        system(paste0('printf "', cond, '\n" >> problem_methods.log'))
        return(0)
    }, finally = function() {})

    if(nmeth2 - nmeth > 0){
        isMethod <- 1
    } else {
        if(nmeth2 - nmeth < 0){
            ## this shouldn't happen
            isMethod <- -1
        } else {
            ## this will also be 0 if the conflict is a dataset,
            ## not a function
            isMethod <- 0
        }
    }
}

df <- data.frame(fn = fn, pkg = pkg, isMethod = isMethod)
write.table(df, '../../Data/fn_pkg_method_2.csv', append = TRUE,
            row.names = FALSE, col.names = FALSE, quote = FALSE,
            sep = ',')
