#' @title domino.reset
#' @name domino.reset
#' 
#' @description Resets Domino project.
#' 
#' @usage domino.reset()
#' @keywords reset
#' @export

domino.reset <- function() {
  domino.runCommand("reset")
}
