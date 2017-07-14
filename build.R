install.packages("devtools", repos = "http://cran.us.r-project.org")
library("devtools")
devtools::install_github("klutometis/roxygen")
library(roxygen2)

# To generate documentation and build package
setwd("hakaiApi")
document()
