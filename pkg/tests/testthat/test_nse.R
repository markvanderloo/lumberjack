
library(testthat)

context("NSE helper functions")
test_that("symbol replacement works",{
  
  expect_identical(
    replace(expression(x + y)[[1]],quote(x),quote(z))
    , expression(z + y)[[1]])
  
  expect_identical(
    replace(expression(x + y*y)[[1]],quote(y),quote(z))
    , expression(x + z*z)[[1]])

  expect_identical(
    replace(expression(x + f(y*y))[[1]],quote(y),quote(z))
    , expression(x + f(z*z))[[1]])
})

context("The pipe")

test_that("the basic pipe function",{
  expect_identical(pipe(3, expression({ 2*. })[[1]]), 6)
  expect_identical(pipe(3, expression(( 2*. ))[[1]]), 6)
  expect_identical(pipe(3, expression(sum())[[1]]), 3)
})

test_that("The actual pipe function",{
  expect_identical(1:3 %>>% mean(), mean(1:3))
  g <- 1:3
  expect_identical(g %>>% mean(), mean(1:3))
  
})






