#' @title domino.upload
#' @name domino.upload
#' 
#' @description Uploads local version of Domino project files to the server.
#' 
#' @usage domino.upload(commitMessage)
#' 
#' @param commitMessage Commit message for Domino client, explaining changes you
#' did to the project code in recent update. Ex. \code{"updated project files"}
#' 
#' @keywords upload
#' @export

domino.upload <- function(commitMessage) {
  if(missing(commitMessage)) {
    domino.runCommand("upload", domino.OK, "Uploading project data failed.")
  } else {
    cmd = paste("upload -m \"", commitMessage, "\"", sep="");
    domino.runCommand(cmd, domino.OK, "Uploading project data failed.")
  }
}

