##' Create an interpolation function, using the same implementation as
##' would be available from C code.  This will give very similar
##' answers to R's \code{\link{splinefun}} function.  This is not the
##' primary intended use of the package, which is mostly designed for
##' use from C/C++.  This function primarily exists for testing this
##' package, and for exploring the interface without writing C code.
##'
##' @title Create an interpolation function
##'
##' @param x Independent variable
##'
##' @param y Dependent variable
##'
##' @param type Character string indicating the interpolation type
##'   ("constant", "linear" or "spline").
##'
##' @param scalar Return a function that will compute only a single
##'   \code{x} input at a time.  This is more similar to the C
##'   interface and is equivalent to dropping the first dimension of
##'   the output.
##'
##' @param fail_on_extrapolate Logical, indicating if extrapolation
##'   should cause an failure (rather than an NA value)
##'
##' @return A function that can be used to interpolate the function(s)
##'   defined by \code{x} and \code{y} to new values of {x}.
##'
##' @export
##' @useDynLib cinterpolate, .registration = TRUE
##'
##' @examples
##'
##' # Some data to interpolate
##' x <- seq(0, 8, length.out = 20)
##' y <- sin(x)
##' xx <- seq(min(x), max(x), length.out = 500)
##'
##' # Spline interpolation
##' f <- cinterpolate::interpolation_function(x, y, "spline")
##' plot(f(xx) ~ xx, type = "l")
##' lines(sin(xx) ~ xx, col = "grey", lty = 2)
##' points(y ~ x, col = "red", pch = 19, cex = 0.5)
##'
##' # Linear interpolation
##' f <- cinterpolate::interpolation_function(x, y, "linear")
##' plot(f(xx) ~ xx, type = "l")
##' lines(sin(xx) ~ xx, col = "grey", lty = 2)
##' points(y ~ x, col = "red", pch = 19, cex = 0.5)
##'
##' # Piecewise constant interpolation
##' f <- cinterpolate::interpolation_function(x, y, "constant")
##' plot(f(xx) ~ xx, type = "s")
##' lines(sin(xx) ~ xx, col = "grey", lty = 2)
##' points(y ~ x, col = "red", pch = 19, cex = 0.5)
##'
##' # Multiple series can be interpolated at once by providing a
##' # matrix for 'y'.  Each series is interpolated independently but
##' # simultaneously.
##' y <- cbind(sin(x), cos(x))
##' f <- cinterpolate::interpolation_function(x, y, "spline")
##' matplot(xx, f(xx), type = "l", lty = 1)
interpolation_function <- function(x, y, type, scalar = FALSE,
                                   fail_on_extrapolate = FALSE) {
  if (!is.character(type) || length(type) != 1L || is.na(type)) {
    stop("Expected 'type' to be a scalar character")
  }
  dim <- dim(y)
  if (is.null(dim)) {
    is_array <- FALSE
  } else {
    is_array <- TRUE
    if (length(dim) > 2) {
      y <- matrix(y, length(x))
    }
    dim <- dim[-1L]
  }
  is_array <- !is.null(dim)
  ptr <- .Call(Cinterpolate_prepare, as_numeric(x), as_numeric(y), type,
               fail_on_extrapolate)

  if (scalar) {
    ret <- function(x) {
      if (length(x) != 1L) {
        stop("Expected a single 'x' value")
      }
      y <- .Call(Cinterpolate_eval, ptr, as_numeric(x))
      if (is_array) {
        dim(y) <- dim
      }
      y
    }
  } else {
    ret <- function(x) {
      y <- .Call(Cinterpolate_eval, ptr, as_numeric(x))
      if (is_array) {
        dim(y) <- c(length(x), dim)
      }
      y
    }
  }
  attr(ret, "info") <- function() .Call(Cinterpolate_data_info, ptr)
  ret
}


as_numeric <- function(a) {
  if (storage.mode(a) == "integer") {
    storage.mode(a) <- "numeric"
  }
  a
}
