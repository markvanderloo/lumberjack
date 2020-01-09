library(lumberjack)
## expression logger


tmpfile <- tempfile()
logger <- expression_logger$new(
    mh      = mean(height)
  , mw      = mean(weight)
  , verbose = FALSE
)

women %L>%
  start_log(logger) %L>%
  identity() %L>%
  {.$height <- 2*.$height; .} %L>%
  dump_log(file=tmpfile)
lg <- read.csv(tmpfile)
expect_equal(lg$mh[1], mean(women$height))
expect_equal(lg$mw[1], mean(women$weight))
expect_equal(lg$mh[2], mean(2*women$height))
expect_equal(lg$mw[2], mean(women$weight))

expect_true("label" %in% ls(logger))


