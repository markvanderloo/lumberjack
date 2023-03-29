
logfile <- tempfile(fileext=".csv")
out <- women %L>%
  start_log(log=no_log$new(verbose=FALSE)) %L>%
  identity() %L>%
  head() %L>% 
  dump_log(file=logfile, stop=TRUE)

cat(readLines(logfile),"\n") # Empty file

