# hakaiApi 1.0.4

Enhancements

* the crendentials path is now configurable and environment variables can also be used for tokens (#25)
* Can now use relative urls once client has been initialized (#27)

Bug fixes
* use redacted headers so that they can't be accidentally saved to disk (thx @hadley in #28)

## Test environments
* local macOS, R 4.4.3(via R CMD check --as-cran)
* ubuntu-24.04.2, r: 'release' (github actions)
* ubuntu-24.04.2, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)

## R CMD check results
0 errors ✓ | 0 warnings ✓ | 0 note ✓