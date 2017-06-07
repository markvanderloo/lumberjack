
logfile <- tempfile(fileext=".csv")

# convert height from inch to cm and log changes.
out <- women %>>%
  start_log(log=cellwise$new()) %>>%
  {.$height <- .$height*2.54; .} %>>%
  dump_log(file=logfile)

read.csv(logfile) %>>% head()

