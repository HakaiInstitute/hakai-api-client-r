# hakaiApi 1.0.2.9000

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
