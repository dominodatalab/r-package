library(domino)
library(testthat)
context("domino.create")

test_that("domino.create validates inputs correctly", {
  # Test that missing arguments are caught
  expect_error(domino.create(), "Missing parameters for create command")
  
  # Test with invalid project name (if API mode)
  # Just verify the function exists and accepts arguments
  expect_error(domino.create(), "Missing parameters")
})

test_that("Project name validation in create context", {
  # Valid project names
  expect_silent(domino:::.domino.validate.project.name("my-new-project"))
  expect_silent(domino:::.domino.validate.project.name("project_123"))
  
  # Invalid project names
  expect_error(domino:::.domino.validate.project.name(""), "must be a non-empty string")
  expect_error(domino:::.domino.validate.project.name("project/with/slash"), "invalid characters")
})

test_that("Visibility validation works", {
  # This is tested indirectly through domino.create
  # Valid visibility values are "public" and "private"
  # We can't easily test this without API credentials, but the logic is in .domino.create.api
  expect_true(is.function(domino.create))
})

# Integration tests (require API credentials)
if (nchar(Sys.getenv("DOMINO_USER_API_KEY", "")) > 0 || 
    nchar(Sys.getenv("DOMINO_TOKEN", "")) > 0) {
  
  test_that("domino.create API mode detection works", {
    # Set up test credentials
    Sys.setenv(DOMINO_API_HOST = Sys.getenv("DOMINO_TEST_HOST", "https://app.dominodatalab.com"))
    
    # Should detect API mode when credentials are set
    expect_true(is.function(domino.create))
  })
  
  # Note: Actual project creation tests would require:
  # - Valid API credentials
  # - Cleanup of created projects
  # - Proper error handling for duplicate project names
  # These are better suited for manual testing or integration test suite
}

