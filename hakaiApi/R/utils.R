base_request <- function(endpoint_url, token) {
  httr2::request(endpoint_url) |>
    httr2::req_headers("Authorization" = token) |>
    httr2::req_user_agent("hakai-api-client-r") 
}


json2tbl_impl <- function(data) {
  # Handle special case of single vectors
  if (all(sapply(data, length) == 1)) {
    return(tibble::tibble(value = unlist(data)))
  }
  data <- lapply(data, function(data) {
    data[sapply(data, is.null)] <- NA  # nolint
    unlist(data)
  })
  data <- bind_rows(data)
  return(data)
}