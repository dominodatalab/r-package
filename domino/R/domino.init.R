#' @title domino.init
#' @name domino.init
#' 
#' @description Initializes new domino project in current directory.
#' It can also set arbitrary name to the project,
#' even if different from current directory name.
#' 
#' @usage 
#' # inits a project inside current directory, with given name.
#' # ex. if run in ~/my_project, with "my_name" as a param,
#' # it will create a Domino project called my-param inside ~/my_project directory.
#' domino.init("projectName")
#' 
#' @param projectName Project name for the project that will be created in 
#' current working directory.
#' 
#' @keywords init
#' 
#' @examples
#' \dontrun{
#' # in directory ./
#' domino.init("my-new-project")
#' # new project with name "my-new-project" is initialized inside current directory.
#' }
#' 
#' @export


domino.init <- function(projectName) {
  if(missing(projectName)) {
    stop("Missing parameters for init command. Proper usage:domino.init(projectName)", call.=FALSE)
  }
  cmd = paste("init", projectName)
  domino.runCommand(cmd, domino.OK, "Initializing the project failed")
}

