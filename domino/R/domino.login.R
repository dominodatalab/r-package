#' @title domino.login
#' @name domino.login
#'
#' @description Logins to Domino server.
#'
#' @usage domino.login(usernameOrEmail, password,
#' approvalForSendingErrorReports=FALSE, host)
#'
#' @param usernameOrEmail Login or e-mail address used when registering for
#' Domino Data Lab account. Ex. \code{"jglodek"}
#' @param password Secret password that was set for authenticating in Domino
#' Data Lab server. If the password is not provided,a password prompt will be
#' shown for interactive sessions. For non-interactive sessions, this arguments
#' is required. Ex. \code{"my-secret-password"}
#' @param approvalForSendingErrorReports Approval for the Domino client to send
#' error reports to Domino in order to improve the product
#' (these will NEVER include any of your data or source code).
#' This defaults to FALSE. Ex. \code{ FALSE }
#' @param host The location of the domino server (this argument is optional)
#' Ex. \code{"https://app.dominodatalab.com"}
#'
#'
#' @keywords login
#'
#' @examples
#' \dontrun{
#' domino.login("jglodek", TRUE)
#' domino.login("jglodek","my-super-secret-password", TRUE)
#' domino.login("jglodek","my-super-secret-password", TRUE, "https://app.dominodatalab.com")
#' }
#'
#' @export

domino.login <- function(usernameOrEmail, password, approvalForSendingErrorReports=FALSE, host) {
  # If the user did not enter a password open the login prompt
  if(missing(password) && !interactive()){
    stop("Missing parameters for login command. Proper usage: domino.login(usernameOrEmail, password, approvalForSendingErrorReports)")
  }

  if(missing(usernameOrEmail)) {
    if(interactive()){
      stop("Missing parameters for login command. Proper usage: domino.login(usernameOrEmail, approvalForSendingErrorReports, host)")
    } else {
      stop("Missing parameters for login command. Proper usage: domino.login(usernameOrEmail, password, approvalForSendingErrorReports, host)")
    }
  }

  if(missing(password)){
    password <- .domino.login.prompt()
  }

  if(is.null(password)){
    stop("Missing parameters for login command. Password is required.")
  }

  if(approvalForSendingErrorReports){
    approvalChar = "Y"
  } else {
    approvalChar = "N"
  }

  theinput = paste(usernameOrEmail, '\n', password, '\n', approvalChar, sep="")

  loginCommand <- "login"

  if(missing(host)) {
    warning("You did not provide a host. Starting in June 2016, the CLI will not automatically determine the host for you.")
  }

  if(!missing(host)){
    loginCommand <- paste(loginCommand, host, sep=" ")
  }

  domino.runCommand(loginCommand, domino.OK, "Login failed", theinput)
}
