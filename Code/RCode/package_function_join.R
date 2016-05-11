require(dplyr)

## MakeJoinTable <- function(){
    pkg <- read.csv('../../Data/package.csv', stringsAsFactors = FALSE)
    fn <- read.csv('../../Data/function.csv', stringsAsFactors = FALSE)

    pkgfn <- read.csv('../../Data/conflict_adjlist.csv', stringsAsFactors = FALSE)
    pkgfn <- pkgfn %>%
        dplyr::rename(function_name = function.) %>%
            dplyr::rename(package_name = package)
    pkgfnnum <- read.csv('../../Data/package_function.csv', stringsAsFactors = FALSE)

## there are a bunch of NAs in rows here that don't make sense...
## ids that don't match with names, etc.
    pkgfn <- pkgfn %>%
    dplyr::full_join(pkg) %>%
            dplyr::full_join(fn) %>%
                dplyr::full_join(pkgfnnum)

    write.csv(pkgfn, '../../Data/pkg_fn_join_from_R.csv', row.names = FALSE,
              quote = FALSE)
    return(pkgfn)
## }

pkgfn <- MakeJoinTable()
## this ignores the group and I don't know why
tmp <- dplyr::group_by(pkgfn, package_name) %>%
    count(package_name)
