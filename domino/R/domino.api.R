# API Client Module for Domino REST API
# This module handles authentication and HTTP requests to Domino's REST API
#
# When running inside Domino, the DOMINO_API_PROXY environment variable will be set.
# In this case, requests are sent to the proxy URL and authentication is handled
# automatically by the proxy (no API keys or tokens needed).
#
# When running outside Domino, use DOMINO_API_HOST and provide API keys or tokens
# via DOMINO_USER_API_KEY or DOMINO_TOKEN environment variables, or via domino.login().

# Package environment for API configuration
domino_api <- new.env()

# Initialize API configuration
.domino.api.init <- function() {
  if (!exists("base_url", envir = domino_api)) {
    # Check for DOMINO_API_PROXY first (when running inside Domino)
    proxy_url <- Sys.getenv("DOMINO_API_PROXY", "")
    if (nzchar(proxy_url)) {
      # Normalize proxy URL (remove trailing slash, ensure proper format)
      proxy_url <- gsub("/$", "", proxy_url)
      # Proxy URLs typically don't need https:// prefix, but handle if present
      if (!grepl("^https?://", proxy_url)) {
        # Most proxies are HTTP, but let's default to HTTP for proxy
        # (proxy will handle SSL termination)
        proxy_url <- paste0("http://", proxy_url)
      }
      domino_api$base_url <- proxy_url
      domino_api$using_proxy <- TRUE
    } else {
      domino_api$base_url <- Sys.getenv("DOMINO_API_HOST", "https://app.dominodatalab.com")
      domino_api$using_proxy <- FALSE
    }
  }
  if (!exists("api_key", envir = domino_api)) {
    domino_api$api_key <- Sys.getenv("DOMINO_USER_API_KEY", "")
  }
  if (!exists("auth_token", envir = domino_api)) {
    domino_api$auth_token <- Sys.getenv("DOMINO_TOKEN", "")
  }
}

# Set API host/base URL
.domino.api.set.base_url <- function(host) {
  # Check if we're using DOMINO_API_PROXY - if so, don't override it
  .domino.api.init()
  if (exists("using_proxy", envir = domino_api) && domino_api$using_proxy) {
    # When using proxy, don't allow base URL to be overridden
    warning("DOMINO_API_PROXY is set; using proxy URL instead of provided host")
    return(invisible(NULL))
  }
  
  # Normalize host URL
  host <- gsub("/$", "", host)  # Remove trailing slash
  if (!grepl("^https?://", host)) {
    host <- paste0("https://", host)
  }
  domino_api$base_url <- host
  domino_api$using_proxy <- FALSE
}

# Set API key for authentication
.domino.api.set.api_key <- function(api_key) {
  domino_api$api_key <- api_key
}

# Set auth token (service account token) for authentication
.domino.api.set.auth_token <- function(token) {
  domino_api$auth_token <- token
}

# Get authentication headers
.domino.api.get.auth.headers <- function() {
  .domino.api.init()
  
  headers <- httr::add_headers(
    "Content-Type" = "application/json"
  )
  
  # If using DOMINO_API_PROXY, skip authentication (proxy handles it)
  if (exists("using_proxy", envir = domino_api) && domino_api$using_proxy) {
    return(headers)
  }
  
  # Prefer API key if available, otherwise use token
  if (nzchar(domino_api$api_key)) {
    headers <- httr::add_headers(
      "X-Domino-Api-Key" = domino_api$api_key,
      "Content-Type" = "application/json"
    )
  } else if (nzchar(domino_api$auth_token)) {
    headers <- httr::add_headers(
      "Authorization" = paste("Bearer", domino_api$auth_token),
      "Content-Type" = "application/json"
    )
  } else {
    stop("No authentication credentials found. Set DOMINO_USER_API_KEY or DOMINO_TOKEN environment variable, or call domino.login() with api_key or token parameter.")
  }
  
  return(headers)
}

# Get base URL
.domino.api.get.base_url <- function() {
  .domino.api.init()
  return(domino_api$base_url)
}

# Make API request with error handling
.domino.api.request <- function(method, endpoint, body = NULL, ...) {
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("httr package is required for API functionality. Install it with: install.packages('httr')")
  }
  
  base_url <- .domino.api.get.base_url()
  url <- paste0(base_url, endpoint)
  headers <- .domino.api.get.auth.headers()
  
  # Make request based on method
  if (method == "GET") {
    response <- httr::GET(url, headers, ...)
  } else if (method == "POST") {
    if (!is.null(body)) {
      response <- httr::POST(url, headers, body = body, encode = "json", ...)
    } else {
      response <- httr::POST(url, headers, ...)
    }
  } else if (method == "PUT") {
    response <- httr::PUT(url, headers, body = body, encode = "json", ...)
  } else if (method == "DELETE") {
    response <- httr::DELETE(url, headers, ...)
  } else {
    stop(paste("Unsupported HTTP method:", method))
  }
  
  # Check response status
  status_code <- httr::status_code(response)
  
  if (status_code >= 200 && status_code < 300) {
    # Success
    content <- httr::content(response, as = "parsed")
    return(list(success = TRUE, data = content, response = response))
  } else {
    # Error
    error_content <- tryCatch(
      httr::content(response, as = "parsed"),
      error = function(e) httr::content(response, as = "text")
    )
    
    error_msg <- "API request failed"
    if (is.list(error_content) && "message" %in% names(error_content)) {
      error_msg <- error_content$message
    } else if (is.character(error_content)) {
      error_msg <- error_content
    }
    
    return(list(
      success = FALSE, 
      status_code = status_code,
      error = error_msg,
      response = response
    ))
  }
}

# Detect current project from .domino directory or config
.domino.api.get.current.project <- function() {
  # Look for .domino directory or domino.yaml in current or parent directories
  current_dir <- getwd()
  max_depth <- 10
  depth <- 0
  
  while (depth < max_depth) {
    domino_dir <- file.path(current_dir, ".domino")
    domino_yaml <- file.path(current_dir, "domino.yaml")
    
    if (dir.exists(domino_dir) || file.exists(domino_yaml)) {
      # Try to read project info from config
      # For now, return NULL and let caller handle it
      # In a full implementation, we'd parse the config file
      return(list(path = current_dir))
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

# Parse project name (owner/project-name format)
.domino.api.parse.project.name <- function(project_name) {
  parts <- strsplit(project_name, "/")[[1]]
  if (length(parts) == 2) {
    return(list(owner = parts[1], project = parts[2]))
  } else if (length(parts) == 1) {
    # If no owner specified, we'd need to get it from API or config
    # For now, return NULL for owner
    return(list(owner = NULL, project = parts[1]))
  } else {
    stop(paste("Invalid project name format:", project_name))
  }
}

# Helper function to check if value is NULL (similar to %||% from rlang)
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

