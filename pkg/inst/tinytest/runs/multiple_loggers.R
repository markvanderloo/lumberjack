
library(lumberjack)
women$id <- 1:15

lf1 <- tempfile()
lf2 <- tempfile()


start_log(women, simple$new(verbose=FALSE))
start_log(women, cellwise$new(key='id',verbose=FALSE))

women[1,1] <- 2*women[1,1]
women$ratio <- women$height/women$weight

dump_log(women, "simple", file=lf1)
dump_log(women, "cellwise", file=lf2)

