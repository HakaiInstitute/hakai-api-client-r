test_that("base_request returns ", {
  req <- base_request("artoo", "detoo")

  expect_s3_class(req, "httr2_request")
  expect_equal(req$url, "artoo")
  expect_equal(req$headers$Authorization, "detoo")
  expect_equal(req$options$useragent, "hakai-api-client-r")
})
