
logfile <- file.path(tempfile(fileext=".csv"))
e <- expression_logger$new(mean=mean(height), sd=sd(height))

out <- women %L>%
  start_log(e) %L>%
  within(height <- height * 2) %L>%
  within(height <- height * 3) %L>%
  dump_log(file=logfile)

read.csv(logfile)


