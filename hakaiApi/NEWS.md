# hakaiApi 1.0.2.9000

Enhancements

* wrap examples in `try()`

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
