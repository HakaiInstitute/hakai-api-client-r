install.packages("usethis", repos = "https://cloud.r-project.org/")
install.packages("devtools", repos = "https://cloud.r-project.org/")
install.packages("roxygen2", repos = "https://cloud.r-project.org/")
install.packages("goodpractice", repos = "https://cloud.r-project.org/")
install.packages("rhub", repos = "https://cloud.r-project.org/")
install.packages("remotes", repos = "https://cloud.r-project.org/")
install.packages("spelling", repos = "https://cloud.r-project.org/")
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

usethis::use_tidy_description()

# Run inteRgrate checks
inteRgrate::check_pkg()
inteRgrate::check_lintr()
inteRgrate::check_tidy_description()
inteRgrate::check_r_filenames()
inteRgrate::check_gitignore()
inteRgrate::check_version()

# Spell check
devtools::spell_check()

# Check for CRAN specific requirements using rhub and save it in the results objects
results <- rhub::check_for_cran()
# Get the summary of your results. Manually, save the output cran-comments.md and explain any Notes at the bottom.
results$cran_summary()

# Check for win-development
devtools::check_win_devel()

# One last check before release
devtools::check()

# Release the package to CRAN
devtools::release_checks()
# devtools::release()
