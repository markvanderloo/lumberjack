library(lumberjack)
logfile <- tempfile()
## file should create women_logger, locally.
data(women)
start_log(women, logger=simple$new(verbose=FALSE))
women[1,1] <- 2*women[1,1]
women$ratio <- women$height/women$weight
dump_log(women, "simple", file=logfile)


