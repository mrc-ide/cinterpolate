context("search")
## search returns the index of the first element that is smaller to it

test_that("binary search", {
  x <- 0:9 + 0.5

  ## off the edges
  expect_identical(test_interpolate_search(x, 0, 0), -1L)
  expect_identical(test_interpolate_search(x, 0, 10), 10L)
  expect_identical(test_interpolate_search(x, 5, 0), -1L)
  expect_identical(test_interpolate_search(x, 5, 10), 10L)
  expect_identical(test_interpolate_search(x, 9, 0), -1L)
  expect_identical(test_interpolate_search(x, 9, 10), 10L)
})


test_that("trivial search", {
  x <- 0.5
  test_interpolate_search(x, 0, 0)
  test_interpolate_search(x, 0, x)
  test_interpolate_search(x, 0, x - 1e-7)
  test_interpolate_search(x, 0, x + 1e-7)
})
