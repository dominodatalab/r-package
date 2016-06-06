#' @title domino.run
#' @name domino.run
#'
#' @description Runs your project on Domino servers with given parameters.
#'
#' @usage domino.run(..., publishApiEndpoint=FALSE)
#'
#' @param ... All the run arguments will be joined together using space character.
#' Ex. \code{domino.run("main.py", "-xvz", "my-file1.csv")}
#'
#'
#' @param publishApiEndpoint Whether or not to republish the project's API endpoint at the end of the run.
#'
#' @examples
#' \dontrun{
#' my_data <- 4
#' domino.run("main.R","1","my-file1.csv", my_data)
#' #=> Runs "domino main.R 1 my-file1.csv 4"
#' }
#' @export

domino.run <- function(..., publishApiEndpoint=FALSE) {
  if(missing(...)) {
    stop("Missing parameters for run command. Example usage:domino.run('main.R', param1, param2, param3, ...)", call.=FALSE)
  }

  cmd = "run"

  if(domino.notFalse(publishApiEndpoint)){
    cmd = paste(cmd, "--publish-api-endpoint")
  }

  cmd = paste(cmd, ...)

  domino.runCommand(cmd, domino.OK, paste("Running the \"", cmd,"\" command failed", sep=""))
}
