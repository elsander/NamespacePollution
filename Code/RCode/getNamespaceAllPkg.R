require(parallel)
pkgs <- as.data.frame(installed.packages())$Package
out <- mclapply(pkgs, FUN = function(pkg){
    system(paste('Rscript getNamespaceOnePkg.R', pkg))
},
                mc.cores = 3,
                mc.silent = TRUE)
