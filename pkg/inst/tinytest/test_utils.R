library(lumberjack)
## Utilities

expect_message(lumberjack:::msgf("foo"))
expect_warning(lumberjack:::warnf("foo"))
expect_error(lumberjack:::stopf("foo"))


