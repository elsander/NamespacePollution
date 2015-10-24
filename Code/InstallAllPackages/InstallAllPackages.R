# This installs all R packages
# Because there are nested dependencies, the first run will install all stand-alone packages

# retrieve all the package names
all_packages <- as.vector(available.packages(contriburl  = "https://cran.rstudio.com/src/contrib")[,"Package"])

# cleanup
system("rm success.txt")
system("rm failure.txt")

processing <- 1
for (package_name in all_packages){
  # call the script
  print("##############################################################################")
  print(processing)
  print("##############################################################################")
  system(paste("Rscript InstallAPackage.R", package_name, "install"))
  processing <- processing + 1 
  ##if (processing > 10) break
}