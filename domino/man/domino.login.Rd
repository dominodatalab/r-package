\name{domino.login}
\alias{domino.login}
\encoding{UTF-8}
\title{
domino.login
}
\description{
Logins to Domino server.
}
\usage{
domino.login(usernameOrEmail, password, approvalForSendingErrorReports=FALSE, host)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{usernameOrEmail}{
Login or e-mail address used when registering for Domino Data Lab account. Ex. \code{"jglodek"}
}
  \item{password}{
Secret password that was set for authenticating in Domino Data Lab server. If the password is not provided,
a password prompt will be shown for interactive sessions. For non-interactive sessions, this arguments is required. 
Ex. \code{"my-secret-password"}
}
  \item{approvalForSendingErrorReports}{
Approval for the Domino client to send error reports to Domino in order to improve the product
(these will NEVER include any of your data or source code).
This defaults to FALSE. Ex. \code{ FALSE }
}
  \item{host}{
The location of the domino server (this argument is optional) Ex. \code{"https://app.dominodatalab.com"}
}
}
\examples{
\dontrun{
    domino.login("jglodek", TRUE)
    domino.login("jglodek","my-super-secret-password", TRUE)
    domino.login("jglodek","my-super-secret-password", TRUE, "https://app.dominodatalab.com")}
}
\keyword{ login }

