# Implementation of the simple logger.


#' The simple logger
#' 
#' Record for each expression a \code{POSIXct} timestamp and a logical
#' indicating whether the tracked object has changed.
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
#' \code{$dump(file=NULL,...)}
#' \tabular{ll}{
#' \code{file}\tab filename or \code{\link[base]{connection}} to write output to.\cr
#' \code{...}\tab extra options passed to \code{\link[utils]{write.csv}}, except
#' \code{row.names}, which is set to \code{FALSE}.\cr
#' }
#' 
#' The default location is \code{"simple.csv"} in an interactive session, and
#' \code{"DATA_simple.csv"} in a script that executed via \code{\link{run_file}}.
#' Here, \code{DATA} is the variable name of the data being tracked 
#' or the \code{label} provided with \code{\link{start_log}}.
#'
#'
#' @section Get data:
#' \code{$logdata()} Returns a data frame with the current log.
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
  , private = list(
      n = NULL
      , store = NULL
      , verbose = NULL
      , label = NULL
    )
  , public = list(
    initialize = function( verbose = TRUE){
      private$n <- 0
      private$store <- new.env()
      private$verbose <- verbose
    }
    , add = function(meta, input, output){
      private$n <- private$n + 1
      logname <- sprintf("step%03d",private$n)
        logdat <- data.frame(step = private$n, time = Sys.time()
                   , expression  = meta$src
                   , changed = !identical(input, output)
                   , stringsAsFactors = FALSE) 
      private$store[[logname]] <- logdat
      
    }
    , dump = function(file=NULL,...){
        log_df <- do.call(rbind,mget(ls(private$store), private$store))
        if (is.null(file)){ 
          file <- "simple.csv"
          if (!is.null(private$label) && private$label != "" ) file <- paste(private$label,file,sep="_")
        }
        write.csv(log_df, file=file, row.names = FALSE,...)
        if (is.character(file) && private$verbose ){
          msgf("Dumped a log at %s", normalizePath(file))
        }
    }
    , logdata = function(){
        v <- private$verbose
        private$verbose <- FALSE
        fl <- tempfile()
        self$dump(file=fl)
        out <- read.csv(fl)
        private$verbose <- v
        out
    }
  )
)
