% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/domino.create.R
\name{domino.create}
\alias{domino.create}
\title{domino.create}
\usage{
domino.create(projectName)
}
\arguments{
\item{projectName}{String that will be the name of the new project.}
}
\description{
Creates Domino project. Changes working directory to new 
project's one.
}
\examples{
\dontrun{
# in directory ./
domino.create("my-new-project")
# current working directory is now switched to ./my-new-project and new
project is initialized.
}
}
\keyword{create}

