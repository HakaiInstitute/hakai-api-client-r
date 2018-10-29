library(R6)
library("httr")
library("urltools")
library(tidyverse)

#' A Hakai API Client
#'
#' This class allows you to make authenticated API requests
#' @param api_root The root url for all API Requests. Defaults to https://hecate.hakai.org/api
#' @keywords hakai
#' @export
#' @examples
#' Client$new()
Client <- R6Class("Client",
  lock_objects = FALSE,
  public = list(
    api_root = NULL,
    credentials = NULL,
    initialize = function(api_root = "https://hecate.hakai.org/api") {
      self$api_root <- api_root
      private$authorization_base_url <- sprintf('%s/auth/oauth2', api_root)
      private$token_url <- sprintf('%s/auth/oauth2/token', api_root)

      credentials <- private$try_to_load_credentials()
      if(is.list(credentials)) {
        self$credentials = credentials
      } else {
        credentials = private$get_credentials_from_web()
        private$save_credentials(credentials)
        self$credentials = credentials
      }
    },
    get = function(endpointUrl) {
      token = sprintf("%s %s", self$credentials$token_type, self$credentials$access_token)
      r <- httr::GET(endpointUrl, httr::add_headers(Authorization = token))
      data <- private$json2tbl(httr::content(r))
      data <- tibble::as_tibble(data)
      data <- type_convert(data)
      return(data)
    },
    remove_old_credentials = function() {
      if(file.exists(private$credentials_file)) {
        file.remove(private$credentials_file)
      }
    }
  ),
  private = list(
    client_id = '289782143400-1f4r7l823cqg8fthd31ch4ug0thpejme.apps.googleusercontent.com',
    authorization_base_url = NULL,
    token_url = NULL,
    credentials_file = path.expand('~/.hakai-api-credentials-r'),
    json2tbl = function(data) {
      data <- lapply(data, function(data) {
        data[sapply(data, is.null)] <- NA
        unlist(data)
      })
      data <- do.call("rbind", data)
      return(data)
    },
    get_credentials_from_web = function() {
      # Get the user to login and get the oAuth2 code from the redirect url
      writeLines("Please go here and authorize:")
      writeLines(private$authorization_base_url)
      redirect_response <- readline("\nPaste the full redirect URL here:\n")
      code <- urltools::param_get(redirect_response, "code")$code

      # Exchange the oAuth2 code for a jwt token
      res <- httr::POST(private$token_url, body = list(code = code), encode = "json")
      res_body <- httr::content(res, "parsed")

      now <- as.numeric(Sys.time())
      credentials = list(
        access_token = res_body$access_token,
        token_type = res_body$token_type,
        expires_in = res_body$expires_in,
        expires_at = now + res_body$expires_in
      )

      # Return the credentials
      return(credentials)
    },
    try_to_load_credentials = function() {
      # Check the cached credentials file exists
      if(!file.exists(private$credentials_file)){
        return(FALSE)
      }

      tryCatch({
        # Load the credentials from the file cache
        credentials_file <- file(private$credentials_file, "r")
        cache = unserialize(credentials_file)
        close(credentials_file)
        api_root = cache$api_root
        credentials = cache$credentials

        # Check api root is the same and that credentials aren't expired
        same_root = self$api_root == api_root
        credentials_expired = as.numeric(Sys.time()) > credentials$expires_at

        if(!same_root || credentials_expired){
          file.remove(private$credentials_file)
          return(FALSE)
        }
      }, error = function(e) {
        # Remove file anyway if there's an error
        file.remove(private$credentials_file)
        return(FALSE)
      })

      # If all is well, return the credentials
      return(credentials)
    },
    save_credentials = function(credentials) {
      # Save the credentials to the self$credentials_file location
      cache = list(
        api_root = self$api_root,
        credentials = credentials
      )
      credentials_file = file(private$credentials_file, "w")
      serialize(cache, credentials_file)
      close(credentials_file)
    }
  )
)
