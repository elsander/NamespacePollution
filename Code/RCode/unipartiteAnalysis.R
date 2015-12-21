require(igraph)
require(Matrix)

## allConf <- read.csv('../../Data/pkg_conflicts_nomethods_noidentical.csv',
##                     stringsAsFactors = FALSE)
## conflictCounts <- allConf %>% count(pkg1, pkg2, sort = TRUE) %>%
##     ungroup %>% arrange(desc(n))
## write.csv(conflictCounts, '../../Data/pkg_conflicts_counts.csv',
##           quote = FALSE, row.names = FALSE)

confCounts <- read.csv('../../Data/pkg_conflicts_counts.csv', header = TRUE)
bothLevels <- union(levels(confCounts$pkg1), levels(confCounts$pkg2))
confCounts$pkg1 <- as.numeric(factor(confCounts$pkg1, levels = bothLevels))
confCounts$pkg2 <- as.numeric(factor(confCounts$pkg2, levels = bothLevels))

## convert to adjacency matrix so it can be converted to igraph object
N <- length(bothLevels)
conflictMatrix <- sparseMatrix(i = confCounts$pkg1,
                           j = confCounts$pkg2,
                           x = confCounts$n, dims = c(N,N),
                           symmetric = TRUE)
rownames(conflictMatrix) <- colnames(conflictMatrix) <- as.character(bothLevels)

g <- graph.adjacency(conflictMatrix, mode = 'undirected', weighted = TRUE,
                     add.colnames = TRUE)
gDeg <- degree(g)
gAssort <- assortativity_degree(g)

gMotifs3 <- graph.motifs(g, size = 3)
gMotifs4 <- graph.motifs(g, size = 4)
gClusters <- clusters(g)
