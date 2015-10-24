import rpy2.robjects as robjects

rcode = "row.names(as.data.frame(available.packages()))"
packages = robjects.r(rcode)

failed = []
package_function_dict = dict()
for i, package in enumerate(packages):
    print i
    try:
        rcode = 'install.packages(%s)' % (package)
        robjects.r(rcode)
    except:
        failed.append(package)
        continue
    fns = []
    package_function_dict[package] = fns
    


