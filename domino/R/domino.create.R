#' @title domino.create
#' @name domino.create
#' @description Creates Domino project. Changes working directory to new 
#' project's one.
#' 
#' This function supports both API-based and CLI-based execution. If API credentials
#' are configured (via \code{domino.login()} or environment variables), it will use
#' the REST API. Otherwise, it falls back to CLI-based execution.
#' 
#' @param projectName String that will be the name of the new project.
#' @param ownerId (API mode only) Owner ID for the project. If not provided, will use current user's ID.
#' @param visibility (API mode only) Project visibility. Can be "public" or "private". Defaults to "private".
#' @param description (API mode only) Project description. Defaults to empty string if not provided.
#'
#' @usage domino.create(projectName, ownerId = NULL, visibility = "private", description = NULL)
#' 
#' @examples 
#' \dontrun{
#' # API mode (after domino.login() with api_key or token)
#' domino.create("my-new-project")
#' domino.create("my-new-project", visibility = "public", description = "My project description")
#' 
#' # CLI mode (requires Domino CLI installed)
#' domino.create("my-new-project")
#' }
#' @keywords create
#' @export

domino.create <- function(projectName, ownerId = NULL, visibility = "private", description = NULL) {
  if(missing(projectName)) {
    stop("Missing parameters for create command. Proper usage: domino.create(projectName)", call. = FALSE)
  }
  
  # Check if we have API credentials or are using proxy
  .domino.api.init()
  using_proxy <- exists("using_proxy", envir = domino_api) && domino_api$using_proxy
  has_api_auth <- (using_proxy ||
                   nzchar(domino_api$api_key %||% "") || 
                   nzchar(domino_api$auth_token %||% "") ||
                   nzchar(Sys.getenv("DOMINO_USER_API_KEY", "")) ||
                   nzchar(Sys.getenv("DOMINO_TOKEN", "")))
  
  if (has_api_auth) {
    # API mode
    return(.domino.create.api(projectName, ownerId = ownerId, visibility = visibility, description = description))
  } else {
    # CLI mode (legacy)
    cmd <- paste("create", projectName)
    goToProjectCallback <- function(){
      domino.jumpToProjectsWorkingDirectory(projectName)
    }
    domino.runCommand(cmd, goToProjectCallback, "Creating project failed")
  }
}

# API-based create implementation
.domino.create.api <- function(projectName, ownerId = NULL, visibility = "private", description = NULL) {
  
  # Validate inputs
  projectName <- .domino.validate.project.name(projectName)
  
  # Validate visibility
  if (!is.null(visibility) && !visibility %in% c("public", "private")) {
    stop("Visibility must be either 'public' or 'private'")
  }
  
  # Validate description - default to empty string if not provided (API requires it)
  if (is.null(description)) {
    description <- ""
  } else {
    if (!is.character(description)) {
      stop("Description must be a string")
    }
    description <- trimws(description)
    if (nchar(description) > 1000) {
      stop("Description is too long (max 1000 characters)")
    }
  }
  
  # Get owner ID if not provided
  if (is.null(ownerId)) {
    # Try to get current user from API
    user_result <- .domino.api.request("GET", "/v4/users/self")
    if (!is.null(user_result) && user_result$success && !is.null(user_result$data$id)) {
      ownerId <- user_result$data$id
    } else {
      stop("Could not determine owner ID. Please provide ownerId parameter or ensure you are authenticated.")
    }
  }
  
  # Build API request payload according to /api/projects/beta/projects schema
  # Description is required by the API, so always include it (defaults to empty string)
  payload <- list(
    name = projectName,
    ownerId = ownerId,
    visibility = visibility,
    description = description
  )
  
  # Make API request
  endpoint <- "/api/projects/beta/projects"
  result <- .domino.api.request("POST", endpoint, body = payload)
  
  if (!result$success) {
    # Include URL in error message for debugging
    url_info <- if (!is.null(result$url)) paste0(" (URL: ", result$url, ")") else ""
    stop("Failed to create project", url_info, ": ", result$error, call. = FALSE)
  }
  
  # Return project information
  project_data <- result$data
  
  message("Project created successfully")
  if (!is.null(project_data$id)) {
    message("Project ID: ", project_data$id)
  }
  if (!is.null(project_data$name)) {
    message("Project name: ", project_data$name)
  }
  
  # Change to project directory (same behavior as CLI mode)
  # Note: API doesn't automatically create local directory, so we need to create it
  # The project name might be sanitized by the API, so use the returned name if available
  final_project_name <- if (!is.null(project_data$name)) project_data$name else projectName
  project_dir <- domino.projectNameWithoutUser(final_project_name)
  
  # Create directory if it doesn't exist (API mode doesn't create it automatically)
  if (!dir.exists(project_dir)) {
    dir.create(project_dir, recursive = TRUE)
    message("Created local project directory: ", project_dir)
  }
  
  domino.jumpToProjectsWorkingDirectory(final_project_name)
  
  return(invisible(project_data))
}
