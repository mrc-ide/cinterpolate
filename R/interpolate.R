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
  ny <- if (is_matrix) ncol(y) else 1L
  if (!is.character(type) || length(type) != 1L || is.na(type)) {
    stop("Expected 'type' to be a scalar character")
  }
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
