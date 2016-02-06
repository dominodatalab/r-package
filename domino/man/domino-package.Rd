\name{domino}
\alias{domino}
\alias{domino-package}
\encoding{UTF-8}
\docType{package}
\title{
Domino Data Lab R console bindings
}
\details{
\tabular{ll}{
Package: \tab domino\cr
Type: \tab Package\cr
Version: \tab 0.2-7\cr
Date: \tab 2015-05-27\cr
License: \tab MIT \cr
}
}
\author{
Jacek Głodek <jacek@theiterators.com>
Maintainer: Nick Elprin <nick@dominodatalab.com>
}
\description{
The Domino R package is a wrapper on top of the Domino command-line client.
It lets you run  Domino commands (e.g., "run", "upload", "download")
directly from your R environment.
Under the hood, it uses R's system function to run the Domino executable,
which must be installed as a prerequisite.
}
\references{
  Domino Data Lab support webpage - http://help.dominodatalab.com/
}
\keyword{
package
domino
dominoup
}

\examples{
\dontrun{
## logins as a given user to the Domino server
## and approves sending error reports to Domino.
domino.login("jglodek", "MySecretPassword", TRUE)

## creates new project.
domino.create("my-new-project")

## gets existing project from the server.
domino.get("jglodek/my-old-project")

## gets existing project from the server.
domino.get("my-old-project")

## initializes new domino project in current working directory with a given name.
domino.init("other-name")

## downloads run results from Domino server.
domino.download()

## uploads project files to Domino server.
domino.upload()

## runs main.r in the cloud with given arguments.
domino.run("main.r", "other", "console", "arguments")

## shows difference between current version and last uploaded version.
domino.diff()

## displays current run's status in the console.
domino.status()

## shows debug information
domino.debug()

## resets project defined in by current working directory
domino.reset()

## runs any of domino client command with given arguments
domino.runCommand("run my-file.r", successCallback, "failure message!")

}
}
