# read command line arguments:
# The program can be launched with
# Rscript package_name install
# Rscript package_name remove

options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)
package_name <- args[1]
flag <- args[2]

if (flag == "install"){
  if (eval(substitute(require(pkg), list(pkg = as.name(package_name))))){
  #if (require(package_name, character.only = TRUE)){
    # the package is already installed
    print(paste("package", package_name, "is already installed"))
  } else {
    # try installing the package
    eval(substitute(install.packages(pkg, contriburl  = "https://cran.rstudio.com/src/contrib"), list(pkg = (package_name))))
  }
  # now make sure that everything is fine
  if (require(package_name, character.only = TRUE)){
    # append to the success files
    system(paste("echo", package_name, ">> success.txt"))
  } else {
    system(paste("echo", package_name, ">> failure.txt"))
    x <- system2("Rscript", paste0("-e \"install.packages('", package_name, ", contriburl=\"https://cran.rstudio.com/src/contrib\"')\""), stdout=TRUE, stderr=TRUE)
    write(x, file = paste0("../../FailedOutput/", package_name, "-fail.log"))
    print("could not install package!")
  }
}

if (flag == "remove"){
  if (eval(substitute(require(pkg), list(pkg = as.name(package_name))))){
    # the package is already installed, remove
    eval(substitute(remove.packages(pkg), list(pkg = (package_name))))
  } else {
    print(paste("package", package_name, "is not installed -- cannot remove"))
  }
}
