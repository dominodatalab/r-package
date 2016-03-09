#' @title domino.runCommand
#' @name domino.runCommand
#' 
#' @description Runs domino client command and runs success callback or shows 
#' failure message
#' 
#' @usage domino.runCommand(commandAndArgs, successCallback = domino.OK,
#' failureMessage = "Executing the command failed", stdInput = FALSE)
#' 
#' @param commandAndArgs The \code{commandAndArgs} argument is a string that 
#' matches standard domino client's syntax,ex. \code{"get quick-start"} or 
#' \code{"download"}.
#' @param successCallback A function that will be called when domino command 
#' executes successfuly. Defaults to noop function.
#' @param failureMessage A string representing failure message that should be printed when command fails. Has default value.
#' @param stdInput Internal string data that is pushed to domino client's stdio
#' streams. Default is no stdio stream input. 
#' 
#' @examples
#' \dontrun{
#' success <- function() {
#' print("Success!")
#' }
#' domino.runCommand("run main.R 1 2 3",success, "failed to succeed")
#' # Runs command "run main.R 1 2 3" and 
#' # calls 'success' function if domino command ends successfuly.
#' # Prints error message  - "failed to succeed" if domino command fails.
#' }
#' 
#' @keywords command
#' @export

domino.runCommand <- function(commandAndArgs, successCallback=domino.OK, failureMessage="Executing the command failed", stdInput=FALSE) {
  if(domino$command_is_in_the_path) {
    cmd = paste("domino --source R", commandAndArgs)
    result = domino.call(cmd, stdInput)
    
    if (result == 0) {
      successCallback()
    } else {
      stop(failureMessage, call.=FALSE)
    }
  } else {
    # Call domino client directly from default path if we know that it's not in the PATH
    domino.runCommandFromDefaultPath(commandAndArgs, successCallback, failureMessage, stdInput)
  }
}


# Runs Domino client command from default installer path
# calls successCallback if command execution succedded
# prints failure message if command execution failed
# prints domino.handleCommandNotFound message when there was no domino client found in default location.
domino.runCommandFromDefaultPath <- function(commandAndArgs, successCallback=domino.OK, failureMessage="Executing the command failed", stdInput=FALSE) {
  # handling of command not found
  prefix = domino.osSpecificPrefixOfDominoCommand()
  # join without spaces, as prefix and domino must stick together and commandAndArgs is already a string with spaces
  fixedCmd = paste(prefix, "domino --source R ", commandAndArgs, sep="")
  fixedResult = domino.call(fixedCmd, stdInput)
  if (fixedResult == 0) {
    return(successCallback())
  }
  else if (fixedResult == 127) {
    domino.handleCommandNotFound(failureMessage)
  }
  else {
    stop(failureMessage, call.=FALSE)
  }
}