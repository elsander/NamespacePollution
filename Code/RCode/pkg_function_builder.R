packages <- sort(row.names(as.data.frame(installed.packages())))

for(i in 1:length(packages)){
    system(paste("Rscript one_pkg.R", packages[i]))
    if(i %% 100 == 0) print(i)
}
