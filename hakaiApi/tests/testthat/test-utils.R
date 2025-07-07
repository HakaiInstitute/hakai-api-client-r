test_that("base_request returns request with default user agent", {
  # Ensure env var is not set
  old_user_agent <- Sys.getenv("HAKAI_API_USER_AGENT")
  Sys.unsetenv("HAKAI_API_USER_AGENT")
  
  req <- base_request("artoo", "detoo")

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "artoo")

  if (utils::packageVersion("httr2") >= "1.1.2.9000") {
    headers <- httr2::req_get_headers(req, "reveal")
  } else {
    headers <- req$headers
  }
  expect_equal(headers$Authorization, "detoo")
  expect_equal(req$options$useragent, "hakai-api-client-r")
  
  # Restore previous env var if it existed
  if (old_user_agent != "") {
    Sys.setenv(HAKAI_API_USER_AGENT = old_user_agent)
  }
})

test_that("base_request uses user agent from environment variable", {
  # Set custom user agent
  old_user_agent <- Sys.getenv("HAKAI_API_USER_AGENT")
  Sys.setenv(HAKAI_API_USER_AGENT = "custom-test-agent")
  
  req <- base_request("artoo", "detoo")

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "artoo")
  if (utils::packageVersion("httr2") >= "1.1.2.9000") {
    headers <- httr2::req_get_headers(req, "reveal")
  } else {
    headers <- req$headers
  }
  expect_equal(headers$Authorization, "detoo")
  expect_equal(req$options$useragent, "custom-test-agent")
  
  # Restore previous env var if it existed
  if (old_user_agent != "") {
    Sys.setenv(HAKAI_API_USER_AGENT = old_user_agent)
  } else {
    Sys.unsetenv("HAKAI_API_USER_AGENT")
  }
})


test_that("json2tbl_impl handles list of simple character values correctly", {
  # Test data - list of single character values
  test_data <- list(
    "Millennium Falcon",
    "Death Star",
    "Star Destroyer"
  )
  
  result <- json2tbl_impl(test_data)
  
  # Should return a tibble with a single column
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 1)
  expect_equal(colnames(result), "value")
  expect_equal(result$value, c("Millennium Falcon", "Death Star", "Star Destroyer"))
})

test_that("json2tbl_impl handles objects with NULL values correctly", {
  # Test data - objects with NULL values
  test_data <- list(
    list(name = "Obi-Wan Kenobi", planet = "Tatooine", ship = NULL),
    list(name = "C-3PO", planet = NULL, ship = "Millennium Falcon"),
    list(name = NULL, planet = "Endor", ship = "Imperial Shuttle")
  )
  
  result <- json2tbl_impl(test_data)
  
  # Should return a tibble with NAs for NULL values
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 3)
  expect_equal(is.na(result$ship[1]), TRUE)
  expect_equal(is.na(result$planet[2]), TRUE)
  expect_equal(is.na(result$name[3]), TRUE)
})

test_that("json2tbl_impl handles mixed length lists correctly", {
  # Test data - mixed length objects
  test_data <- list(
    list(planet = "Tatooine", terrain = "Desert"),
    list(planet = "Hoth", terrain = "Ice", native_species = "Wampa"), 
    list(planet = "Dagobah")
  )
  
  result <- json2tbl_impl(test_data)
  
  # Should return a tibble with all columns from all objects
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 3)
  expect_equal(result$planet, c("Tatooine", "Hoth", "Dagobah"))
  expect_equal(result$terrain[1:2], c("Desert", "Ice"))
  expect_equal(is.na(result$terrain[3]), TRUE)
  expect_equal(result$native_species[2], "Wampa")
  expect_equal(is.na(result$native_species[1]), TRUE)
  expect_equal(is.na(result$native_species[3]), TRUE)
})

test_that("json2tbl_impl handles empty lists correctly", {
  # Test data - empty list
  test_data <- list()
  
  result <- json2tbl_impl(test_data)
  
  # Should return an empty tibble
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})
