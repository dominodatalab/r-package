\name{domino.get}
\alias{domino.get}
\encoding{UTF-8}
\title{
domino.get
}
\description{
Downloads given project data from Domino.
Changes working directory to the project's directory.
}
\usage{
# Usage without username
domino.get("projectName")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{projectName}{
String containing project name. It can be prefixed by username and slash. Ex. \code{"jglodek/quick-start"}.
}
}
\examples{
\dontrun{
    # in directory ./
    domino.get("my-project-in-the-cloud")
    # current working directory is now switched to ./my-project-in-the-cloud and the directory
    # is filled with files from Domino server.
    
    # The name of the project is prepended with username
    domino.get("jglodek/my-project-in-the-cloud")}
}
\keyword{ get }

