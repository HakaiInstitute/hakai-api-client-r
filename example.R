install.packages("devtools", repos = "http://cran.us.r-project.org")
library("devtools")

devtools::install_github("HakaiInstitute/hakai-api-client-r", subdir = "hakaiApi")
library("hakaiApi")

# Initialize the client
client <- hakaiApi::Client$new()

# Request some data (request chlorophyll data here)
endpoint <- "eims/views/output/chlorophyll?limit=50"
data <- client$get(sprintf("%s/%s", client$api_root, endpoint))

# Print out the data
print(data)
