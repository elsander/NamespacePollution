pkgs <- (.packages())

require(dplyr)

pkgConflicts <- read.table('../../Data/pkg_conflicts_nomethods.csv',
                         header = FALSE)
adjlist <- rbind(pkgConflicts[,1:2],
                 setNames(pkgConflicts[,c(1,3)],
                          names(pkgConflicts[,1:2]))) %>%
    distinct %>% filter(V2 %in% pkgs)
names(adjlist) <- c('fn', 'pkg')

out <- mapply(FUN = function(fn, pkg){
    system(paste('Rscript isMethod.R', fn, pkg))
},
as.matrix(as.data.frame(select(adjlist, fn))),
as.matrix(as.data.frame(select(adjlist, pkg))))

methodDF <- read.csv('../../Data/fn_pkg_method.csv', header = FALSE,
                     stringsAsFactors = FALSE)
names(methodDF) <- c('fn', 'pkg', 'isMethod')
methodDF$isMethod <- as.numeric(methodDF$isMethod)
methodDFnew <- read.csv('../../Data/fn_pkg_method_2.csv', header = FALSE,
                        stringsAsFactors = FALSE)
names(methodDFnew) <- c('fn', 'pkg', 'isMethod')
methodDFnew$isMethod <- methodDFnew$isMethod * 1

## get rid of old results and add new results
for(i in pkgs){
    methodDF <- filter(methodDF, pkg != i)
}
methodDF <- bind_rows(methodDF, methodDFnew)

write.table(methodDF, '../../Data/fn_pkg_method.csv',
            quote = FALSE, row.names = FALSE, sep = ',')

pkgConflicts$methodConflict <-
    apply(pkgConflicts,
          MARGIN = 1,
          FUN = function(row, methodDF){
              match1 <- filter(methodDF, fn == row[1], pkg == row[2])
              match2 <- filter(methodDF, fn == row[1], pkg == row[3])
              return(select(match1, isMethod)[[1]] &&
                     select(match2, isMethod)[[1]])
          }, methodDF = methodDF)

pkgConflicts <- pkgConflicts %>% filter(methodConflict == 0) %>%
    select(-methodConflict)

write.table(pkgConflicts, '../../Data/pkg_conflicts_nomethods.csv', row.names = FALSE, quote = FALSE, sep = ',')
