
library(lumberjack)

logfile <- tempfile()
logger <- simple$new(verbose=FALSE)
start_log(women, logger)

women[1,1] <- 2*women[1,1]
women$ratio <- women$height/women$weight

dump_log(file=logfile)


