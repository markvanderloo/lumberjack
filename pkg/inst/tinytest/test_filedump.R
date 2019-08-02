library(lumberjack)
## filedump logging",{
logger <- filedump$new(verbose=FALSE)
i2 <- start_log(iris, logger=logger) 
i2 <- i2 %>>%  identity()    
i2 <- i2 %>>% {.$Sepal.Length <- .$Sepal.Length*2; .}  
i2 <- dump_log(i2, verbose=TRUE) 
expect_equal(length(dir(logger$dir)), 3)
# this test crashes covr but it does pass.
#expect_equal(length(logger$logdata()) , 3)

