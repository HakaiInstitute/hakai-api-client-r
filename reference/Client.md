# The Hakai API Client Class

Class to use to make authenticated API requests for Hakai data.
Credentials can be provided via the HAKAI_API_TOKEN environment variable
or through a credentials file.

## Public fields

- `api_root`:

  The api_root you are logged in to

## Methods

### Public methods

- [`Client$new()`](#method-Client-new)

- [`Client$get()`](#method-Client-get)

- [`Client$get_stations()`](#method-Client-get_stations)

- [`Client$post()`](#method-Client-post)

- [`Client$put()`](#method-Client-put)

- [`Client$patch()`](#method-Client-patch)

- [`Client$remove_credentials()`](#method-Client-remove_credentials)

- [`Client$clone()`](#method-Client-clone)

------------------------------------------------------------------------

### Method `new()`

Log into Google to gain credential access to the API

#### Usage

    Client$new(
      api_root = "https://portal.hakai.org/api",
      login_page = "https://portal.hakai.org/api-client-login",
      credentials_file = NULL
    )

#### Arguments

- `api_root`:

  Optional API base url to fetch data. Defaults to
  "https://portal.hakai.org/api"

- `login_page`:

  Optional API login page url to display to user. Defaults to
  "https://portal.hakai.org/api-client-login"

- `credentials_file`:

  Optional path to the credentials cache file. Defaults to a file in the
  user's data directory as determined by tools::R_user_dir()

#### Details

Credentials can be provided in two ways: 1. Via the HAKAI_API_TOKEN
environment variable (contains query string:
"token_type=Bearer&access_token=...") 2. Via a credentials file
(default: in user data directory via tools::R_user_dir()) The
environment variable takes precedence if both are available.

#### Returns

A client instance

#### Examples

    try(
       client <- Client$new()
    )
    # Using environment variable
    Sys.setenv(HAKAI_API_TOKEN = "token_type=Bearer&access_token=TOKEN")
    try(
       client <- Client$new()
    )
    # Using custom credentials file
    try(
       client <- Client$new(credentials_file = "/path/to/creds")
    )

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Send a GET request to the API

#### Usage

    Client$get(endpoint_url, col_types = NULL)

#### Arguments

- `endpoint_url`:

  The API endpoint url - can be a full URL or a relative path that will
  be appended to the api_root

- `col_types`:

  a readr type specification

#### Returns

A dataframe of the requested data

#### Examples

    try(client$get("/aco/views/projects"))
    try(client$get("https://portal.hakai.org/api/aco/views/projects"))

------------------------------------------------------------------------

### Method `get_stations()`

Get recent sensor nodes and their locations as an sf object

#### Usage

    Client$get_stations()

#### Returns

An sf object of sensor nodes and their locations

#### Examples

    try(client$get_stations())

------------------------------------------------------------------------

### Method `post()`

Send a POST request to the API

#### Usage

    Client$post(endpoint_url, rec_data)

#### Arguments

- `endpoint_url`:

  The API endpoint url - can be a full URL or a relative path that will
  be appended to the api_root

- `rec_data`:

  dataframe, list, or other R data structure to send as part of the post
  request payload

#### Returns

post request response status code and description

------------------------------------------------------------------------

### Method `put()`

Send a PUT request to the API

#### Usage

    Client$put(endpoint_url, rec_data)

#### Arguments

- `endpoint_url`:

  The API endpoint url - can be a full URL or a relative path that will
  be appended to the api_root

- `rec_data`:

  dataframe, list, or other R data structure to send as part of the post
  request payload

#### Returns

PUT request response status code and description

------------------------------------------------------------------------

### Method `patch()`

Send a PATCH request to the API

#### Usage

    Client$patch(endpoint_url, rec_data)

#### Arguments

- `endpoint_url`:

  The API endpoint url - can be a full URL or a relative path that will
  be appended to the api_root

- `rec_data`:

  dataframe, list, or other R data structure to send as part of the post
  request payload

#### Returns

PATCH request response status code and description

------------------------------------------------------------------------

### Method `remove_credentials()`

Remove your cached login credentials to logout of the client

#### Usage

    Client$remove_credentials()

#### Examples

    try(
       client$remove_credentials()
    )

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Client$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Initialize a new client
try(
  client <- Client$new()
)

# Or use environment variable for token
Sys.setenv(HAKAI_API_TOKEN = "token_type=Bearer&access_token=TOKEN")
try(
  client <- Client$new()
)

# Follow authorization prompts to log in

# Retrieve some data. See <https://hakaiinstitute.github.io/hakai-api/> for options.
try(
  projects_2020 <- client$get("/aco/views/projects?project_year=2020&fields=project_name")
)

try(
  print(projects_2020)
)
# # A tibble: 20 x 1
#    project_name
#    <chr>
#  1 Fountain FN
#  2 Haig Glacier
#  3 Fraser River - Chimney Creek West William Canyon
#  4 Cruickshank WS
#  ...
} # }

## ------------------------------------------------
## Method `Client$new`
## ------------------------------------------------

try(
   client <- Client$new()
)
#> /home/runner/.local/share/R/hakaiApi/.hakai-api-auth-r
#> Please go here and authorize:
#> https://portal.hakai.org/api-client-login
#> 
#> Copy and paste the full credential string from the login page:
#> 
#> Invalid credential format, try again.
# Using environment variable
Sys.setenv(HAKAI_API_TOKEN = "token_type=Bearer&access_token=TOKEN")
try(
   client <- Client$new()
)
#> Error in if (are_credentials_expired(credentials)) { : 
#>   argument is of length zero
# Using custom credentials file
try(
   client <- Client$new(credentials_file = "/path/to/creds")
)
#> Error in if (are_credentials_expired(credentials)) { : 
#>   argument is of length zero

## ------------------------------------------------
## Method `Client$get`
## ------------------------------------------------

try(client$get("/aco/views/projects"))
#> Error in httr2::req_perform(base_request(resolved_url, token)) : 
#>   HTTP 401 Unauthorized.
try(client$get("https://portal.hakai.org/api/aco/views/projects"))
#> Error in httr2::req_perform(base_request(resolved_url, token)) : 
#>   HTTP 401 Unauthorized.

## ------------------------------------------------
## Method `Client$get_stations`
## ------------------------------------------------

try(client$get_stations())
#> Simple feature collection with 27 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -128.1432 ymin: 50.116 xmax: -124.8554 ymax: 51.77083
#> Geodetic CRS:  WGS 84
#> # A tibble: 27 × 3
#>    station_id                sensor_node             geometry
#>    <chr>                     <chr>                <POINT [°]>
#>  1 Buxton                    Buxton      (-128.0178 51.60491)
#>  2 Calvert Reference Station RefStn      (-128.1287 51.65195)
#>  3 East Buxton               BuxtonEast  (-127.9752 51.58994)
#>  4 Ethel                     Ethel       (-127.5317 51.54844)
#>  5 Hecate                    Hecate      (-128.0228 51.68257)
#>  6 KCBuoy                    KCBuoy       (-127.9663 51.6499)
#>  7 Koeye                     Koeye       (-127.8794 51.77083)
#>  8 Lookout                   Lookout      (-128.1432 51.6475)
#>  9 Orford Buoy               OrfordBuoy  (-124.9018 50.59661)
#> 10 Orford Camp               OrfordCamp  (-124.8554 50.59206)
#> # ℹ 17 more rows

## ------------------------------------------------
## Method `Client$remove_credentials`
## ------------------------------------------------

try(
   client$remove_credentials()
)
#> [1] TRUE
```
