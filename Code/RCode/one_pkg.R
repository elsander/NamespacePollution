args <- commandArgs(trailingOnly = TRUE)
pkg <- as.character(args[1])
print(pkg)
library(pkg, character.only = TRUE)
fns <- as.vector(lsf.str(paste0('package:', pkg)))
df <- data.frame(package = rep(pkg, length(fns)),
                 func = fns)
write.table(df, "../../Data/pkg_function_2.txt",
            row.names = FALSE, col.names = FALSE,
            quote = FALSE, append = TRUE)
