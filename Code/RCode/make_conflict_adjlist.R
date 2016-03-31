require(dplyr)

pkgConflicts <- read.csv('../../Data/pkg_conflicts_nomethods_noidentical.csv',
                         header = TRUE)
adjlist <- rbind(pkgConflicts[,1:2],
                 setNames(pkgConflicts[,c(1,3)],
                          names(pkgConflicts[,1:2]))) %>%
    distinct
names(adjlist) <- c('function', 'package')

write.table(adjlist, '../../Data/conflict_adjlist.csv',
            sep = ',', row.names = FALSE, col.names = TRUE)
