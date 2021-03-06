## ---
## title: "Using `cinterpolate`"
## author: "Rich FitzJohn"
## date: "`r Sys.Date()`"
## output: rmarkdown::html_vignette
## vignette: >
##   %\VignetteIndexEntry{Using cinterpolate}
##   %\VignetteEngine{knitr::rmarkdown}
##   %\VignetteEncoding{UTF-8}
## ---

##+ echo = FALSE, results = "hide"
knitr::opts_chunk$set(
  error = FALSE,
  fig.width = 7,
  fig.height = 5)
set.seed(1)

## This package provides a minimal set of interpolation methods
## (piecewise constant, linear and spline) designed to be compatible
## with R's `interpolate` function but callable from C.  It will only
## be of interest to people writing C or C++ packages.

## The package is designed to be used with R's `LinkingTo:` support
## and is header only.  This is a somewhat awkward situation for C
## (rather than C++).  The approach is the same as taken by
## [`ring`](https://cran.r-project.org/package=ring).

## ## Package preparation

## * In your `DESCRIPTION`, add a line `LinkingTo: cinterpolate`.  You
##   also need to add `cinterpolate` to `Imports` and ensure that the
##   package is loaded before use, as it uses R's `R_GetCCallable`
##   interface to call the actual interpolation functions.
##
## * In your `src/` directory, add a file `cinterpolate.c` containing
##   just the line `#include <cinterpolate/cinterpolate.c>`.
##
## * Anywhere in your C (or C++) code you want to use the
##   interpolation code buffer, include the line `#include
##   <cinterpolate/cinterpolate.h>` to include the prototypes and use
##   the interface as described below.
##
## (I am not sure what the best practice way of doing this with a
## standalone shared library compiled with `R CMD SHLIB` is though;
## probably best to make a package.)

## ## The API

## There are only three functions in the `cinterpolate` API; one to
## build the object (`cinterpolate_alloc`), one for carrying out
## interpolation (`cinterpolate_eval`) and one for freeing the object
## after calculations have been run (`cinterpolate_free`).  If you
## allocate a cinterpolate object then you are responsible for freeing
## it (even on error elsewhere in code).  Not doing this will cause
## leaks.

##+ echo = FALSE, results = "asis"
writeLines(c(
  "```c",
  readLines(system.file("include/cinterpolate/cinterpolate.h",
                        package = "cinterpolate")),
  "```"))

## A complete example of use is included in the package as `system.file("example", package = "cinterpolate")`.

## The `DESCRIPTION` looks like

##+ echo = FALSE, results = "asis"
writeLines(c(
  "```plain",
  readLines(system.file("example/DESCRIPTION",
                        package = "cinterpolate")),
  "```"))

## Note the use of `LinkingTo:` and `Imports:` here.
##
## The `NAMESPACE` file ensures that the package's shared library is
## loaded (`useDynLib(example)`) and that `cinterpolate`'s functions
## will be available by importing the package `import(cinterpolate)`
## (`importFrom(cinterpolate, interpolate_function)` would also be
## fine).
##+ echo = FALSE, results = "asis"
writeLines(c(
  "```plain",
  readLines(system.file("example/NAMESPACE",
                        package = "cinterpolate")),
  "```"))

## The actual usage from C looks like:
##+ echo = FALSE, results = "asis"
writeLines(c(
  "```c",
  readLines(system.file("example/src/testing.c",
                        package = "cinterpolate")),
  "```"))

## * Because this is the only use of cinterpolate in the package, we
##   can directly include `cinterpolate/cinterpolate.c`
##
## * The `interpolate_alloc` function is used with `auto_clean = true`
##   so there is no use of `interpolate_free` - because this
##   interpolator only needs to survive for this single C function
##   this method of cleanup is probably better
##
## * There is a single allocation of an interpolation object but
##   several calls to interpolate new values.
