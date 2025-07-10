base_request <- function(endpoint_url, token) {
  user_agent <- Sys.getenv("HAKAI_API_USER_AGENT", "hakai-api-client-r")

  httr2::request(endpoint_url) |>
    httr2::req_headers("Authorization" = token) |>
    httr2::req_user_agent(user_agent)
}

# Helper function to resolve URLs - extracted for testing
resolve_url <- function(endpoint_url, api_root) {
  # Check if the URL is already absolute (contains http:// or https://)
  if (grepl("^https?://", endpoint_url)) {
    return(endpoint_url)
  }

  # For relative URLs, prepend the api_root
  # Remove any leading slash from endpoint_url to avoid double slashes
  endpoint_url <- sub("^/+", "", endpoint_url)

  # Remove any trailing slash from api_root to avoid double slashes
  api_root <- sub("/+$", "", api_root)

  return(paste0(api_root, "/", endpoint_url))
}


json2tbl_impl <- function(data) {
  # Handle special case of single vectors
  if (all(sapply(data, length) == 1)) {
    return(tibble::tibble(value = unlist(data)))
  }
  data <- lapply(data, function(data) {
    data[sapply(data, is.null)] <- NA # nolint
    unlist(data)
  })
  data <- dplyr::bind_rows(data)
  return(data)
}


are_credentials_expired <- function(credentials) {
  as.numeric(Sys.time()) > credentials$expires_at
}
