#' The Hakai API Client Class
#'
#' @description
#' Class to use to make authenticated API requests for Hakai data.
#' Credentials can be provided via the HAKAI_API_TOKEN environment variable
#' or through a credentials file.
#' @importFrom R6 R6Class
#' @importFrom httr2 request req_headers req_method req_body_json req_perform
#' @importFrom readr type_convert
#' @export
#' @examples
#' \dontrun{
#' # Initialize a new client
#' try(
#'   client <- Client$new()
#' )
#'
#' # Or use environment variable for token
#' Sys.setenv(HAKAI_API_TOKEN = "token_type=Bearer&access_token=TOKEN")
#' try(
#'   client <- Client$new()
#' )
#'
#' # Follow authorization prompts to log in
#'
#' # Retrieve some data. See <https://hakaiinstitute.github.io/hakai-api/> for options.
#' try(
#'   projects_2020 <- client$get("/aco/views/projects?project_year=2020&fields=project_name")
#' )
#'
#' try(
#'   print(projects_2020)
#' )
#' # # A tibble: 20 x 1
#' #    project_name
#' #    <chr>
#' #  1 Fountain FN
#' #  2 Haig Glacier
#' #  3 Fraser River - Chimney Creek West William Canyon
#' #  4 Cruickshank WS
#' #  ...
#' }
Client <- R6::R6Class(
  "Client", # nolint
  lock_objects = FALSE,
  public = list(
    #' @field api_root The api_root you are logged in to
    api_root = NULL,
    #' @description
    #' Log into Google to gain credential access to the API
    #' @param api_root Optional API base url to fetch data.
    #' Defaults to "https://hecate.hakai.org/api"
    #' @param login_page Optional API login page url to display to user.
    #' Defaults to "https://hecate.hakai.org/api-client-login"
    #' @param credentials_file Optional path to the credentials cache file.
    #' Defaults to a file in the user's data directory as determined by tools::R_user_dir()
    #' @details
    #' Credentials can be provided in two ways:
    #' 1. Via the HAKAI_API_TOKEN environment variable (contains query string: "token_type=Bearer&access_token=...")
    #' 2. Via a credentials file (default: in user data directory via tools::R_user_dir())
    #' The environment variable takes precedence if both are available.
    #' @return A client instance
    #' @examples
    #' try(
    #'    client <- Client$new()
    #' )
    #' # Using environment variable
    #' Sys.setenv(HAKAI_API_TOKEN = "token_type=Bearer&access_token=TOKEN")
    #' try(
    #'    client <- Client$new()
    #' )
    #' # Using custom credentials file
    #' try(
    #'    client <- Client$new(credentials_file = "/path/to/creds")
    #' )
    initialize = function(
      api_root = "https://hecate.hakai.org/api",
      login_page = "https://hecate.hakai.org/api-client-login",
      credentials_file = NULL
    ) {
      self$api_root <- api_root
      private$login_page_url <- login_page

      # Set default credentials file location using R_user_dir
      if (is.null(credentials_file)) {
        user_dir <- tools::R_user_dir("hakaiApi", "data")
        private$credentials_file <- file.path(user_dir, ".hakai-api-auth-r")
      } else {
        private$credentials_file <- path.expand(credentials_file)
      }

      credentials <- private$try_to_load_credentials()
      if (is.list(credentials)) {
        private$credentials <- credentials
      } else {
        credentials <- private$get_credentials_from_web()
        private$save_credentials(credentials)
        private$credentials <- credentials
      }
    },
    #'@description
    #' Send a GET request to the API
    #' @param endpoint_url The API endpoint url - can be a full URL or a relative path that will be appended to the api_root
    #' @param col_types a readr type specification
    #' @return A dataframe of the requested data
    #' @examples
    #' try(client$get("/aco/views/projects"))
    #' try(client$get("https://hecate.hakai.org/api/aco/views/projects"))
    get = function(endpoint_url, col_types = NULL) {
      resolved_url <- private$resolve_url(endpoint_url)
      token <- paste(
        private$credentials$token_type,
        private$credentials$access_token
      )
      r <- base_request(resolved_url, token) |>
        httr2::req_perform()
      data <- httr2::resp_body_json(r)
      data <- private$json2tbl(httr2::resp_body_json(r))
      data <- tibble::as_tibble(data)
      data <- readr::type_convert(data, col_types = col_types)
      return(data)
    },
    #' @description
    #' Get recent sensor nodes and their locations as an sf object
    #' @return An sf object of sensor nodes and their locations
    #' @examples
    #' try(client$get_stations())
    get_stations = function() {
      if (!requireNamespace("sf", quietly = TRUE)) {
        stop(
          "Package 'sf' is required. Install with: install.packages('sf')",
          call. = FALSE
        )
      }
      endpoint_url = "sn/recent_stations.geojson"
      resolved_url <- private$resolve_url(endpoint_url)
      token <- paste(
        private$credentials$token_type,
        private$credentials$access_token
      )
      r <- base_request(resolved_url, token) |>
        httr2::req_perform()
      data <- httr2::resp_body_string(r)
      temp_file <- tempfile(fileext = ".geojson")
      writeLines(foo, temp_file)

      stations <- sf::read_sf(temp_file, quiet = TRUE)
      on.exit(unlink(temp_file))
      stations[, c("station_id", "sensor_node", "geometry")]
    },

    #'@description
    #' Send a POST request to the API
    #' @param endpoint_url The API endpoint url - can be a full URL or a relative path that will be appended to the api_root
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return post request response status code and description
    post = function(endpoint_url, rec_data) {
      resolved_url <- private$resolve_url(endpoint_url)
      token <- paste(
        private$credentials$token_type,
        private$credentials$access_token
      )
      resp <- base_request(resolved_url, token) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(rec_data) |>
        httr2::req_perform()
      data <- paste0(
        httr2::resp_status(resp),
        ' ',
        httr2::resp_status_desc(resp)
      )
      return(data)
    },

    #'@description
    #' Send a PUT request to the API
    #' @param endpoint_url The API endpoint url - can be a full URL or a relative path that will be appended to the api_root
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return PUT request response status code and description
    put = function(endpoint_url, rec_data) {
      resolved_url <- private$resolve_url(endpoint_url)
      token <- paste(
        private$credentials$token_type,
        private$credentials$access_token
      )
      resp <- base_request(resolved_url, token) |>
        httr2::req_body_json(data = rec_data, auto_unbox = TRUE) |>
        httr2::req_method("PUT") |>
        httr2::req_perform()
      data <- paste0(
        httr2::resp_status(resp),
        ' ',
        httr2::resp_status_desc(resp)
      )
      return(resp)
    },

    #'@description
    #' Send a PATCH request to the API
    #' @param endpoint_url The API endpoint url - can be a full URL or a relative path that will be appended to the api_root
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return PATCH request response status code and description
    patch = function(endpoint_url, rec_data) {
      resolved_url <- private$resolve_url(endpoint_url)
      token <- paste(
        private$credentials$token_type,
        private$credentials$access_token
      )
      resp <- base_request(resolved_url, token) |>
        httr2::req_body_json(data = rec_data, auto_unbox = TRUE) |>
        httr2::req_method("PATCH") |>
        httr2::req_perform()
      data <- paste0(
        httr2::resp_status(resp),
        ' ',
        httr2::resp_status_desc(resp)
      )
      return(resp)
    },

    #' @description
    #' Remove your cached login credentials to logout of the client
    #' @examples
    #' try(
    #'    client$remove_credentials()
    #' )
    remove_credentials = function() {
      if (file.exists(private$credentials_file)) {
        file.remove(private$credentials_file)
      }
    }
  ),
  private = list(
    login_page_url = NULL,
    credentials_file = NULL,
    credentials = NULL,
    json2tbl = function(data) {
      json2tbl_impl(data)
    },
    resolve_url = function(endpoint_url) {
      resolve_url(endpoint_url, self$api_root)
    },
    querystring2df = function(querystring) {
      tryCatch(
        {
          s <- strsplit(querystring, "&")
          p <- lapply(s, function(a) {
            strsplit(a, "=")
          })
          df <- data.frame(matrix(unlist(p), ncol = length(unlist(s))))
          names(df) <- as.character(unlist(df[1, ]))
          return(df[-1, ])
        },
        error = function(e) {
          # Return dummy credentials
          writeLines("Invalid credential format, try again.")
          return(data.frame(
            token_type = "",
            access_token = "",
            expires_at = -1
          ))
        }
      )
    },
    get_credentials_from_web = function() {
      # Ask for permission to store credentials before getting them
      if (interactive()) {
        message(
          "hakaiApi would like to store credentials in: ",
          private$credentials_file
        )
        choice <- utils::menu(
          c("Yes", "No"),
          title = "Store credentials file?"
        )
        if (choice != 1) {
          stop(
            "Permission denied to store credentials file. ",
            "Alternative: Set environment variable HAKAI_API_TOKEN with your credentials.",
            call. = FALSE
          )
        }
      }

      # Get the user to login and get the oAuth2 code from the redirect url
      writeLines("Please go here and authorize:")
      writeLines(private$login_page_url)
      writeLines("")

      querystring <- readline(
        "Copy and paste the full credential string from the login page:\n"
      )
      credentials <- private$querystring2df(querystring)
      return(credentials)
    },
    try_to_load_credentials = function() {
      # check if token is provided via environment variable
      env_token <- Sys.getenv("HAKAI_API_TOKEN", unset = NA)
      if (!is.na(env_token) && env_token != "") {
        credentials <- private$querystring2df(env_token)

        if (are_credentials_expired(credentials)) {
          stop(
            paste0(
              "HAKAI_API_TOKEN is expired. Please generate a new token at ",
              self$api_root
            ),
            call. = FALSE
          )
        }

        return(credentials)
      }

      # If no environment variable, fall back to file-based credentials
      # Check the cached credentials file exists
      message(private$credentials_file)
      if (!file.exists(private$credentials_file)) {
        return(FALSE)
      }

      tryCatch(
        {
          # Load the credentials from the file cache
          credentials_file <- file(private$credentials_file, "r")
          credentials <- unserialize(credentials_file)
          close(credentials_file)

          # Check that credentials aren't expired
          if (are_credentials_expired(credentials)) {
            self$remove_credentials()
            credentials <- FALSE
          }
        },
        error = function(cond) {
          message("Error reading cached credentials:")
          message(cond[1])
          self$remove_credentials()
          credentials <<- FALSE
        }
      )

      # If all is well, return the credentials
      credentials
    },
    save_credentials = function(credentials) {
      # Ensure the directory exists before saving
      cred_dir <- dirname(private$credentials_file)
      if (!dir.exists(cred_dir)) {
        dir.create(cred_dir, recursive = TRUE)
      }

      # Save the credentials to the self$credentials_file location
      credentials_file <- file(private$credentials_file, "w")
      serialize(credentials, credentials_file)
      close(credentials_file)
    }
  )
)
