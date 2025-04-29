base_request <- function(endpoint_url, token) {
  httr2::request(endpoint_url) |>
    httr2::req_headers("Authorization" = token) |>
    httr2::req_user_agent("hakai-api-client-r") 
}