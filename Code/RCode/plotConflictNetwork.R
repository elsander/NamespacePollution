require(networkD3)
require(dplyr)

allConf <- read.csv('../../Data/pkg_conflicts_nomethods_noidentical.csv')

confCounts <- allConf %>% count(pkg1, pkg2, sort = TRUE) %>%
    ungroup %>% arrange(desc(n))

## combine factor levels between pkg1 and pkg2
bothLevels <- union(levels(confCounts$pkg1), levels(confCounts$pkg2))
confCounts$pkg1 <- as.numeric(factor(confCounts$pkg1, levels = bothLevels)) - 1
confCounts$pkg2 <- as.numeric(factor(confCounts$pkg2, levels = bothLevels)) - 1

nodeConflicts <- data.frame(NodeID = bothLevels,
                            TotalConflicts = rep(NA, length(bothLevels)),
                            group = rep(1, length(bothLevels)))
nodeConflicts$NodeID <- as.character(nodeConflicts$NodeID)
for(i in 1:nrow(nodeConflicts)){
    nodeConflicts$TotalConflicts[i] <- sum(confCounts$pkg1 == (i-1),
                                           confCounts$pkg2 == (i-1))
}

forceNetwork(Links = confCounts, Nodes = nodeConflicts,
             Source = "pkg1", Target = "pkg2",
             Value = "n", NodeID = "NodeID",
             Nodesize = "TotalConflicts", Group = "group",
             opacity = 0.5, zoom = TRUE)
