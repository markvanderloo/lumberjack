
logfile <- file.path(tempfile(fileext=".csv"))
e <- expression_logger$new(mean=mean(height), sd=sd(height),file=logfile)

out <- women %L>%
  start_log(e) %L>%
  {.$height <- .$height * 2; .} %L>%
  {.$height <- .$height * 3; .} %L>%
  dump_log(stop=TRUE)

read.csv(logfile)