test_that("absolute URLs are returned unchanged", {
  absolute_url <- "https://external-api.com/endpoint"
  api_root <- "https://my-api.com/api"
  resolved <- hakaiApi:::resolve_url(absolute_url, api_root)
  expect_equal(resolved, absolute_url)

  # Test http URLs too
  http_url <- "http://external-api.com/endpoint"
  resolved_http <- hakaiApi:::resolve_url(http_url, api_root)
  expect_equal(resolved_http, http_url)
})

test_that("resolve_url handles relative URLs and slashes correctly", {
  api_root <- "https://my-api.com/api"

  relative_url <- "/path/to/endpoint"
  resolved <- hakaiApi:::resolve_url(relative_url, api_root)
  expect_equal(resolved, "https://my-api.com/api/path/to/endpoint")

  relative_url_no_slash <- "path/to/endpoint"
  resolved_no_slash <- hakaiApi:::resolve_url(relative_url_no_slash, api_root)
  expect_equal(resolved_no_slash, "https://my-api.com/api/path/to/endpoint")
})

test_that("resolve_url handles api_root with trailing slashes", {
  api_root_with_slash <- "https://my-api.com/api/"
  relative_url <- "/path/to/endpoint"
  resolved <- hakaiApi:::resolve_url(relative_url, api_root_with_slash)
  expect_equal(resolved, "https://my-api.com/api/path/to/endpoint")

  api_root_multiple_slashes <- "https://my-api.com/api///"
  resolved_multiple <- hakaiApi:::resolve_url(
    relative_url,
    api_root_multiple_slashes
  )
  expect_equal(resolved_multiple, "https://my-api.com/api/path/to/endpoint")
})

test_that("resolve_url handles query parameters correctly", {
  api_root <- "https://my-api.com/api"

  # Test relative URL with query parameters
  relative_url <- "/path/to/endpoint?param1=value1&param2=value2"
  resolved <- hakaiApi:::resolve_url(relative_url, api_root)
  expect_equal(
    resolved,
    "https://my-api.com/api/path/to/endpoint?param1=value1&param2=value2"
  )

  # Test absolute URL with query parameters (should remain unchanged)
  absolute_url <- "https://external-api.com/endpoint?param=value"
  resolved_abs <- hakaiApi:::resolve_url(absolute_url, api_root)
  expect_equal(resolved_abs, absolute_url)
})

test_that("resolve_url handles edge cases", {
  api_root <- "https://my-api.com/api"

  # Test empty endpoint
  empty_endpoint <- ""
  resolved_empty <- hakaiApi:::resolve_url(empty_endpoint, api_root)
  expect_equal(resolved_empty, "https://my-api.com/api/")

  # Test just a slash
  slash_only <- "/"
  resolved_slash <- hakaiApi:::resolve_url(slash_only, api_root)
  expect_equal(resolved_slash, "https://my-api.com/api/")
})


test_that("Client uses environment variable when available", {
  withr::with_envvar(
    c(
      HAKAI_API_TOKEN = "token_type=Bearer&access_token=dummy_token&expires_at=9999999999"
    ),
    {
      temp_creds <- tempfile()

      # Client should initialize successfully using env var
      client <- Client$new(credentials_file = temp_creds)

      expect_true(inherits(client, "Client"))
      expect_false(file.exists(temp_creds))
    }
  )
})

test_that("Environment variable takes precedence over file", {
  temp_creds <- tempfile()
  dir.create(dirname(temp_creds), recursive = TRUE, showWarnings = FALSE)

  # Create a dummy credentials file
  dummy_file_creds <- list(
    token_type = "Bearer",
    access_token = "file_token",
    expires_at = as.numeric(Sys.time()) + 3600
  )
  con <- file(temp_creds, "wb")
  serialize(dummy_file_creds, con)
  close(con)

  withr::with_envvar(
    c(
      HAKAI_API_TOKEN = "token_type=Bearer&access_token=env_token&expires_at=9999999999"
    ),
    {
      client <- Client$new(credentials_file = temp_creds)
      expect_true(inherits(client, "Client"))
      # File still exists but wasn't used (env var took precedence)
      expect_true(file.exists(temp_creds))
    }
  )

  unlink(temp_creds)
})
