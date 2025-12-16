# Domino R package

This package provides bindings to interact with Domino Data Lab from R. The package now supports
direct API integration, eliminating the need for the Domino CLI in most cases.

**Note:** For legacy CLI-based usage, you still need the Domino CLI installed. You can find more 
information on setting up the Domino CLI in [this support article](http://support.dominodatalab.com/hc/en-us/articles/204856475-Installing-the-Domino-Client-CLI-).

## Installation

The Domino R package can be installed from CRAN directly using the `install.packages` command:

```R
install.packages("domino")
```

You can likewise manually obtain a tarball of the package from CRAN and install it directly:

```
R CMD install domino_X.Y.tar.gz
```

## Usage

### API-Based Authentication (Recommended)

The package now supports API-based authentication, which doesn't require the Domino CLI. You can use
API keys or service account tokens, set via environment variables or the `domino.login()` function.

**Option 1: Using Environment Variables (Recommended for Automation)**

```R
library(domino)

# Set credentials via environment variables
Sys.setenv(DOMINO_USER_API_KEY = "your-api-key-here")
Sys.setenv(DOMINO_API_HOST = "https://app.dominodatalab.com")

# No need to call domino.login() - credentials are automatically used
# Get the my-magic-project project from your Domino install
domino.get("my-magic-project")

# Trigger a run with some parameters
domino.run("main.r", "--secret-arg")

# Download changes from the domino server
domino.download()
```

**Option 2: Using domino.login() for Programmatic Configuration**

```R
library(domino)

# Authenticate with API key
domino.login(api_key = "your-api-key-here", host = "https://app.dominodatalab.com")

# Or authenticate with service account token
domino.login(token = "your-service-token-here", host = "https://app.dominodatalab.com")

# Now use Domino functions
domino.run("main.r", "--secret-arg")
domino.upload("Updated code with new features")
```

**Running Inside Domino**

When running code inside a Domino environment, authentication is handled automatically via the 
`DOMINO_API_PROXY` environment variable. No credentials needed:

```R
library(domino)

# Automatically authenticated - no login required!
domino.run("main.r", "--secret-arg")
domino.status()
```

### Legacy CLI-Based Authentication

For backward compatibility, the package still supports CLI-based username/password authentication:

```R
library(domino)

# Login with username and password (requires Domino CLI)
domino.login("username", "password", FALSE, "https://app.dominodatalab.com")

# Use Domino functions
domino.run("main.r", "--secret-arg")
```

## Authentication Methods

The package supports multiple authentication methods, in priority order:

1. **API Proxy** (when running inside Domino) - Automatically detected, no configuration needed
2. **API Key** - Set via `DOMINO_USER_API_KEY` environment variable or `domino.login(api_key=...)`
3. **Service Account Token** - Set via `DOMINO_TOKEN` environment variable or `domino.login(token=...)`
4. **Username/Password** (Legacy) - Requires Domino CLI, use `domino.login(usernameOrEmail, password, ...)`

Full documentation and usage information is available in the manuals for various releases:

* [Release 0.3.0](https://github.com/dominodatalab/r-package/blob/master/man/domino-manual-0.3.0.pdf)

## Known Bugs

If you're getting these warning messages:

```
1: Setting LC_TIME failed, using "C"
2: Setting LC_MESSAGES failed, using "C"
3: Setting LC_MONETARY failed, using "C"
```

check your shell locales with ```locale```
set locales with ```export LC_ALL=en_US.UTF-8``` in the shell

## License

This library is made available under the MIT License. This is an open-source project of
[Domino Data Lab](https://www.dominodatalab.com).
