
# Environment(package global) variable holding infomation about domino client
# If this gets assigned with true, the commands will be tried to run from default installation path
domino <- new.env()

#Calls a program with or without stdin
domino.call <- function(cmd, stdInput=FALSE) {
  if(domino.notFalse(stdInput)){
    return(system(cmd, input=stdInput))
  } else {
    return(system(cmd))
  }
}

domino.handleCommandNotFound = function(failureMessage){
  stop(paste("Couldn't find domino client in the PATH or in default locations.
  Add domino client directory path to PATH environment variable.
  If you don't have domino client installed follow instructions on 'http://help.dominodatalab.com/client'.
  If you use R-Studio Domino on GNU/Linux through a desktop launcher, add domino path to the .desktop file.

  If you need more help, email support@dominodatalab.com or visit http://help.dominodatalab.com/troubleshooting

  - ", failureMessage), call.=FALSE)
}

domino.osSpecificPrefixOfDominoCommand <- function() {
  os = Sys.info()["sysname"]
  if(os == "Darwin") {return("/Applications/domino/")}
  else if (os =="Linux") {return("~/domino/")}
  else if (os == "Windows") {return("c:\\program files (x86)\\domino\\")}
  else { print("Your operating system is not supported by domino R package.")}
}

domino.notFalse <- function(arg) {
  if (arg == FALSE){FALSE} else { TRUE}
}

domino.OK <- function(){return(0)}

domino.projectNameWithoutUser <- function(projectName) {
  rev(unlist(strsplit(projectName, "/")))[1]
}

domino.jumpToProjectsWorkingDirectory <- function(projectName) {
  setwd(paste("./",domino.projectNameWithoutUser(projectName), sep=""))
  print("Changed working directory to new project's directory.")
}


# Checks whether domino is in the system's path, by running a 'dummy' command. 
# If the result is an error, domino it's safe to assume that domino is not found
.is.domino.in.path <- function() {
  result <- try(
    system("domino help", ignore.stdout=TRUE, ignore.stderr=TRUE), 
    silent = TRUE
    )
  if(!inherits(result, "try-error") && result != 127) {
    TRUE
  } else {
    FALSE
  }
}

.open.rStudio.login.prompt <- function(message){
  if(Sys.getenv("RSTUDIO") != "1"){
    stop("The system is not running in RStudio")
  }
  
  if(!("tools:rstudio" %in% search())){
    stop("Cannot locate RStudio tools")
  }
  
  toolsEnv <- as.environment("tools:rstudio")
  rStudioLoginPrompt <- get(".rs.askForPassword", envir=toolsEnv)
  
  rStudioLoginPrompt(message)
}

.domino.login.prompt <- function(){
  passwordPromptMessage <- "Enter your Domino password: "
  
  # if not in rstudio env or the prompt function is not found, 
  # the function will fail => fallback to readLine
  password <- try(.open.rStudio.login.prompt(passwordPromptMessage), silent=T)
  
  if(inherits(password, "try-error")){
    password <- readline("Enter your Domino password: ") 
  }
  
  if(password == ""){
    password <- NULL
  }
  
  password
}

.onAttach <- function(libname, pkgname) {
  domino$command_is_in_the_path <- .is.domino.in.path()
}

