#' @title domino.debug
#' @name domino.debug
#' 
#' @description Shows Domino debug information.
#' @usage domino.debug()
#' 
#' @keywords debug
#' @export

domino.debug <- function() {
  domino.runCommand("--debug")
}
