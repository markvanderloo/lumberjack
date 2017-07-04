## lumberjack -- the pipe operator that logs
[![Build Status](https://travis-ci.org/markvanderloo/lumberjack.svg?branch=master)](https://travis-ci.org/markvanderloo/lumberjack)
[![Coverage Status](https://coveralls.io/repos/markvanderloo/lumberjack/badge.svg?branch=master&service=github)](https://coveralls.io/github/markvanderloo/lumberjack?branch=master)
[![CRAN](http://www.r-pkg.org/badges/version/lumberjack)](http://cran.r-project.org/package=lumberjack/)
[![Downloads](http://cranlogs.r-pkg.org/badges/lumberjack)](http://www.r-pkg.org/pkg/lumberjack) 



A function composition operator ('pipe') and extensible framework
that allows for easy logging of changes in data.

<a href="https://asciinema.org/a/5wbyzkgvrif4884n41gmstjg0"><img src="https://asciinema.org/a/5wbyzkgvrif4884n41gmstjg0.png" width=400></a>

### Installation


```
install.packages('lumberjack')
```

### Usage

To log changes in data, you need to attach a logger, and use the `lumberjack` operator `%>>%`.

```r
> out <- iris %>>%     # feed iris
+   start_log() %>>%   # tag for logging
+   identity() %>>%    # do nothing
+   head() %>>%        # cut of the head
+   dump_log()         # dump log
Dumped a log at /home/mark/projects/lumberjack/simple_log.csv
> 
> # the processed data is here:
> 
> out[1:3]
  Sepal.Length Sepal.Width Petal.Length
1          5.1         3.5          1.4
2          4.9         3.0          1.4
3          4.7         3.2          1.3
4          4.6         3.1          1.5
5          5.0         3.6          1.4
6          5.4         3.9          1.7
> 
> # the log is here:
> read.csv("simple_log.csv")
  step                time expression changed
1    1 2017-06-01 12:08:03 identity()   FALSE
2    2 2017-06-01 12:08:03     head()    TRUE
```

The `start_log` function takes as its argument a logging object, which is a
[Reference](http://adv-r.had.co.nz/R5.html) or a
[R6](https://cran.r-project.org/web/packages/R6/vignettes/Introduction.html)
class implementing two methods: `$add` and `$dump`.  Other than that it is
completely flexible and users can write their own loggers as desired.

### Materials

- A [blogpost](http://www.markvanderloo.eu/yaRb/2017/06/23/track-changes-in-data-with-the-lumberjack/) introducing the package
- Get started with the [introductory vignette](https://cran.r-project.org/web/packages/lumberjack/vignettes/intro.html)
- Write your own loggers: [extending lumberjack](https://cran.r-project.org/web/packages/lumberjack/vignettes/extending.html)
