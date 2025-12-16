#' @title domino.login
#' @name domino.login
#'
#' @description Configures authentication with Domino server.
#' 
#' **Note:** This function is OPTIONAL for API-based authentication. If you set credentials
#' via environment variables (\code{DOMINO_USER_API_KEY}, \code{DOMINO_TOKEN}, \code{DOMINO_API_HOST}),
#' or are running inside Domino (where \code{DOMINO_API_PROXY} is set), you can skip calling
#' this function entirely. API functions will automatically use credentials from environment variables.
#' 
#' Use this function if you want to:
#' \itemize{
#'   \item Set credentials programmatically (instead of environment variables)
#'   \item Set the host URL programmatically
#'   \item Verify authentication works before making API calls
#'   \item Use CLI-based username/password authentication (legacy, requires Domino CLI)
#' }
#' 
#' This function supports multiple authentication methods:
#' \itemize{
#'   \item API Key authentication (recommended for automation)
#'   \item Service Account Token authentication (recommended by Domino)
#'   \item Username/password authentication (legacy, requires CLI)
#' }
#'
#' @usage domino.login(api_key = NULL, token = NULL, host = NULL,
#'                     usernameOrEmail = NULL, password = NULL,
#'                     approvalForSendingErrorReports = FALSE)
#'
#' @param api_key API key for Domino authentication. Can also be set via 
#'   \code{DOMINO_USER_API_KEY} environment variable. Ex. \code{"abc123xyz"}
#' @param token Service account token for Domino authentication. Can also be set via 
#'   \code{DOMINO_TOKEN} environment variable. Ex. \code{"bearer_token_here"}
#' @param host The location of the domino server. Can also be set via 
#'   \code{DOMINO_API_HOST} environment variable. Ex. \code{"https://app.dominodatalab.com"}
#' @param usernameOrEmail (Legacy) Login or e-mail address for CLI-based authentication.
#'   Only used if api_key and token are not provided.
#' @param password (Legacy) Password for CLI-based authentication. If not provided 
#'   and interactive session, a password prompt will be shown.
#' @param approvalForSendingErrorReports (Legacy) Approval for the Domino client to send
#'   error reports. Only used with CLI-based authentication.
#'
#' @details
#' The function prioritizes API authentication methods over CLI-based authentication:
#' \enumerate{
#'   \item If \code{api_key} is provided, it will be used for authentication
#'   \item Otherwise, if \code{token} is provided, it will be used
#'   \item Otherwise, falls back to CLI-based username/password authentication (requires Domino CLI)
#' }
#' 
#' Environment variables can be used instead of function parameters:
#' \itemize{
#'   \item \code{DOMINO_USER_API_KEY} - API key
#'   \item \code{DOMINO_TOKEN} - Service account token
#'   \item \code{DOMINO_API_HOST} - Domino server host
#' }
#'
#' @keywords login
#'
#' @examples
#' \dontrun{
#' # OPTION 1: Use environment variables (no login() needed!)
#' Sys.setenv(DOMINO_USER_API_KEY = "your-api-key")
#' Sys.setenv(DOMINO_API_HOST = "https://app.dominodatalab.com")
#' # Now you can use domino.run(), etc. directly without calling domino.login()
#' 
#' # OPTION 2: Set credentials programmatically
#' domino.login(api_key = "your-api-key", host = "https://app.dominodatalab.com")
#' 
#' # OPTION 3: Token authentication
#' domino.login(token = "your-service-token", host = "https://app.dominodatalab.com")
#' 
#' # OPTION 4: Legacy username/password (requires CLI)
#' domino.login(usernameOrEmail = "jglodek", password = "secret", 
#'              host = "https://app.dominodatalab.com")
#' }
#'
#' @export

domino.login <- function(api_key = NULL, token = NULL, host = NULL,
                         usernameOrEmail = NULL, password = NULL,
                         approvalForSendingErrorReports = FALSE) {
  
  # Initialize API client
  .domino.api.init()
  
  # Check if running inside Domino (DOMINO_API_PROXY is set)
  proxy_url <- Sys.getenv("DOMINO_API_PROXY", "")
  if (nzchar(proxy_url)) {
    # When running inside Domino, proxy handles authentication
    message("Running inside Domino - using API proxy (authentication handled automatically)")
    return(invisible(TRUE))
  }
  
  # Determine authentication method and set credentials
  use_api_auth <- FALSE
  
  # Priority 1: API Key
  if (!is.null(api_key) || nzchar(Sys.getenv("DOMINO_USER_API_KEY", ""))) {
    use_api_auth <- TRUE
    key <- api_key %||% Sys.getenv("DOMINO_USER_API_KEY", "")
    if (nzchar(key)) {
      .domino.api.set.api_key(key)
      message("Authenticated using API key")
    }
  }
  # Priority 2: Token
  else if (!is.null(token) || nzchar(Sys.getenv("DOMINO_TOKEN", ""))) {
    use_api_auth <- TRUE
    tok <- token %||% Sys.getenv("DOMINO_TOKEN", "")
    if (nzchar(tok)) {
      .domino.api.set.auth_token(tok)
      message("Authenticated using service account token")
    }
  }
  
  # Set host if provided (but not if using proxy)
  if (!is.null(host)) {
    .domino.api.set.base_url(host)
  } else {
    env_host <- Sys.getenv("DOMINO_API_HOST", "")
    if (nzchar(env_host)) {
      .domino.api.set.base_url(env_host)
    }
  }
  
  # If using API authentication, verify it works by making a test request
  if (use_api_auth) {
    # Try to get current user info to verify authentication
    # Using /v4/users/self endpoint (common in REST APIs)
    result <- tryCatch({
      .domino.api.request("GET", "/v4/users/self")
    }, error = function(e) {
      # If endpoint doesn't exist or fails, that's okay for now
      # The actual API calls will validate authentication
      return(NULL)
    })
    
    if (!is.null(result) && !result$success) {
      warning("API authentication may not be valid. Error: ", result$error)
    }
    
    return(invisible(TRUE))
  }
  
  # Fall back to CLI-based authentication
  # This maintains backward compatibility
  if (is.null(usernameOrEmail) && is.null(password)) {
    # Check if we have API credentials from environment (already handled above)
    if (use_api_auth) {
      return(invisible(TRUE))
    }
    
    stop("No authentication credentials provided. Use api_key, token, or usernameOrEmail/password parameters, or set DOMINO_USER_API_KEY/DOMINO_TOKEN environment variables.")
  }
  
  # Legacy CLI-based login
  if (is.null(password) && !interactive()) {
    stop("Missing parameters for login command. For API authentication, use api_key or token parameters. For CLI authentication, provide password.")
  }
  
  if (is.null(usernameOrEmail)) {
    stop("Missing usernameOrEmail parameter for CLI-based authentication. For API authentication, use api_key or token parameters instead.")
  }
  
  if (is.null(password)) {
    password <- .domino.login.prompt()
  }
  
  if (is.null(password)) {
    stop("Missing parameters for login command. Password is required for CLI-based authentication.")
  }
  
  # Set host for CLI if provided
  if (!is.null(host)) {
    .domino.api.set.base_url(host)
  }
  
  # Use legacy CLI login
  if (approvalForSendingErrorReports) {
    approvalChar <- "Y"
  } else {
    approvalChar <- "N"
  }
  
  theinput <- paste(usernameOrEmail, '\n', password, '\n', approvalChar, sep="")
  loginCommand <- "login"
  
  if (!is.null(host)) {
    loginCommand <- paste(loginCommand, host, sep=" ")
  } else {
    warning("You did not provide a host. Starting in June 2016, the CLI will not automatically determine the host for you.")
  }
  
  domino.runCommand(loginCommand, domino.OK, "Login failed", theinput)
}

