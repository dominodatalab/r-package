#' @title domino.status
#' @name domino.status
#' 
#' @description Shows status of current Domino project.
#' @usage domino.status(...)
#' 
#' @param ... Arguments normally passed to the domino status command.
#' 
#' @keywords status
#' @export

domino.status <- function(...) {
  cmd = paste("status", ...)
  domino.runCommand(cmd, domino.OK)
}
