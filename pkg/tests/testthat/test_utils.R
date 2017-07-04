
context("Utilities")

test_that("exceptions",{
  expect_message(msgf("foo"))
  expect_warning(warnf("foo"))
  expect_error(stopf("foo"))
})