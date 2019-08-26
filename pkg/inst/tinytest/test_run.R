# without explicit log dumping
expect_silent(e <- run_file("runs/auto_dump.R"))
expect_true(file.exists(e$logfile)) 


# with explicit log dumping
e <- run_file("runs/single_logger.R", auto_dump=FALSE)
expect_true(file.exists(e$logfile))
expect_silent(read.csv(e$logfile))

# NOTE, this also tests whether 'label' gets prepended properly
e <- run_file("runs/multiple_loggers.R")
expect_true(file.exists(e$lf1))
expect_true(file.exists(e$lf2))


e <- run_file("runs/dump_test.R", auto_dump=FALSE)
expect_true(file.exists(e$logfile))

