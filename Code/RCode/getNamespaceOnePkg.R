myArgs <- commandArgs(trailingOnly = TRUE)
pkg <- myArgs[1]

require(pkg, character.only = TRUE)

## list all of the functions in the package
fns <- as.list(ls(pos = paste0("package:", pkg)))

## get namespaces for package
namespaces <- lapply(fns, function(fn){
    namespace <- tryCatch({
        environment(eval(parse(text = paste0(pkg, '::', fn))))$.packageName
    }, error = function(cond){
        return('NA')
    }, finally = function() {
    })
    if(is.null(namespace)){
        namespace <- 'NA'
    }
    return(namespace)
})

df <- data.frame(pkg = rep(pkg, length(fns)),
                 fn = unlist(fns),
                 namespace = unlist(namespaces))
write.table(df, '../../Data/package_function_namespace.csv', append = TRUE,
            row.names = FALSE, col.names = FALSE, quote = FALSE,
            sep = ',')
