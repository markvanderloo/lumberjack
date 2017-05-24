

context("Logging switches")
test_that("switching on, switching off",{
  expect_false( is.null(get_log(start_log(1:3))) )
  expect_true(  is.null(get_log(stop_log(start_log(1:3)))) )
})

