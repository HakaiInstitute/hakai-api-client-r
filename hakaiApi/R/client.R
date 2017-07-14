library("httr")
library("urltools")
library("jsonlite")

apiRoot <- "http://localhost:8666"
authorizationBaseUrl <- sprintf("%s/auth/oauth2", apiRoot)
tokenUrl <- sprintf("%s/auth/oauth2/token", apiRoot)

# Get the user to login and get the oAuth2 code from the redirect url
writeLines("Please go here and authorize:")
writeLines(authorizationBaseUrl)
redirect_response <- readline("\nPaste the full redirect URL here:\n")
code <- urltools::param_get(redirect_response, "code")$code

# Exchange the oAuth2 code for a jwt token
res <- httr::POST(tokenUrl, body = list(code = code), encode = "json")
resBody <- httr::content(res, "parsed")
accessToken <- resBody$access_token
tokenType <- resBody$token_type
expiresIn <- resBody$expires_in

# Format token as proper credentials
credentials = sprintf("%s %s", tokenType, accessToken)

# Make an authenticated API request
exampleAddress = sprintf("%s/%s", apiRoot, "whoami")
r <- httr::GET(exampleAddress, httr::add_headers(Authorization = credentials))
content(r)
