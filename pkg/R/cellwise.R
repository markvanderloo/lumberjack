# Implementation of the cellwise logger.


#' The cellwise logger.
#' 
#' The cellwise logger registres the row, column, old, and new value
#' of cells that changed, along with a step number, timestamp, and the
#' expression used to alter a dataset. The log is initially written
#' to a file connection. Upon dump, this file is closed and copied
#' to a local file.
#' 
#' @section Creating a logger:
#' \code{cellwise$new(verbose=TRUE, file=tempfile())}
#' \tabular{ll}{
#' \code{verbose}\tab toggle verbosity\cr
#' \code{file}\tab temporary file to write logs info to\cr
#' }
#' 
#' 
#' @section Dump options:
#' \code{$dump(file="cellwise.csv")}
#' \tabular{ll}{
#'   \code{file}\tab file to write final output to.
#' }
#' 
#' @section Details:
#' At initialization, the cellwise logger opens a connection to a temporary
#' file. All logging info is written to that connection. When
#' \code{\link{dump_log}} is called, the temporary file is closed, copied to the
#' output file, and reopened for writing. The connection is closed automatically
#' when the logger is destroyed, for example when calling 
#' \code{dump_log(stop=TRUE)}, or \code{stop_log()} in the lumberjack pipeline.
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @example ../examples/cellwise.R
#' 
#' @family loggers
#' @export
cellwise <- R6Class("cellwise"
  , public = list(
    tmpfile   = NULL
    , con     = NULL
    , n       = NULL 
    , verbose = NULL
    , key     = NULL
  , initialize = function(key, verbose=TRUE, file=tempfile()){
      if(missing(key)) stop("you must provide a key")
      self$tmpfile = file
      self$con = file(self$tmpfile, open="wt")
      self$n <- 0
      self$verbose <- verbose
      self$key <- key
      write.csv(
        data.frame(
          step=integer(0)
          , time=character(0)
          , expression=character(0)
          , row=character(0)
          , col=character(0)
          , old=character(0)
          , new=character(0)
        )
        , file=self$con
        , row.names=FALSE
      )
  }
  , add = function(meta, input, output){
      self$n <- self$n+1
      # timestamp
      ts <- strftime(Sys.time(),usetz=TRUE)
      d <- celldiff(input, output)
      if (is.null(d)) return()
      d$step <- self$n
      d$time <- ts
      d$expression <- meta$src
      d <- d[c(5:7,1:4)]
      write.table(d,file = self$con
            , row.names=FALSE, col.names=FALSE, sep=",")
  }
  , dump = function(file="cellwise.csv"){
      self$con <- iclose(self$con) 
      file.copy(from=self$tmpfile, to=file)
      if (self$verbose){
        msgf("Dumped a log at %s",file)
      }
      self$con <- file(self$tmpfile, open="wt")
  }
  , show = function(){
    state <- if ( is_open(self$con) ) "open" else "closed"
    cat("\ncellwise logger with %s connection", state)
  }
  , finalize = function(){
    if (is_open(self$con)) close(self$con)
  }
  )
)

# A reasonable connection closer
iclose <- function(con,...){
  close(con,...)
  invisible(NULL)
}

# A reasonable connection checker that really only works
# if the reasonable closer is used to overwrite the connection
# object. isOpen crashes on closed (hence destroyed) connections :-(.
is_open <- function(con,...){
  !is.null(con) && isOpen(con)
}

# a decent sort
isort <- function(x, by,...){
  x[do.call("order",x[by]),,drop=FALSE]
}

cc <- function(x,y) c(as.character(x), as.character(y))

mpaste <- function(...) paste(...,sep=".@.")

# send x to long format, values as character.
keyframe <- function(x, key){
  col_x <- names(x)[names(x) != key]
  kf <- expand.grid(key=x[,key],variable=col_x)
  kf$value <- Reduce(cc, x[col_x])
  isort(kf, c("key","variable"))
}

celldiff <- function(x,y,key){
  kx <- keyframe(x,key)
  ky <- keyframe(y,key)
  kxy <- merge(kx,ky,by=c("key","variable"), all=TRUE)
  na_x <- is.na(kxy$value.x)
  na_y <- is.na(kxy$value.y)
  d_xy <- (na_x & !na_y) | (!na_x & na_y) | 
      (!na_x & !na_y & kxy$value.x != kxy$value.y)
  kxy[d_xy,]
}







