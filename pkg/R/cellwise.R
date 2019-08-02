# Implementation of the cellwise logger.


#' The cellwise logger.
#' 
#' The cellwise logger registres the row, column, old, and new value
#' of cells that changed, along with a step number, timestamp, and the
#' expression used to alter a dataset. 
#' 
#' @section Creating a logger:
#' \code{cellwise$new(verbose=TRUE, file=tempfile()}
#' \tabular{ll}{
#' \code{verbose}\tab toggle verbosity\cr
#'  \code{key}\tab \code{[character|integer]} index to column that uniquely identifies a row.\cr
#'   \code{verbose}\tab \code{[logical]} toggle verbosity.\cr
#' \code{file}\tab [character] filename for temporaty log storage. \cr
#' }
#' 
#' 
#' @section Dump options:
#' \code{$dump(file="cellwise.csv")}
#' \tabular{ll}{
#'   \code{file}\tab \code{[character]} location to write final output to.
#' }
#' 
#' @section Getting data from the logger:
#' 
#' \code{$logdata()} Returns a data.frame (it dumps, then reads the current log).
#' 
#' @section Details:
#' At initialization, the cellwise logger opens a connection to a temporary 
#' file. All logging info is written to that connection. When 
#' \code{\link{dump_log}} is called, the temporary file is closed, copied to the
#' output file, and reopened for writing. The connection is closed automatically
#' when the logger is destroyed, for example when calling 
#' \code{dump_log(stop=TRUE)} (the default), or \code{stop_log()} in the
#' lumberjack pipeline.
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
    , label   = NULL
    , key     = NULL
  , initialize = function(key, verbose=TRUE, file=file.path(tempdir(),"cellwise.csv")){
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
          , key=character(0)
          , variable=character(0)
          , old=character(0)
          , new=character(0)
        )
        , file=self$con
        , row.names=FALSE
      )
  }
  , stop = function(...){
       self$con <- iclose(self$con)
  }
  , add = function(meta, input, output){
      if (!is_open(self$con)) return()
      self$n <- self$n+1
      # timestamp
      ts <- strftime(Sys.time(),usetz=TRUE)
      d <- celldiff(input, output, self$key)
      if (nrow(d) == 0) return()
      d$step <- self$n
      d$time <- ts
      d$expression <- meta$src
      d <- d[c(5:7,1:4)]
      write.table(d,file = self$con
            , row.names=FALSE, col.names=FALSE, sep=",")
  }
  , dump = function(file=NULL){
      self$con <- iclose(self$con)
      if (is.null(file)){ 
        file <- "cellwise.csv" 
        if (!is.null(self$label) && self$label != "" ) file <- paste(self$label,file,sep="_")
      }
      file.copy(from=self$tmpfile, to=file, overwrite = TRUE)
      if (self$verbose){
        msgf("Dumped a log at %s",file)
      }
  }
  , finalize = function(){
    if (is_open(self$con)) close(self$con)
  }
  , logdata = function(){
     read.csv(self$tmpfile)
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
  # we need doube brackets, for tibbles.
  kf <- expand.grid(key=x[[key]],variable=col_x)
  # we need as.data.frame for certain tibbles (created with group_by)
  kf$value <- Reduce(cc, as.data.frame(x[col_x]))
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







