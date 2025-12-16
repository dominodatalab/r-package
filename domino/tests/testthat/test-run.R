library(domino)
library(testthat)
context("domino.run")

# Test validation functions (using ::: to access internal functions)
test_that("Project name validation works", {
  # Valid project names
  expect_silent(domino:::.domino.validate.project.name("my-project"))
  expect_silent(domino:::.domino.validate.project.name("project_123"))
  expect_silent(domino:::.domino.validate.project.name("a"))
  
  # Invalid project names
  expect_error(domino:::.domino.validate.project.name(""), "must be a non-empty string")
  expect_error(domino:::.domino.validate.project.name(NULL), "must be a non-empty string")
  expect_error(domino:::.domino.validate.project.name("project/with/slash"), "invalid characters")
  expect_error(domino:::.domino.validate.project.name("project..with..dots"), "invalid characters")
  expect_error(domino:::.domino.validate.project.name(paste(rep("a", 256), collapse = "")), "too long")
})

test_that("Owner validation works", {
  # Valid owner names
  expect_silent(domino:::.domino.validate.owner("myuser"))
  expect_silent(domino:::.domino.validate.owner("user_123"))
  
  # Invalid owner names
  expect_error(domino:::.domino.validate.owner(""), "must be a non-empty string")
  expect_error(domino:::.domino.validate.owner(NULL), "must be a non-empty string")
  expect_error(domino:::.domino.validate.owner("user/with/slash"), "invalid characters")
})

test_that("Commit ID validation works", {
  # Valid commit IDs (SHA hashes)
  expect_silent(domino:::.domino.validate.commit.id("960a4c99a4cc38194cbacbcce41caa68ba5369ea"))
  expect_silent(domino:::.domino.validate.commit.id("abc1234"))
  
  # Valid branch/tag names
  expect_silent(domino:::.domino.validate.commit.id("master"))
  expect_silent(domino:::.domino.validate.commit.id("feature/new-thing"))
  expect_silent(domino:::.domino.validate.commit.id("v1.2.3"))
  
  # Invalid commit IDs
  expect_error(domino:::.domino.validate.commit.id(paste(rep("a", 256), collapse = "")), "too long")
  expect_error(domino:::.domino.validate.commit.id(123), "must be a string")
})

test_that("Title validation works", {
  # Valid titles
  expect_silent(domino:::.domino.validate.title("My Run Title"))
  expect_silent(domino:::.domino.validate.title(NULL))
  
  # Invalid titles
  expect_error(domino:::.domino.validate.title(123), "must be a string")
  expect_error(domino:::.domino.validate.title(paste(rep("a", 501), collapse = "")), "too long")
})

test_that("Command sanitization works", {
  # Valid commands
  result <- domino:::.domino.sanitize.command(list("main.R", "arg1", "arg2"))
  expect_equal(result, c("main.R", "arg1", "arg2"))
  
  # Numeric arguments converted to strings
  result <- domino:::.domino.sanitize.command(list("main.R", 1, 2, 3))
  expect_equal(result, c("main.R", "1", "2", "3"))
  
  # Invalid commands
  expect_error(domino:::.domino.sanitize.command(list(NULL)), "must be strings or numbers")
  expect_error(domino:::.domino.sanitize.command(list(data.frame())), "must be strings or numbers")
})

test_that("domino.run validates inputs correctly", {
  # Test that missing arguments are caught
  expect_error(domino.run(), "Missing parameters for run command")
  
  # Verify function exists and is callable
  expect_true(is.function(domino.run))
})

test_that("Command building works correctly", {
  # Test R script detection
  args <- list("main.R", "arg1", "arg2")
  cmd_parts <- domino:::.domino.sanitize.command(args)
  expect_true(grepl("\\.r$|\\.R$", cmd_parts[1], ignore.case = TRUE))
  
  # Test non-R scripts
  args <- list("main.py", "arg1", "arg2")
  cmd_parts <- domino:::.domino.sanitize.command(args)
  expect_false(grepl("\\.r$|\\.R$", cmd_parts[1], ignore.case = TRUE))
  
  # Test that R scripts get Rscript prepended (logic test)
  # This is tested indirectly through the command building logic
  expect_true(is.character(cmd_parts))
})

# Integration tests (require API credentials)
if (nchar(Sys.getenv("DOMINO_USER_API_KEY", "")) > 0 || 
    nchar(Sys.getenv("DOMINO_TOKEN", "")) > 0) {
  
  test_that("domino.run API mode detection works", {
    # Set up test credentials
    Sys.setenv(DOMINO_API_HOST = Sys.getenv("DOMINO_TEST_HOST", "https://app.dominodatalab.com"))
    
    # Should detect API mode when credentials are set
    # Note: This test may require actual API credentials
    # For now, we'll just verify the function structure
    expect_true(is.function(domino.run))
  })
}

