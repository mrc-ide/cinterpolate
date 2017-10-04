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
  res <- system3(R, c("CMD", "build", "testing"))
  expect_true(res$success)

  v <- read.dcf("testing/DESCRIPTION", "Version")[[1]]
  path <- sprintf("testing_%s.tar.gz", v)
  res <- system3(R, c("CMD", "check", "--no-manual", path))
  expect_true(res$success)

  file.remove(path)
  unlink("testing.Rcheck", recursive = TRUE)
})
