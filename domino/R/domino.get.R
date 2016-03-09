#' @title domino.get
#' @name domino.get
#' 
#' @description Downloads given project data from Domino.
#' Changes working directory to the project's directory.
#' 
#' @usage # Usage without username 
#' domino.get("projectName")
#' 
#' @param projectName String containing project name. It can be prefixed by 
#' username and slash. Ex. \code{"jglodek/quick-start"}.
#' 
#' @keywords get
#' 
#' @examples
#' \dontrun{
#' # in directory ./
#' domino.get("my-project-in-the-cloud")
#' # current working directory is now switched to ./my-project-in-the-cloud 
#' and the directory
#' # is filled with files from Domino server.
#' 
#' # The name of the project is prepended with username
#'     domino.get("jglodek/my-project-in-the-cloud")
#' }
#' @export


domino.get <- function(projectName) {
  if(missing(projectName)) {
    stop("Missing parameters for get command. Proper usage:domino.get(projectName)", call.=FALSE)
  }
  cmd = paste("get", projectName)
  goToProjectCallback = function(){
    domino.jumpToProjectsWorkingDirectory(projectName)
  }
  domino.runCommand(cmd, goToProjectCallback, "Downloading project data failed")
}
