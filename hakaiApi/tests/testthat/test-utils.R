test_that("base_request returns ", {
  req <- base_request("artoo", "detoo")

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "artoo")
  expect_equal(req$headers$Authorization, "detoo")
  expect_equal(req$options$useragent, "hakai-api-client-r")
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
