# Implementation of the cellwise logger.


#' The cellwise logger.
#' 
#' The cellwise logger registers the row, column, old, and new value of cells
#' that changed, along with a step number, timestamp, source reference, and the
#' expression used to alter a dataset. 
#' 
#' @section Creating a logger:
#' \code{cellwise$new(key, verbose=TRUE, file=tempfile())}
#' \tabular{ll}{
#'   \code{key}\tab \code{[character|integer]} index to column that uniquely identifies a row.\cr
#'   \code{verbose}\tab \code{[logical]} toggle verbosity.\cr
#'   \code{tempfile}\tab [character] filename for temporary log storage. \cr
#' }
#' 
#' @usage 
#' cellwise(key, verbose=TRUE, tempfile=file.path(tempdir(),"cellwise.csv"))
#'
#' @param key \code{[character|integer]} index to column that uniquely identifies a row.
#' @param verbose  \code{[logical]} toggle verbosity.
#' @param tempfile  \code{[character]} filename for temporary log storage.
#'
#' @section Dump options:
#'
#' \code{$dump(file=NULL)}
#' \tabular{ll}{
#'   \code{file}\tab \code{[character]} location to write final output to.\cr
#' }
#' The default location is \code{"cellwise.csv"} in an interactive session, and
#' \code{"DATA_cellwise.csv"} in a script that executed via \code{\link{run_file}}.
#' Here, \code{DATA} is the variable name of the data being tracked or the
#' \code{label} provided with \code{\link{start_log}}.
#' 
#' 
#' @section Getting data from the logger:
#' 
#' \code{$logdata()} Returns a data frame with the current log.
#' 
#' @section Details:
#' At initialization, the cellwise logger opens a connection to a temporary
#' file. All logging info is appended to that connection. When
#' \code{\link{dump_log}} is called, the temporary file is closed, copied to
#' the output file, and reopened for writing. The connection is closed
#' automatically when the logger is destroyed, for example when calling
#' \code{\link{stop_log}()}.
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @example ../examples/cellwise.R
#' 
#' @family loggers
#' @export
cellwise <- R6Class("cellwise"
  , private = list(
    tmpfile   = NULL
    , con     = NULL
    , n       = NULL 
    , verbose = NULL
    , key     = NULL
  )
  , public = list(
     label   = NULL
   , initialize = function(key, verbose=TRUE, tempfile=file.path(tempdir(),"cellwise.csv")){
      if(missing(key)) stop("you must provide a key")
      private$tmpfile = tempfile
      private$con = file(private$tmpfile, open="wt")
      private$n <- 0
      private$verbose <- verbose
      private$key <- key
      write.csv(
        data.frame(
          step=integer(0)
          , time=character(0)
          , srcref=character(0)
          , expression=character(0)
          , key=character(0)
          , variable=character(0)
          , old=character(0)
          , new=character(0)
        )
        , file=private$con
        , row.names=FALSE
      )
  }
  , stop = function(...){
       private$con <- iclose(private$con)
  }
  , add = function(meta, input, output){
      if (!is_open(private$con)) return()
      private$n <- private$n+1
      # timestamp
      ts <- strftime(Sys.time(),usetz=TRUE)
      d <- celldiff(input, output, private$key)
      if (nrow(d) == 0) return()
      d$step <- private$n
      d$time <- ts
      d$expression <- meta$src
      d$srcref <- get_srcref(meta)
      d <- d[c(5,6,8,7,1:4)]

      write.table(d,file = private$con
            , row.names=FALSE, col.names=FALSE, sep=",")
  }
  , dump = function(file=NULL){
      private$con <- iclose(private$con)
      if (is.null(file)){ 
        file <- "cellwise.csv" 
        if (!is.null(self$label) && self$label != "" ) file <- paste(self$label,file,sep="_")
      }
      file.copy(from=private$tmpfile, to=file, overwrite = TRUE)
      if (private$verbose){
        msgf("Dumped a log at %s",file)
      }
  }
  , finalize = function(){
    if (is_open(private$con)) close(private$con)
  }
  , logdata = function(){
     read.csv(private$tmpfile)
  }
  )
)

# A reasonable connection closer
iclose <- function(con,...){
  if (!is.null(con)) close(con,...)
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
  # we need double brackets, for tibbles.
  kf <- expand.grid(key=x[[key]],variable=col_x)
  # we need as.data.frame for certain tibbles (created with group_by)
  kf$value <- Reduce(cc, as.data.frame(x[col_x]))
  isort(kf, c("key","variable"))
}

celldiff <- function(x,y,key){
  if ( anyDuplicated(x[,key]) || anyDuplicated(y[,key]) ){
    warnf("Detected duplicates in key variable '%s'. Logging data corrupted.",key)
  }
  
  kx <- keyframe(x,key)
  ky <- keyframe(y,key)
  kxy <- merge(kx,ky,by=c("key","variable"), all=TRUE)
  na_x <- is.na(kxy$value.x)
  na_y <- is.na(kxy$value.y)
  d_xy <- (na_x & !na_y) | (!na_x & na_y) | 
      (!na_x & !na_y & kxy$value.x != kxy$value.y)
  kxy[d_xy,]
}







