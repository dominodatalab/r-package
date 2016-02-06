\name{domino.run}
\alias{domino.run}
\encoding{UTF-8}
\title{
domino.run
}
\description{
Runs your project on Domino servers with given parameters.
}
\usage{
domino.run(..., publishApiEndpoint=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
\item{...}{
All the run arguments will be joined together using space character. \\
Ex. \code{domino.run("main.py", "-xvz", "my-file1.csv")}
}
\item{publishApiEndpoint}{
Automatically publish API endpoints upon successful run completion. \\
Ex. \code{domino.run("main.py", "-xvz", "my-file1.csv", publishApiEndpoint=TRUE)}
}
}
\examples{\dontrun{
    my_data <- 4
    domino.run("main.R","1","my-file1.csv", my_data)
    #=> Runs "domino main.R 1 my-file1.csv 4"}
}
\keyword{ run }

