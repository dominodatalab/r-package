\name{domino.init}
\alias{domino.init}
\encoding{UTF-8}
\title{
domino.init
}
\description{
Initializes new domino project in current directory.
It can also set arbitrary name to the project,
even if different from current directory name.
}
\usage{
# inits a project inside current directory, with given name.
# ex. if run in ~/my_project, with "my_name" as a param,
# it will create a Domino project called my-param inside ~/my_project directory.
domino.init("projectName")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{projectName}{
Project name for the project that will be created in current working directory.
}
}
\examples{
\dontrun{
    # in directory ./
    domino.init("my-new-project")
    # new project with name "my-new-project" is initialized inside current directory.}
}
\keyword{ init }

