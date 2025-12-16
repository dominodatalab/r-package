# Domino R Package Tests

This directory contains tests for the Domino R package using the `testthat` framework.

## Test Structure

The tests are organized into the following files:

- `test-login.R` - Tests for `domino.login()` function
- `test-run.R` - Tests for `domino.run()` function and validation logic
- `test-create.R` - Tests for `domino.create()` function and validation logic

## Running Tests

### Using devtools (recommended)

```r
library(devtools)
load_all("domino")
test()
```

### Using testthat directly

```r
library(testthat)
library(domino)
test_dir("domino/tests/testthat")
```

### Using R CMD check

```bash
R CMD check domino/
```

## Test Categories

### Unit Tests (No Credentials Required)

Most tests are unit tests that validate:
- Input validation functions
- Sanitization logic
- Error handling
- Function existence and structure

These tests **do not require** API credentials or the Domino CLI and can be run safely in any environment.

Examples:
- Project name validation (rejecting invalid characters, empty strings, etc.)
- Owner validation
- Commit ID format validation
- Command sanitization

### Integration Tests (Credentials Required)

Some tests verify API integration and require valid credentials:

**For API-based tests**, set one of:
- `DOMINO_USER_API_KEY` - Your Domino API key
- `DOMINO_TOKEN` - Service account token
- `DOMINO_API_PROXY` - Proxy URL (when running inside Domino)

**Optional environment variables:**
- `DOMINO_API_HOST` - Domino server host (defaults to `https://app.dominodatalab.com`)
- `DOMINO_TEST_HOST` - Override for test host URL

**For CLI-based tests**, set:
- `TESTUSER` - Domino username
- `TESTUSERPASS` - Domino password

Integration tests are wrapped in conditional blocks and will only run if credentials are available:

```r
if (nchar(Sys.getenv("DOMINO_USER_API_KEY", "")) > 0) {
  # Integration tests here
}
```

## Test Coverage

### `test-login.R`
- CLI-based login functionality
- Requires `TESTUSER` and `TESTUSERPASS` environment variables

### `test-run.R`
- **Validation Functions:**
  - Project name validation (valid/invalid patterns, length limits)
  - Owner validation
  - Commit ID validation (SHA hashes, branch/tag names)
  - Title validation
  - Command sanitization

- **Function Behavior:**
  - Missing argument detection
  - R script detection logic
  - Command building

- **API Integration** (conditional):
  - API mode detection
  - Requires `DOMINO_USER_API_KEY` or `DOMINO_TOKEN`

### `test-create.R`
- **Validation:**
  - Project name validation
  - Input validation

- **API Integration** (conditional):
  - API mode detection
  - Requires `DOMINO_USER_API_KEY` or `DOMINO_TOKEN`

## Testing Internal Functions

Some tests access internal (non-exported) functions using the `:::` operator:

```r
domino:::.domino.validate.project.name("test-project")
```

This is acceptable in tests to verify validation logic directly, but internal functions should not be used in production code.

## Example: Running Tests Locally

### 1. Unit tests only (no credentials needed):

```r
library(devtools)
load_all("domino")
test(filter = "run")  # Run only test-run.R tests
```

### 2. With API credentials:

```r
# Set credentials
Sys.setenv(DOMINO_USER_API_KEY = "your-api-key")
Sys.setenv(DOMINO_API_HOST = "https://app.dominodatalab.com")

# Run tests
library(devtools)
load_all("domino")
test()
```

### 3. With CLI credentials:

```r
# Set credentials (in shell)
export TESTUSER=your-username
export TESTUSERPASS=your-password

# Run tests
R
library(devtools)
load_all("domino")
test()
```

## Continuous Integration

For CI/CD pipelines:

1. **Unit tests** can always run (no credentials needed)
2. **Integration tests** require secure credential storage:
   - Store API keys/tokens as encrypted environment variables
   - Never commit credentials to version control
   - Use CI system's secret management features

## Writing New Tests

When adding new tests:

1. **Use testthat syntax:**
   ```r
   test_that("Description of what is tested", {
     expect_equal(actual, expected)
     expect_error(function(), "error message")
   })
   ```

2. **Keep unit tests separate from integration tests:**
   ```r
   # Unit test - no credentials needed
   test_that("Validation works", {
     expect_error(domino:::.domino.validate.project.name(""), "must be a non-empty string")
   })
   
   # Integration test - requires credentials
   if (nchar(Sys.getenv("DOMINO_USER_API_KEY", "")) > 0) {
     test_that("API call works", {
       # Test actual API interaction
     })
   }
   ```

3. **Test both success and failure cases:**
   - Valid inputs
   - Invalid inputs
   - Edge cases
   - Error conditions

4. **Use descriptive test names** that explain what is being tested

## Troubleshooting

### Tests fail with "lazy-load database is corrupt"
This is a package installation issue, not a test issue. Rebuild the package:
```r
devtools::install("domino")
```

### Integration tests don't run
Check that credentials are set:
```r
Sys.getenv("DOMINO_USER_API_KEY")
Sys.getenv("DOMINO_TOKEN")
```

### Tests timeout or hang
Integration tests making real API calls may timeout if:
- Network issues
- Invalid credentials
- API server issues

Add timeouts or mock API calls for more reliable tests.

## Notes

- Tests use the `testthat` package (v2.0.0 or later recommended)
- Some tests modify environment variables - each test should clean up after itself
- Integration tests may create actual resources (projects, runs) - consider cleanup in teardown

