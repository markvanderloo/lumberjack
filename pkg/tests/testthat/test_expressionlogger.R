
context("expression logger")

test_that("expression logging",{
  tmpfile <- tempfile()
  logger <- expression_logger$new(
    mh = mean(height)
    ,mw = mean(weight)
    ,file=tmpfile
  )
  
  women %L>%
    start_log(logger) %L>%
    {.$height <- 2*.$height; .} %L>%
    dump_log()
  lg <- read.csv(tmpfile)
  expect_equal(lg$mh[1], mean(2*women$height))
  expect_equal(lg$mw[1], mean(women$weight))
})


