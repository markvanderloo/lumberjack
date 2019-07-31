
library(lumberjack)
women$id <- 1:15


start_log(women, simple$new(verbose=FALSE))
start_log(women, cellwise$new(key='id',verbose=FALSE))

women[1,1] <- 2*women[1,1]
women$ratio <- women$height/women$weight

dump_log()

