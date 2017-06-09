logfile <- tempfile(fileext=".csv")

# convert height from inch to cm and log changes.
# we need to set a unique key.
women$sleutel <- 1:nrow(women)
out <- women %>>%
  start_log(log=cellwise$new(key="sleutel")) %>>%
  {.$height <- .$height*2.54; .} %>>%
  dump_log(file=logfile, stop=TRUE)

read.csv(logfile) %>>% head()

