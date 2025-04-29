#' The Hakai API Client Class
#'
#' @description
#' Class to use to make authenticated API requests for Hakai data
#' @importFrom R6 R6Class
#' @importFrom httr2 request req_headers req_method req_body_json req_perform 
#' @importFrom readr type_convert
#' @importFrom tibble as_tibble
#' @importFrom dplyr bind_rows
#' @export
#' @examples
#' \dontrun{
#' # Initialize a new client
#' try(
#'   client <- Client$new()
#' )
#' 
#' # Follow authorization prompts to log in
#'
#' # Retrieve some data. See <https://hakaiinstitute.github.io/hakai-api/> for options.
#' try(
#'   url <- paste0(client$api_root, "/aco/views/projects?project_year=2020&fields=project_name")
#' )
#'
#' try(
#'   projects_2020 <- client$get(url)
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
Client <- R6::R6Class("Client",  # nolint
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
    #' @return A client instance
    #' @examples
    #' try(
    #'    client <- Client$new()
    #' )
    initialize = function(api_root = "https://hecate.hakai.org/api",
                          login_page="https://hecate.hakai.org/api-client-login") {
      self$api_root <- api_root
      private$login_page_url <- login_page
      private$credentials_file <- path.expand("~/.hakai-api-auth-r")

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
    #' @param endpoint_url The full API url to fetch data from
    #' @return A dataframe of the requested data
    #' @examples
    #' try(client$get("https://hecate.hakai.org/api/aco/views/projects"))
    get = function(endpoint_url) {
      token <- paste(private$credentials$token_type,
                     private$credentials$access_token)
      r <- base_request(endpoint_url, token) |> 
        httr2::req_perform()
      data <- httr2::resp_body_json(r)
      data <- private$json2tbl(httr2::resp_body_json(r))
      data <- tibble::as_tibble(data)
      data <- readr::type_convert(data)
      return(data)
    },

    #'@description
    #' Send a POST request to the API
    #' @param endpoint_url The full API url to fetch data from
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return post request response status code and description
    post = function(endpoint_url, rec_data) {
      token <- paste(private$credentials$token_type,
                     private$credentials$access_token)
      resp <- base_request(endpoint_url, token) |>
        httr2::req_method("POST") |>
        httr2::req_body_json(rec_data) |>
        httr2::req_perform()
      data <- paste0(httr2::resp_status(resp), ' ',  httr2::resp_status_desc(resp))
      return(data)
    },

    #'@description
    #' Send a PUT request to the API
    #' @param endpoint_url The full API url to fetch data from
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return PUT request response status code and description
    put = function(endpoint_url, rec_data) {
      token <- paste(private$credentials$token_type,
                     private$credentials$access_token)
      resp <- base_request(endpoint_url, token) |>
        httr2::req_body_json(data = rec_data, auto_unbox = TRUE) |>
        httr2::req_method("PUT") |>
        httr2::req_perform()
      data <- paste0(httr2::resp_status(resp), ' ',  httr2::resp_status_desc(resp))
      return(resp)
    },

    #'@description
    #' Send a PATCH request to the API
    #' @param endpoint_url The full API url to fetch data from
    #' @param rec_data dataframe, list, or other R data structure to send as part of the post request payload
    #' @return PATCH request response status code and description
    patch = function(endpoint_url, rec_data) {
      token <- paste(private$credentials$token_type,
                     private$credentials$access_token)
      resp <- base_request(endpoint_url, token) |>
        httr2::req_body_json(data = rec_data, auto_unbox = TRUE) |>
        httr2::req_method("PATCH") |>
        httr2::req_perform()
      data <- paste0(httr2::resp_status(resp), ' ',  httr2::resp_status_desc(resp))
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
      data <- lapply(data, function(data) {
        data[sapply(data, is.null)] <- NA  # nolint
        unlist(data)
      })
      data <- bind_rows(data)
      return(data)
    },
    querystring2df = function(querystring) {
      tryCatch({
        s <- strsplit(querystring, "&")
        p <- lapply(s, function(a) {
          strsplit(a, "=")
        })
        df <- data.frame(matrix(unlist(p), ncol = length(unlist(s))))
        names(df) <- as.character(unlist(df[1, ]))
        return(df[-1, ])
      }, error = function(e) {
        # Return dummy credentials
        writeLines("Invalid credential format, try again.")
        return(data.frame(token_type = "", access_token = "", expires_at = -1))
      })
    },
    get_credentials_from_web = function() {
      # Get the user to login and get the oAuth2 code from the redirect url
      writeLines("Please go here and authorize:")
      writeLines(private$login_page_url)
      writeLines("")

      querystring <- readline("Copy and past your credentials from the login page:\n")
      credentials <- private$querystring2df(querystring)
      return(credentials)
    },
    try_to_load_credentials = function() {
      # Check the cached credentials file exists
      if (!file.exists(private$credentials_file)) {
        return(FALSE)
      }

      tryCatch({
        # Load the credentials from the file cache
        credentials_file <- file(private$credentials_file, "r")
        credentials <- unserialize(credentials_file)
        close(credentials_file)

        # Check that credentials aren't expired
        if (as.numeric(Sys.time()) > credentials$expires_at) {
          self$remove_credentials()
          credentials <- FALSE
        }
      },
      error = function(cond) {
        message("Error reading cached credentials:")
        message(cond[1])
        self$remove_credentials()
        credentials <<- FALSE
      })

      # If all is well, return the credentials
      return(credentials)
    },
    save_credentials = function(credentials) {
      # Save the credentials to the self$credentials_file location
      credentials_file <- file(private$credentials_file, "w")
      serialize(credentials, credentials_file)
      close(credentials_file)
    }
  )
)
