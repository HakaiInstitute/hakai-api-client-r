install.packages("usethis", repos = "https://cloud.r-project.org/")
install.packages("devtools", repos = "https://cloud.r-project.org/")
install.packages("roxygen2", repos = "https://cloud.r-project.org/")
install.packages("goodpractice", repos = "https://cloud.r-project.org/")
install.packages("rhub", repos = "https://cloud.r-project.org/")
install.packages("remotes", repos = "https://cloud.r-project.org/")
remotes::install_github("jumpingrivers/inteRgrate")

library("usethis")
library("devtools")
library("goodpractice")
library("rhub")
library("inteRgrate")

# Load or reload the hakaiApi package
setwd("./hakaiApi")
devtools::load_all()
devtools::reload()

# Generate documentation and build package with roxygen2
devtools::document()

# Check docs, check for release
devtools::check_man()

# Check best practices
goodpractice::gp()

# Run inteRgrate checks
inteRgrate::check_pkg()
inteRgrate::check_lintr()
inteRgrate::check_tidy_description()
inteRgrate::check_r_filenames()
inteRgrate::check_gitignore()
inteRgrate::check_version()

# NOTE: Currently fails due to https://github.com/r-hub/rhub/issues/462. Once this issue is solved, we can upload to CRAN
# Check for CRAN specific requirements using rhub and save it in the results objects
# results <- rhub::check_for_cran()
# Get the summary of your results and save to cran-comments.md
# results$cran_summary()

# Release the package to CRAN
devtools::release_checks()
# devtools::release()