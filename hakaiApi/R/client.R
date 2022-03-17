#' The Hakai API Client Class
#'
#' @description
#' Class to use to make authenticated API requests for Hakai data
#' @importFrom R6 R6Class
#' @importFrom httr GET add_headers content
#' @importFrom readr type_convert
#' @importFrom tibble as_tibble
#' @export
#' @examples
#' # Initialize a new client
#' client <- Client$new()
#' # Follow authorization prompts to log in
#'
#' # Retrieve some data. See <https://hakaiinstitute.github.io/hakai-api/> for options.
#' url <- paste0(client$api_root, "/aco/views/projects?project_year=2020&fields=project_name")
#' projects_2020 <- client$get(url)
#'
#' print(projects_2020)
#' # # A tibble: 20 x 1
#' #    project_name
#' #    <chr>
#' #  1 Fountain FN
#' #  2 Haig Glacier
#' #  3 Fraser River - Chimney Creek West William Canyon
#' #  4 Cruickshank WS
#' #  ...
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
    #' client <- Client$new()
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
    #' client$get("https://hecate.hakai.org/api/aco/views/projects")
    get = function(endpoint_url) {
      token <- paste(private$credentials$token_type,
                     private$credentials$access_token)
      r <- httr::GET(endpoint_url, httr::add_headers(Authorization = token))
      data <- private$json2tbl(httr::content(r))
      data <- tibble::as_tibble(data)
      data <- readr::type_convert(data)
      return(data)
    },
    #' @description
    #' Remove your cached login credentials to logout of the client
    #' @examples
    #' client$remove_credentials()
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
      data <- do.call("rbind", data)
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
          file.remove(private$credentials_file)
          return(FALSE)
        }
      }, error = function() {
        # Remove file anyway if there's an error
        file.remove(private$credentials_file)
        return(FALSE)
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
