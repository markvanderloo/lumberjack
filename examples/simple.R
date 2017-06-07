
logfile <- tempfile(fileext=".csv")
out <- women %>>%
  start_log(log=simple$new(verbose=FALSE)) %>>%
  identity() %>>%
  head() %>>% 
  dump_log(file=logfile, stop=TRUE)


read.csv(logfile,stringsAsFactors=FALSE)

