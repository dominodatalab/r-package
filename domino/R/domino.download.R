#' @title domino.download
#' @name domino.download
#' 
#' @description Downloads the latest Domino run results to the project's folder.
#' 
#' @usage domino.download()
#' @keywords download
#' 
#' @export

domino.download <- function() {
  domino.runCommand("download", domino.OK, "Downloading project data failed.")
}
