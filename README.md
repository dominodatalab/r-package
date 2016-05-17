# Domino R package

This package provides bindings to interact with the Domino CLI from R. You must have a recent version
of the Domino CLI to use this package. You can find more information on setting up the Domino
CLI in [this support article](http://support.dominodatalab.com/hc/en-us/articles/204856475-Installing-the-Domino-Client-CLI-).

## Installation

```
R CMD install domino_X.Y.tar.gz
```

## Usage

```
library(domino)

domino.login("jglodek", "secret_password")
domino.get("my-magic-project")
domino.run("main.r", "--secret-arg")
domino.download()
```

## Known Bugs

If you're getting these warning messages:

```
1: Setting LC_TIME failed, using "C"
2: Setting LC_MESSAGES failed, using "C"
3: Setting LC_MONETARY failed, using "C"
```

check your shell locales with ```locale```
set locales with ```export LC_ALL=en_US.UTF-8``` in the shell

## License

This library is made available under the MIT License. This is an open-source project of
[Domino Data Lab](https://www.dominodatalab.com).
