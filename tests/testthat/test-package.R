context("package")

test_that("package check", {
  skip_on_cran()
  Sys.setenv("R_TESTS" = "")

  ## This one needs a local installation of cinterpolate to work for
  ## the LinkingTo: interface to work (skip_if_not_installed does not
  ## work for this as despite the name it doesn't check installation,
  ## it checks if it can be loaded).
  if (!("cinterpolate" %in% .packages(TRUE))) {
    skip("cinterpolate not installed")
  }

  R <- file.path(R.home(), "bin", "R")
  example <- system.file("example", package = "cinterpolate")
  include <- system.file("include", package = "cinterpolate")

  tmp <- tempfile()
  dir.create(tmp, FALSE, TRUE)
  on.exit(unlink(tmp, recursive = TRUE))

  path <- file.path(tmp, "example")
  file.copy(example, tmp, recursive = TRUE)
  writeLines(sprintf("PKG_CPPFLAGS = %s", include),
             file.path(path, "src", "Makevars"))

  v <- read.dcf(file.path(example, "DESCRIPTION"), "Version")[[1]]
  path_pkg <- sprintf("example_%s.tar.gz", v)

  with_wd(tmp, {
    res <- system3(R, c("CMD", "build", "example"))
    expect_true(res$success)
    res <- system3(R, c("CMD", "check", "--no-manual", path_pkg))
    expect_true(res$success)
  })
})
