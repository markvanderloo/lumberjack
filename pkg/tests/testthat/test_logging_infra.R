

context("Logging switches")
test_that("switching on, switching off",{
  expect_false( is.null(get_log(start_log(1:3))) )
  expect_true(  is.null(get_log(stop_log(start_log(1:3)))) )
})

test_that("Logging does not depend on functins keeping attributes",{
  naughty_function <- function(x){
    attr(x, lumberjack::LOGNAME) <- NULL
    x
  }
  d <- data.frame(x=1:3,y=letters[1:3])
  out <- d %L>%
    start_log(simple$new()) %L>%
    naughty_function()
  expect_true(has_log(out))
})