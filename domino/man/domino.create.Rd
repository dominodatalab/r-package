\name{domino.create}
\alias{domino.create}
\encoding{UTF-8}
\title{
domino.create
}
\description{
Creates Domino project. Changes working directory to new project's one.
}
\usage{
domino.create(projectName)
}
\arguments{
  \item{projectName}{
  String that will be the name of the new project.
}
}
\examples{
\dontrun{
    # in directory ./
    domino.create("my-new-project")
    # current working directory is now switched to ./my-new-project and new project is initialized.}
}
\keyword{ create  }

