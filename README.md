Domino R package
====

#### Bumping Version number

Bump the version number in ./domino/DESCRIPTION and ./domino/man/domino-package.Rd


#### KNOWN ERRORS

If your getting

    During startup - Warning messages:
    1: Setting LC_TIME failed, using "C"
    2: Setting LC_MESSAGES failed, using "C"
    3: Setting LC_MONETARY failed, using "C"

check your shell locales with ```locale```
set locales with ```export LC_ALL=en_US.UTF-8``` in the shell

####Checking package for CRAN

Call ```R CMD check domino --as-cran```

####Building package

Call ```R CMD build domino/```` from within rPackage folder.


####Deploy
Upload to static.dominodatalab.com/R
    - one copy at domino_{version}.tar.gz
    - one copy at domino_latest.tar.gz

####Build documentation

    R CMD Rd2pdf domino/man/domino-package.Rd

####Installation

    R CMD install domino_X.Y.tar.gz

####Usage

    library(domino)

    domino.login("jglodek", "secret_password")
    domino.get("my-magic-project")
    domino.run("main.r", "--secret-arg")
    domino.download()

####Submission & Policies

- http://cran.r-project.org/web/packages/policies.html

####Knowledge

- http://cran.r-project.org/

- http://cran.r-project.org/doc/manuals/R-exts.html




