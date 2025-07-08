# Hakai API R Client

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R build status](https://github.com/HakaiInstitute/hakai-api-client-r/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/HakaiInstitute/hakai-api-client-r/actions/workflows/R-CMD-check.yaml)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/hakaiApi)](https://cran.r-project.org/package=hakaiApi)
[![cran checks](https://badges.cranchecks.info/worst/hakaiApi.svg)](https://cran.r-project.org/web/checks/check_results_hakaiApi.html)

This project exports a single R6 class for the R programming language that can be used to make HTTP requests to the Hakai API resource server. The Class provides a "get" method to make Authenticated requests to the Hakai API data server without needing to know the details of the authentication process.

## Installation

Before using this library, install it into your environment using one of the following in your R script:

```r
# From CRAN
install.packages("hakaiApi")

# OR, the latest version from GitHub
install.packages("remotes")
remotes::install_github("HakaiInstitute/hakai-api-client-r", subdir='hakaiApi')
```

## Quickstart

```r
# Initialize the client
client <- hakaiApi::Client$new("https://hecate.hakai.org")

# Request some data (request chlorophyll data here)
data <- client$get("api/eims/views/output/chlorophyll?limit=50")

# View out the data
View(data)
```

## Methods

This library exports a single class named `Client`. Instantiating this class with the `$new` method sets up the credentials for requests using the `$get` method.

The hakai_api `Client` class also contains a property `api_root` which is useful for constructing urls to access data from the API. The above [Quickstart example](#quickstart) demonstrates using this property to construct a url to access chlorophyll data.

If for some reason your credentials become corrupted and stop working, there is a method to remove the old cached credentials for your account so you can re-authenticate. just do `client$remove_old_credentials()`.

## API endpoints

For details about the API, including available endpoints where data can be requested, see the [Hakai API documentation](https://hakaiinstitute.github.io/hakai-api/).

## Advanced usage

You can specify which API to access when instantiating the Client. By default, the API uses `https://hecate.hakai.org/api` as the API root. It may be useful to use this library to access a locally running API instance or to access the Goose API for testing purposes.

```r
# Get a client for a locally running API instance
client <- hakaiApi::Client$new("localhost:8666")
print(client$api_root) # http://localhost:8666
```

## Contributing
This class defines a number of public and private variables and methods that make this request client work. The development of this class was largely informed by the R project's [R6 class documentation](https://r6.r-lib.org/articles/Introduction.html). To build this class into a R package, [this tutorial](https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/) was followed.

### Author
Sam Albers (sam.albers@hakai.org)
Taylor Denouden (taylor.denouden@hakai.org)

Copyright (c) 2025 Hakai Institute and individual contributors All Rights Reserved.
