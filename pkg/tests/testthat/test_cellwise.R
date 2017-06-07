context("cellwise logger")

test_that("cellwise logging",{
  logfile <- tempfile()
   i2 <- start_log(iris, log=cellwise$new()) 
   i2 <- i2 %>>%  identity()    
   i2 <- i2 %>>% {.$Sepal.Length <- .$Sepal.Length*2; .}  
   i2 <- dump_log(i2, file=logfile, stop=TRUE) 
   expect_equal(nrow(read.csv(logfile)),nrow(iris))
})
