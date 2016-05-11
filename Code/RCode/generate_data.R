# NOTES:
# For some reason, I call the same package twice
# moreover, I have installed some packages more than once?
# finally, some packages do not load


# for each of available packages,
# extract the name of all the functions
# saves them to an adjacency list

# packages that are loaded automatically
special_packages <- c("grDevices", "methods", "stats", "utils", "graphics", "datasets", "base")
                      
get_functions_from_package <- function(package_name){
  # load the package
  eval(substitute(require(pkg), list(pkg = as.name(package_name))))
  # extract the functions
  my_funcs <- as.vector(ls.str(paste("package:", package_name, sep = "")))
  # unload the package
  if (package_name %in% special_packages == FALSE){
    detach(paste("package:", package_name, sep = ""), character.only = TRUE)
  }
  if (length(my_funcs) > 0){
    return(data.frame(package_name = package_name, function_name = my_funcs))
  }
  else{
    return(data.frame(package_name = character(0), function_name = character(0)))
  }
}

# get all installed packages
my_installed_packages <- unique(as.vector(installed.packages()[,"Package"]))
# add packages that are loaded automatically
my_installed_packages <- c(special_packages, my_installed_packages)
my_installed_packages <- sort(unique(my_installed_packages))

blacklist <- c("abbyyR", "adephylo")

# finally, compile the data
function_names <- data.frame()
for (pkg in my_installed_packages){
  print(pkg)
  if (pkg %in% blacklist == FALSE){
    try(function_names <- rbind(function_names, get_functions_from_package(pkg)))
    print(dim(function_names))
    write.csv(function_names, "function_names.csv", row.names = FALSE)
  }
}
