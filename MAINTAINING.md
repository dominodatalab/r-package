
## Bumping Version number

Bump the version number in ./domino/DESCRIPTION and ./domino/man/domino-package.Rd

## Checking package for CRAN

Call ```R CMD check domino --as-cran```

## Building package

Call `R CMD build domino/`

## Build documentation

```
R CMD Rd2pdf domino/man/domino-package.Rd
```

## Useful CRAN links

- http://cran.r-project.org/web/packages/policies.html
- http://cran.r-project.org/
- http://cran.r-project.org/doc/manuals/R-exts.html
