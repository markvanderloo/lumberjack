
e <- run("runs/single_logger.R")
expect_silent(lg <- read.csv(e$logfile))
expect_equal(nrow(lg), 3)


e <- run("runs/multiple_loggers.R")
simple_ok <- expect_silent(lg2 <- read.csv("runs/simple_log.csv"))
cellwise_ok <- expect_silent(lg2 <- read.csv("runs/cellwise.csv"))

if (simple_ok) unlink("runs/simple_log.csv")
if (cellwise_ok) unlink("runs/simple.csv")


