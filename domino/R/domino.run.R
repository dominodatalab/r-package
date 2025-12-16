#' @title domino.run
#' @name domino.run
#'
#' @description Runs your project on Domino servers with given parameters.
#' 
#' This function supports both API-based and CLI-based execution. If API credentials
#' are configured (via \code{domino.login()} or environment variables), it will use
#' the REST API. Otherwise, it falls back to CLI-based execution.
#'
#' @usage domino.run(..., publishApiEndpoint = FALSE, project = NULL, 
#'                   owner = NULL, title = NULL, commitId = "master")
#'
#' @param ... Command arguments that will be combined into the command to run.
#'   Ex. \code{domino.run("main.R", "arg1", "arg2")} will run \code{Rscript main.R arg1 arg2}
#' @param publishApiEndpoint Whether or not to republish the project's API endpoint 
#'   at the end of the run. (CLI mode only)
#' @param project Project name. If not provided, will attempt to detect from current directory.
#' @param owner Project owner/username. If not provided, will attempt to detect or use current user.
#' @param title Optional title for the run (API mode only)
#' @param commitId Git commit ID to use for the run. Defaults to "master" (API mode only)
#'
#' @return In API mode, returns a list containing run information including run ID.
#'   In CLI mode, returns nothing on success.
#'
#' @examples
#' \dontrun{
#' # API mode (after domino.login() with api_key or token)
#' domino.run("main.R", "arg1", "arg2")
#' domino.run("main.R", title = "My custom run title")
#' 
#' # CLI mode (requires Domino CLI installed)
#' domino.run("main.R", "arg1", "arg2")
#' }
#' 
#' @export

domino.run <- function(..., publishApiEndpoint = FALSE, project = NULL, 
                       owner = NULL, title = NULL, commitId = "master") {
  
  # Get command arguments
  args <- list(...)
  
  if (length(args) == 0) {
    stop("Missing parameters for run command. Example usage: domino.run('main.R', param1, param2, param3, ...)", call. = FALSE)
  }
  
  # Check if we have API credentials or are using proxy
  .domino.api.init()
  # Using proxy means we can use API (proxy handles auth)
  using_proxy <- exists("using_proxy", envir = domino_api) && domino_api$using_proxy
  has_api_auth <- (using_proxy ||
                   nzchar(domino_api$api_key %||% "") || 
                   nzchar(domino_api$auth_token %||% "") ||
                   nzchar(Sys.getenv("DOMINO_USER_API_KEY", "")) ||
                   nzchar(Sys.getenv("DOMINO_TOKEN", "")))
  
  if (has_api_auth) {
    # API mode
    return(.domino.run.api(args, project = project, owner = owner, 
                           title = title, commitId = commitId))
  } else {
    # CLI mode (legacy)
    cmd <- "run"
    
    if (domino.notFalse(publishApiEndpoint)) {
      cmd <- paste(cmd, "--publish-api-endpoint")
    }
    
    # Convert args to strings and paste together
    cmd_args <- vapply(args, function(x) {
      if (is.character(x)) x else as.character(x)
    }, character(1))
    
    cmd <- paste(cmd, paste(cmd_args, collapse = " "))
    
    domino.runCommand(cmd, domino.OK, paste("Running the \"", cmd, "\" command failed", sep = ""))
  }
}

# API-based run implementation
.domino.run.api <- function(args, project = NULL, owner = NULL, 
                            title = NULL, commitId = "master") {
  
  # Detect project if not provided
  if (is.null(project)) {
    project_info <- .domino.detect.project()
    if (!is.null(project_info)) {
      project <- project_info$project
      if (is.null(owner) && !is.null(project_info$owner)) {
        owner <- project_info$owner
      }
    }
    
    if (is.null(project)) {
      stop("Could not detect project. Please specify project parameter or run from a Domino project directory.")
    }
  }
  
  # If owner not provided, try to get from API or use project name format
  if (is.null(owner)) {
    # Try to get current user from API
    user_result <- .domino.api.request("GET", "/v4/users/self")
    if (!is.null(user_result) && user_result$success && 
        !is.null(user_result$data$userName)) {
      owner <- user_result$data$userName
    } else {
      # If project name contains owner/project format, parse it
      if (grepl("/", project)) {
        parts <- strsplit(project, "/")[[1]]
        owner <- parts[1]
        project <- parts[2]
      } else {
        stop("Could not determine project owner. Please specify owner parameter or ensure project name is in 'owner/project' format.")
      }
    }
  }
  
  # Get projectId from project name and owner
  # We need to look up the project ID using the API
  project_id <- .domino.get.project.id(owner, project)
  if (is.null(project_id)) {
    stop(paste("Could not find project '", project, "' for owner '", owner, "'. Please verify the project name and owner.", sep = ""))
  }
  
  # Build command from arguments
  # Convert all arguments to strings and join them
  cmd_parts <- vapply(args, function(x) {
    if (is.character(x)) x else as.character(x)
  }, character(1))
  
  # Join command parts with spaces to form a single command string
  # For R scripts, check if we need to add Rscript
  if (length(cmd_parts) > 0) {
    first_arg <- cmd_parts[1]
    # If it's an R file, prepend Rscript
    if (grepl("\\.r$|\\.R$", first_arg, ignore.case = TRUE)) {
      run_command <- paste(c("Rscript", cmd_parts), collapse = " ")
    } else {
      run_command <- paste(cmd_parts, collapse = " ")
    }
  } else {
    stop("No command provided to run")
  }
  
  # Build API request payload according to /api/jobs/v1/jobs schema
  payload <- list(
    projectId = project_id,
    runCommand = run_command
  )
  
  # Add optional fields
  if (!is.null(commitId) && commitId != "master") {
    payload$commitId <- commitId
  }
  
  if (!is.null(title)) {
    payload$title <- title
  }
  
  # Make API request
  endpoint <- "/api/jobs/v1/jobs"
  result <- .domino.api.request("POST", endpoint, body = payload)
  
  if (!result$success) {
    # Include URL in error message for debugging
    url_info <- if (!is.null(result$url)) paste0(" (URL: ", result$url, ")") else ""
    stop("Failed to start run", url_info, ": ", result$error, call. = FALSE)
  }
  
  # Return run information
  run_data <- result$data
  
  message("Run started successfully")
  if (!is.null(run_data$id)) {
    message("Job ID: ", run_data$id)
  } else if (!is.null(run_data$runId)) {
    message("Run ID: ", run_data$runId)
  }
  if (!is.null(run_data$status)) {
    message("Status: ", run_data$status)
  }
  
  return(invisible(run_data))
}

# Get project ID from owner and project name
.domino.get.project.id <- function(owner, project_name) {
  # Try to get project by owner and name
  # API endpoint: GET /v4/projects/{owner}/{projectName}
  endpoint <- paste0("/v4/projects/", owner, "/", project_name)
  result <- .domino.api.request("GET", endpoint)
  
  if (result$success && !is.null(result$data$id)) {
    return(result$data$id)
  }
  
  # If that doesn't work, try alternative endpoint formats
  # Some APIs use /v4/projects?owner={owner}&name={name}
  endpoint <- paste0("/v4/projects?owner=", owner, "&name=", project_name)
  result <- .domino.api.request("GET", endpoint)
  
  if (result$success) {
    # If it's a list, find the matching project
    if (is.list(result$data)) {
      if (is.data.frame(result$data) && "id" %in% names(result$data)) {
        # If it's a data frame with an id column
        return(result$data$id[1])
      } else if (is.list(result$data) && length(result$data) > 0) {
        # If it's a list of projects, find the one matching the name
        for (proj in result$data) {
          if (is.list(proj) && !is.null(proj$name) && proj$name == project_name) {
            return(proj$id)
          }
        }
      }
    }
  }
  
  return(NULL)
}

# Detect project from current directory
.domino.detect.project <- function() {
  # Look for .domino directory or domino.yaml in current or parent directories
  current_dir <- getwd()
  max_depth <- 10
  depth <- 0
  
  while (depth < max_depth) {
    domino_dir <- file.path(current_dir, ".domino")
    domino_yaml <- file.path(current_dir, "domino.yaml")
    
    if (dir.exists(domino_dir)) {
      # Try to read project info from .domino/config file
      config_file <- file.path(domino_dir, "config")
      if (file.exists(config_file)) {
        config_lines <- readLines(config_file, warn = FALSE)
        project_line <- grep("^project=", config_lines, value = TRUE)
        if (length(project_line) > 0) {
          project_name <- sub("^project=", "", project_line[1])
          parsed <- .domino.api.parse.project.name(project_name)
          return(parsed)
        }
      }
    }
    
    if (file.exists(domino_yaml)) {
      # Try to parse YAML (would need yaml package, but for now just check existence)
      # In a full implementation, we'd parse the YAML to get project name
    }
    
    parent_dir <- dirname(current_dir)
    if (parent_dir == current_dir) {
      break  # Reached root
    }
    current_dir <- parent_dir
    depth <- depth + 1
  }
  
  return(NULL)
}
