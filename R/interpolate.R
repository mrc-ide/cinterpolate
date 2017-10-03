##' Create an interpolation function
##' @title Create an interpolation function
##'
##' @param x Independent variable
##'
##' @param y Dependent variable
##'
##' @param type Character string indicating the interpolation type
##'   ("constant", "linear" or "spline").
##'
##' @export
##' @useDynLib cinterpolate, .registration = TRUE
interpolation_function <- function(x, y, type) {
  as_numeric <- function(a) {
    if (storage.mode(a) == "integer") {
      storage.mode(a) <- "numeric"
    }
    a
  }

  is_matrix <- is.matrix(y)
  if (is_matrix) {
    ny <- ncol(y)
  } else {
    y <- matrix(y, ncol = 1)
    ny <- 1L
  }
  stopifnot(is.character(type), length(type) == 1L)
  ptr <- .Call(Cinterpolate_prepare, as_numeric(x), as_numeric(y), type)
  ret <- function(x) {
    y <- .Call(Cinterpolate_eval, ptr, as_numeric(x))
    if (is_matrix) {
      matrix(y, ncol = ny, byrow = TRUE)
    } else {
      y
    }
  }
  attr(ret, "info") <- function() .Call(Cinterpolate_data_info, ptr)
  ret
}
