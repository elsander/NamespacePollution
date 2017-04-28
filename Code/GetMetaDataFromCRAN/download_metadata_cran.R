all_packages <- read.table("All_CRAN_packages_Apr_28_2017.txt", 
                           header = FALSE, sep = "#",
                           stringsAsFactors = FALSE)
# for each package, download the index page using wget
for (i in 1:nrow(all_packages)){
  my_package <- all_packages[i, 1]
  print(c(i, nrow(all_packages), my_package))
  # now download
  system(paste0("wget --output-document=raw_html/", my_package,
                ".html --quiet https://cran.r-project.org/web/packages/",
                my_package, "/index.html"))
}
#https://cran.r-project.org/web/packages/ABHgenotypeR/index.html

