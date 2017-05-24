## lumberjack -- the pipe that smokes!



A function composition operator ('pipe') and extensible framework
that allows for easy logging of changes in data.

### Installation

Its under development, but you can clone this repo and build and install the
package from your local shell.

```
git clone https://github.com/markvanderloo/lumberjack.git
cd lumberjack
R CMD build pkg
R CMD INSTALL lumberjack_*.tar.gz
```

### Usage

To log changes in data, you need to attach a logger, and use the `lumberjack` operator `%>>%`.

```r
> i2 <- iris %>>%
+   start_log() %>>%  # set logger (configurable)
+   identity() %>>%   # do precisely nothing
+   dplyr::arrange(desc(Species)) %>>% # sort
+   dump_log(stop=TRUE) # dump log to csv and stop logging
Dumped a log at /home/mark/projects/lumberjack/simple_log.csv
> read.csv("simple_log.csv")
  step                time            fun changed
1    1 2017-05-24 08:30:47       identity   FALSE
2    2 2017-05-24 08:30:47 dplyr::arrange    TRUE
> 
```

The `start_log` function takes as its argument a logging object, which is a
[Reference](http://adv-r.had.co.nz/R5.html) or a
[R6](https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html)
class implementing two methods: `$add` and `$dump`.  Other than that it is
completely flexible and users can write their own loggers as desired.



