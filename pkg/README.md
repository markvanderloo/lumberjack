### A brief overview of `lumberjack`


#### Add logging capabilities to existing analyses scripts

Start tracking changes by adding two lines of code to an existing script.

```
# contents of 'script.R'

start_log(mydata, logger=simple$new())

# Existing data analyses code here...

dump_log(file="mylog.csv")
```
Next, run the script using `lumberjack::run()`, and read the logging info.

```
library(lumberjack)
run("script.R")

read.csv("mylog.csv")
```


#### Interactive logging with the lumberjack not-a-pipe operator.

```
out <- mydata %L>%
  start_log(logger = simple$new()) %L>%
  transform(z = 2*sqrt(x)) %L>%
  dump_log(file="mylog.csv")
read.csv("mylog.csv")
```

#### Loggers included with lumberjack

|logger              |description                                   |
|--------------------|----------------------------------------------|
|`simple`            | Record whether data has changed or not       |
|`cellwise`          | Record every change in every cell            |
|`expression_logger` | Record the value of user-defined expressions |


#### Extend with your own loggers

A logger is a _reference object_ (either R6 or Reference Class) with 
the following _mandatory_ elements.

- `add(meta, input, output)` A method recording differences between in- and output.
- `dump(...)` A method dumping logging info.
- `label`, A slot for setting a label.

There is also an _optional_ element:

- `stop(...)` A method that will be called before removing a logger.


#### More information

```
install.packages("lumberjack")
library(lumberjack)
vignette("using_lumberjack", package="lumberjack")
```

