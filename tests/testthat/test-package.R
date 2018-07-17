context("package")

test_that("package check", {
  skip_on_cran()
  ## This one needs a local installation of cinterpolate to work for
  ## the LinkingTo: interface to work (skip_if_not_installed does not
  ## work for this as despite the name it doesn't check installation,
  ## it checks if it can be loaded).
  if (!("cinterpolate" %in% .packages(TRUE))) {
    skip("cinterpolate not installed")
  }
  Sys.setenv("R_TESTS" = "")

  R <- file.path(R.home(), "bin", "R")
  example <- system.file("example", package = "cinterpolate")
  res <- system3(R, c("CMD", "build", example))
  expect_true(res$success)

  v <- read.dcf(file.path(example, "DESCRIPTION"), "Version")[[1]]
  path <- sprintf("example_%s.tar.gz", v)
  res <- system3(R, c("CMD", "check", "--no-manual", path))
  expect_true(res$success)

  file.remove(path)
  unlink("example.Rcheck", recursive = TRUE)
})
