library(dplyr)

a <- read.csv("../../Data/pkg_conflicts_nomethods_noidentical.csv", stringsAsFactors = FALSE)
# make undirected by duplicating each row (pkg1, pkg2) -> (pkg2, pkg1)
b <- a[,c(1,3,2)]
colnames(b) <- colnames(a)
a <- rbind(a, b) %>% arrange(fn, pkg1, pkg2)
b <- NULL
# Ideally, we would like to have ids instead of names... trying with dplyr join
b <- read.csv("../../Data/function.csv", stringsAsFactors = FALSE)
a <- inner_join(a, b, by = c("fn" = "function_name") ) # add the function_id 
b <- read.csv("../../Data/package.csv", stringsAsFactors = FALSE)
# adding pkg1_id
colnames(b) <- c("pkg1_id", "pkg1")
a <- inner_join(a, b)
# adding pkg1_id
colnames(b) <- c("pkg2_id", "pkg2")
a <- inner_join(a, b)
# remove extra cols 
a <- a %>% select(-fn, -pkg1, -pkg2)
# write the file
write.csv(a, file = "pkg_conflicts.csv", row.names = FALSE, quote = FALSE)