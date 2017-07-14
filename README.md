# Hakai API R Client

This project exports a single R6 class for the R programming language that can be used to make HTTP requests to the Hakai API resource server. The Class provides a "get" method to make Authenticated requests to the Hakai API data server without needing to know the details of the authentication process.

## Installation

Before using this library, install it into your environment using the following in your R script:

```r
install.packages('devtools')
library('devtools')

devtools::install_github("HakaiInstitute/hakai-api-client-r", subdir='hakaiApi')
```

## Quickstart

```r
library('hakaiApi')

# Get the api request client
client <- hakaiApi::Client$new() # Follow stdout prompts to get an API token

# Make a data request for chlorophyll data
endpoint = sprintf("%s/%s", client$api_root, "eims/views/output/chlorophyll?limit=50")
data <- client$get(endpoint)

# Print out the data
print(data)
```

This script is also available at [./example.R](example.R)

## Methods

This library exports a single class named `Client`. Instantiating this class with the `$new` method sets up the credentials for requests using the `$get` method.

The hakai_api `Client` class also contains a property `api_root` which is useful for constructing urls to access data from the API. The above [Quickstart example](#quickstart) demonstrates using this property to construct a url to access chlorophyll data.

If for some reason your credentials become corrupted and stop working, there is a method to remove the old cached credentials for your account so you can re-authenticate. just do `client$remove_old_credentials()`.

## API endpoints

For details about the API, including available endpoints where data can be requested, see the [Hakai API documentation](https://github.com/HakaiInstitute/hakai-api).

## Advanced usage

You can specify which API to access when instantiating the Client. By default, the API uses `https://hecate.hakai.org/api` as the API root. It may be useful to use this library to access a locally running API instance or to access the Goose API for testing purposes.

```r
# Get a client for a locally running API instance
client <- hakaiApi::Client$new("localhost:8666")
print(client$api_root) # http://localhost:8666
```
