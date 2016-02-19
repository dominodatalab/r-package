#' @title domino.sync
#' @name domino.sync
#' 
#' @description Synchronizes the local project copy with the server project 
#' copy, by running 'download' followed by 'upload'.
#' 
#' @usage domino.sync()
#' @keywords sync
#' 
#' @export

domino.sync <- function() {
  domino.runCommand("sync", domino.OK, "Synchronizing project data failed.")
}

