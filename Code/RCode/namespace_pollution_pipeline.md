# Pipeline for generating data for namespace pollution project

1. Installing packages

**../InstallAllPackages/InstallAllPackages.R**

2. Get data frame of packages and their functions

**pkg_function_builder.R**? (uses *ls.str()*)
**getNamespaceAllPkg.R**? (uses *ls*. The file it creates is no longer
present in the Data folder, suggesting that this script is no longer
part of the pipeline.)

3. Create data frame of namespace conflicts

**function_conflicts.R**

4. Remove methods from conflict list

**methods.R**

5. Remove identical functions from conflict list

**removeIdentical.R**

Python code was then used to build a SQL database-- probably overkill
when dplyr could be used. But the result is several very clean csv
files:
package.csv
function.csv
package_function.csv
