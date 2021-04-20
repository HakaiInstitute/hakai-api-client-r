# install dependant packages
install.packages('devtools')
library('devtools')

# install hakaiApi library
devtools::install_github("HakaiInstitute/hakai-api-client-r", subdir = "hakaiApi")
library("hakaiApi")

# Initialize the client
client <- hakaiApi::Client$new()

# Request some data (request chlorophyll data here)
data <- client$get("https://hecate.hakai.org/api/eims/views/output/chlorophyll?limit=50")

# View out the data
View(data)
