context("testing")

test_that("basics", {
  set.seed(1)

  x <- as.numeric(0:5)
  y <- sin(x)
  xout <- seq(0, 5, length.out = 101)

  yout_c <- .Call("test", x, y, xout, "constant")
  yout_l <- .Call("test", x, y, xout, "linear")
  yout_s <- .Call("test", x, y, xout, "spline")

  expect_equal(yout_c, approx(x, y, xout, "constant")$y)
  expect_equal(yout_l, approx(x, y, xout, "linear")$y)
  expect_equal(yout_s, spline(x, y, xout = xout, method = "natural")$y)

  y2 <- cbind(y, y * 2, deparse.level = 0)
  yout2_c <- .Call("test", x, y2, xout, "constant")
  yout2_l <- .Call("test", x, y2, xout, "linear")
  yout2_s <- .Call("test", x, y2, xout, "spline")

  expect_equal(yout2_c, rbind(yout_c, yout_c * 2, deparse.level = 0))
  expect_equal(yout2_l, rbind(yout_l, yout_l * 2, deparse.level = 0))
  expect_equal(yout2_s, rbind(yout_s, yout_s * 2, deparse.level = 0))
})
