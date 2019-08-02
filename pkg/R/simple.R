# Implementation of the simple logger.


#' The simple logger.
#' 
#' The simple logger registers the expression
#' applied to an object; a \code{POSIXct} timestamp and
#' a logical indicating whether the input is identical to the
#' output.
#' 
#' @section Creating a logger:
#' 
#' \code{simple$new(verbose=TRUE)}
#' \tabular{ll}{
#'   \code{verbose}\tab toggle verbosity
#' }
#' 
#' @section Dump options: 
#' 
#' \code{$dump(file="simple_log.csv",...)}
#' \tabular{ll}{
#' \code{file}\tab filename or \code{\link[base]{connection}} to write output to.\cr
#' \code{...}\tab extra options passed to \code{\link[utils]{write.csv}}, except
#' \code{row.names}, which is set to \code{FALSE}.\cr
#' }
#' 
#' @section Get data:
#' \code{$logdata()} Returns a \code{data.frame}.
#' 
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @example ../examples/simple.R
#' 
#' @family loggers
#' @export
simple <- R6Class("simple"
  , public=list(
    n = NULL
    , store = NULL
    , verbose = NULL
    , label = NULL
    , initialize = function( verbose = TRUE){
      self$n <- 0
      self$store <- new.env()
      self$verbose <- verbose
    }
    , add = function(meta, input, output){
      self$n <- self$n + 1
      logname <- sprintf("step%03d",self$n)
        logdat <- data.frame(step = self$n, time = Sys.time()
                   , expression  = meta$src
                   , changed = !identical(input, output)
                   , stringsAsFactors = FALSE) 
      self$store[[logname]] <- logdat
      
    }
    , dump = function(file=NULL,...){
        log_df <- do.call(rbind,mget(ls(self$store), self$store))
        if (is.null(file)){ 
          file <- "simple.csv"
          if (!is.null(self$label)) file <- paste(self$label,file,sep="_")
        }
        write.csv(log_df, file=file, row.names = FALSE,...)
        if (is.character(file) && self$verbose ){
          msgf("Dumped a log at %s", normalizePath(file))
        }
    }
    , logdata = function(){
        v <- self$verbose
        self$verbose <- FALSE
        fl <- tempfile()
        self$dump(file=fl)
        out <- read.csv(fl)
        self$verbose <- v
        out
    }
))
