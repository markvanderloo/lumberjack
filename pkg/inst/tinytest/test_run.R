
e <- run("runs/single_logger.R")
expect_true(file.exists(e$logfile))
expect_silent(read.csv(e$logfile))

# NOTE, this also tests whether 'label' gets prepended properly
e <- run("runs/multiple_loggers.R")
simple_ok <- expect_true(file.exists("runs/women_simple.csv"))
expect_silent(read.csv("runs/women_simple.csv"))
if (simple_ok) unlink("runs/women_simple.csv")


cellwise_ok <- expect_true(file.exists("runs/women_cellwise.csv"))
expect_silent(read.csv("runs/women_cellwise.csv"))
if (cellwise_ok) unlink("runs/women_cellwise.csv")

e <- run("runs/dump_test.R")
expect_true(file.exists("runs/women_simple.csv"))
expect_false(file.exists("runs/women_cellwise.csv"))


