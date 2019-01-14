context("interpolation")

test_that("constant endpoints", {
  set.seed(1)
  x <- as.numeric(0:5)
  eps <- 1e-8

  expect_identical(approx(x, x, x, "constant")$y, x)
  expect_identical(approx(x, x, x + eps, "constant", rule = 2)$y, x)

  f <- interpolation_function(x, x, "constant")
  expect_identical(f(x), x)
  expect_identical(f(x + eps), x)
})

test_that("spline knots", {
  set.seed(1)
  x <- as.numeric(0:5)
  y <- runif(length(x))
  xout <- seq(min(x), max(x), length.out = 21)
  yout <- spline(x, y, xout = xout, method = "natural")$y

  y2 <- y * 2
  y3 <- cbind(y, y, deparse.level = 0)
  y4 <- cbind(y, y2, deparse.level = 0)

  ## Basic calculations:
  f1 <- interpolation_function(x, y, "spline")
  f2 <- interpolation_function(x, y2, "spline")
  f3 <- interpolation_function(x, y3, "spline")
  f4 <- interpolation_function(x, y4, "spline")

  expect_equal(f1(xout), yout)
  expect_equal(f2(xout), yout * 2)
  expect_equal(f3(xout), cbind(yout, yout, deparse.level = 0))
  expect_equal(f4(xout), cbind(yout, yout * 2, deparse.level = 0))

  i1 <- attr(f1, "info")()
  i2 <- attr(f2, "info")()
  i3 <- attr(f3, "info")()
  i4 <- attr(f4, "info")()
})

test_that("interpolation", {
  set.seed(1)
  x <- as.numeric(0:5)
  y <- runif(length(x))
  ## This set of points here has the advantage that it:
  ##   a. is out of order so excercises the search function
  ##   b. includes all original time points
  xout <- sample(seq(0, 5, length.out = 101))
  ## Overshoot:
  xout_over <- c(xout, max(x) + 0.5)
  ## Undershoot
  xout_under <- c(xout, min(x) - 0.5)

  test <- function(x, y, xout, type) {
    interpolation_function(x, y, type)(xout)
  }

  rapprox <- list(
    constant = function(x, y, xout) approx(x, y, xout, "constant"),
    linear = function(x, y, xout) approx(x, y, xout, "linear"),
    spline = function(x, y, xout) spline(x, y, xout = xout, method = "natural"))

  for (type in names(rapprox)) {
    ## We're all good except that the constant interpolation is not
    ## quite correct in the case of identical time matches.
    res_c <- test(x, y, xout, type)
    res_r <- rapprox[[type]](x, y, xout)$y

    expect_equal(res_c, res_r, tolerance = 1e-12)

    res_c <- test(x, cbind(y, deparse.level = 0), xout, type)
    expect_equal(dim(res_c), c(length(xout), 1))
    expect_equal(drop(res_c), res_r, tolerance = 1e-12)

    ## This is where we get messy.
    y2 <- cbind(y, y, deparse.level = 0)
    res_c2 <- test(x, y2, xout, type)
    expect_equal(dim(res_c2), c(length(xout), 2))
    expect_equal(res_c2[, 1], res_r, tolerance = 1e-12)
    expect_equal(res_c2[, 2], res_r, tolerance = 1e-12)

    y3 <- cbind(y, y * 2, deparse.level = 0)
    res_c3 <- test(x, y3, xout, type)
    expect_equal(dim(res_c2), c(length(xout), 2))
    expect_equal(res_c3[, 1], res_r, tolerance = 1e-12)
    expect_equal(res_c3[, 2], res_r * 2, tolerance = 1e-12)

    res_c4 <- test(x, y3, xout_over, type)
    i <- length(xout_over)
    if (type == "constant") {
      expect_equal(res_c4[i, ], y3[nrow(y3),])
    } else {
      expect_equal(res_c4[i, ], rep(NA_real_, ncol(y3)))
    }
    res_c5 <- test(x, y3, xout_under, type)
    i <- length(xout_under)
    expect_equal(res_c5[i, ], rep(NA_real_, ncol(y3)))

    res_c6 <- test(x, y3, xout_over[i], type)
    if (type == "constant") {
      expect_equal(drop(res_c6), y3[nrow(y3),])
    } else {
      expect_equal(drop(res_c6), rep(NA_real_, ncol(y3)))
    }

    expect_equal(drop(test(x, y3, xout_under[i], type)),
                 rep(NA_real_, ncol(y3)))
  }
})

test_that("invalid type", {
  x <- y <- runif(5)
  expect_error(interpolation_function(x, y, "foo"),
               "Invalid interpolation type 'foo'")
  expect_error(interpolation_function(x, y, NA_character_),
               "Expected 'type' to be a scalar character")
  expect_error(interpolation_function(x, y, 1),
               "Expected 'type' to be a scalar character")
  expect_error(interpolation_function(x, y, letters),
               "Expected 'type' to be a scalar character")
})

test_that("coersion", {
  x <- as.integer(0:5)
  y <- as.integer(0:5)
  f <- interpolation_function(x, y, "linear")
  info <- attr(f, "info")()
  expect_false(is.integer(info$x))
  expect_false(is.integer(info$y))
  xx <- seq(0, 5, length.out = 11)
  expect_identical(f(xx), xx)
})

test_that("invalid input", {
  expect_error(interpolation_function(1:4, 1:5, "linear"),
               "Expected 'y' to have total length of 4 (4 x 1)",
               fixed = TRUE)
})

test_that("survive serialisation without crash", {
  f <- interpolation_function(1:5, 1:5, "linear")
  g <- unserialize(serialize(f, NULL))
  expect_error(g(1), "interpolate_data already freed")
  environment(g)$ptr <- 1L
  expect_error(g(1), "Expected an external pointer")
})


test_that("matrix is returned", {
  x <- 0:10
  y <- cbind(sin(x), cos(x))
  f <- cinterpolate::interpolation_function(x, y, "spline")
  expect_identical(f(x), y)
})


test_that("array", {
  tp <- c(0, 1, 2)
  zp <- array(c(c(0, 1, 0),
                c(0, 2, 0),
                c(0, 3, 0),
                c(0, 4, 0)), c(length(tp), 2, 2))
  f <- cinterpolate::interpolation_function(tp, zp, "constant")
  expect_identical(f(tp), zp)
})
