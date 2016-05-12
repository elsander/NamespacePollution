library(ggthemes)
library(ggplot2)
library(dplyr)
library(tidyr)
library(RSQLite)
require(Matrix)
require(igraph)

GetLargest <- function(mymat){
  func <- function(x, extra=NULL) { as.vector(mymat %*% x) }
  l1v1 <- arpack(func,
                 options=list(
                   n = dim(mymat)[1],
                   nev = 1, ncv = 10,
                   which = "LM",
                   maxiter = 200),sym=TRUE)
  return(l1v1)
}
# load the data
sqlite <- dbDriver("SQLite")
con <- dbConnect(sqlite, "../../Data/R_packages.db")
# run query to fetch data
results <- dbSendQuery(con, "SELECT * FROM package_conflict")
conf_data <- dbFetch(results, n = -1) 
dbClearResult(results)
dbDisconnect(con)

# make undirected, bipartite graph
conf_data <- conf_data %>% select(pkg1_id, function_id) %>% distinct()
conf_data$inter <- 1
# make incidence matrix
B <- as.matrix(conf_data %>% spread(function_id, inter, fill = 0) %>% select(-pkg1_id))
rownames(B) <- paste0("Pkg_", (conf_data %>% spread(function_id, inter, fill = 0))$pkg1_id)
bg <- graph_from_incidence_matrix(t(B))
cl <- clusters(bg, mode = "strong")
bg <- induced.subgraph(bg, which(cl$membership == which.max(cl$csize)))
B1 <- get.incidence(bg)
B1 <- scale(B1, center = TRUE, scale = TRUE)




#B <- t(B)
#Bnorm <- scale(B, center = TRUE, scale = TRUE)
#B1 <- t(Bnorm) %*% Bnorm
#aaa <- GetLargest(B1)
