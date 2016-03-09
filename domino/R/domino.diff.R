#' @title domino.diff
#' @name domino.diff
#' @description Shows changes between your local version of project's data,
#' and the version uploaded to the Domino servers.
#' 
#' @usage domino.diff()
#' @keywords diff
#' 
#' @export

domino.diff <- function() {
  domino.runCommand("diff")
}
