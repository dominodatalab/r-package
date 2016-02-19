#' @title domino.create
#' @name domino.create
#' @description Creates Domino project. Changes working directory to new 
#' project's one.
#' 
#' @param projectName String that will be the name of the new project.
#'
#' @usage domino.create(projectName) 
#' 
#' @examples 
#' \dontrun{
#' # in directory ./
#' domino.create("my-new-project")
#' # current working directory is now switched to ./my-new-project and new
#' project is initialized.
#' }
#' @keywords create
#' @export

domino.create <- function(projectName) {
  if(missing(projectName)) {
    stop("Missing parameters for create command. Proper usage:domino.create(projectName)", call.=FALSE)
  }
  cmd = paste("create", projectName)
  goToProjectCallback = function(){
    domino.jumpToProjectsWorkingDirectory(projectName)
  }
  domino.runCommand(cmd, goToProjectCallback, "Creating project failed")
}
