library(lumberjack)

## Logging switches
# switching on, switching off
expect_false( is.null(get_log(start_log(1:3))) )
expect_true(  is.null(get_log(stop_log(start_log(1:3)))) )


## Logging does not depend on functins keeping attributes
naughty_function <- function(x){
  attr(x, lumberjack:::LOGNAME) <- NULL
  x
}
d <- data.frame(x=1:3,y=letters[1:3])
out <- d %L>%
  start_log(simple$new(verbose=FALSE)) %L>%
  naughty_function()
expect_true(lumberjack:::has_log(out))

# exclude remove_log and dump_log from naughty functions
out <- 1:3 %L>%
  start_log(simple$new(verbose=FALSE)) %L>%
  {.*2} %L>% 
  dump_log(file=tempfile()) 
expect_true(is.null(attributes(out)))



