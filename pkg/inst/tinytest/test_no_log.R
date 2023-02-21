library(lumberjack)

# no_log doesn't keep $logdata().
logger <- no_log$new()
iris %>>% start_log(logger) %>>% head() %>>% stop_log(dump=FALSE)
expect_equal(logger$logdata(), data.frame())

# But does write an empty logfile if asked.
logfile <- tempfile()
i2 <- start_log(iris, no_log$new(verbose=FALSE)) 
i2 <- i2 %>>%  identity()    
i2 <- i2 %>>% head()     
i2 <- dump_log(i2, file=logfile, stop=TRUE) 
expect_true(file.exists(logfile))


