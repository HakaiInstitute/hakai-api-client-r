# hakaiApi 1.0.5.9000
* ADd `get_stations()` method to retrieve list of stations as an sf object

# hakaiApi 1.0.5

* CRAN fix: Moved credential storage to proper user directories and added permission prompts to comply with CRAN policies.
* Fixed typos in auth prompts and added test coverage for environment variable handling.
* Fail informative when creds are expired

# hakaiApi 1.0.4

Enhancements

* the crendentials path is now configurable and environment variables can also be used for tokens (#25)
* Can now use relative urls once client has been initialized (#27)

Bug fixes
* use redacted headers so that they can't be accidentally saved to disk (thx @hadley in #28)

# hakaiApi 1.0.3

Bug fixes
* `get` method now returns tibbles for list responses
* bump minimum R version to 4.2 to handle using native pipe
* change maintainer


Enhancements

* wrap examples in `try()`
* now setting the user agent for the client
* extract `base_request` and `json2tbl` into separate functions to add some unit tests
* user agent can now be customized via the `HAKAI_API_USER_AGENT` environment variable


# hakaiApi 1.0.2

Bug fixes

* Fixes issue where loading cached api credentials sometimes caused cryptic error message and failed to delete the offending corrupted credentials file.

# hakaiApi 1.0.1

Enhancements

* Now uses dplyr::bind_rows for more robust conversion of JSON received from the server.

Bug fixes

* Fixes issue where api credentials were not saved or loaded properly.

# hakaiApi 1.0.0

* Added a `NEWS.md` file to track changes to the package.
* Prevent this packages dependencies from clashing with local packages.
* Add demo code to vignettes.
* Prepared code for CRAN.
* Easier installation using the "remotes" package.
* Update code to follow best practices.
* Update documentation for individual R6 class methods.
