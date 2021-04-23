install.packages("usethis", repos = "https://cloud.r-project.org/")
install.packages("devtools", repos = "https://cloud.r-project.org/")
install.packages("roxygen2", repos = "https://cloud.r-project.org/")

library("usethis")
library("devtools")

# Load or reload the hakaiApi package
devtools::load_all()
devtools::reload()

# Initial check package
devtools::check()

# Generate documentation and build package with roxygen2
devtools::document()

# Check docs, check for release
devtools::check_man()
devtools::check_dep_version("urltools")
devtools::check_dep_version("httr")
devtools::check_dep_version("readr")
devtools::release_checks()
