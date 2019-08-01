
e <- run("runs/single_logger.R")
expect_true(file.exists(e$logfile))
expect_silent(read.csv(e$logfile))


e <- run("runs/multiple_loggers.R")
simple_ok <- expect_true(file.exists("runs/simple_log.csv"))
expect_silent(read.csv("runs/simple_log.csv"))
if (simple_ok) unlink("runs/simple_log.csv")


cellwise_ok <- expect_true(file.exists("runs/cellwise.csv"))
expect_silent(read.csv("runs/cellwise.csv"))
if (cellwise_ok) unlink("runs/cellwise.csv")

e <- run("runs/dump_test.R")
expect_true(file.exists("runs/simple_log.csv"))
expect_false(file.exists("runs/cellwise.csv"))


