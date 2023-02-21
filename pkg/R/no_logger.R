# Implementation of the simple logger.


#' The nop logger
#' 
#' Record nothing, but present logger interface.
#' 
#' @section Creating a logger:
#' 
#' \code{no_logger$new(verbose=TRUE)}
#' \tabular{ll}{
#'   \code{verbose}\tab toggle verbosity
#' }
#' 
#' @section Dump options: 
#' 
#' \code{$dump(file=NULL,...)}
#' \tabular{ll}{
#' \code{file}\tab Ignored. Filename or \code{\link[base]{connection}} to write output to.\cr
#' \code{...}\tab Ignored. extra options passed to \code{\link[utils]{write.csv}}, except
#' \code{row.names}, which is set to \code{FALSE}.\cr
#' }
#' 
#' No file or output is created, except a message when \code{verbose=TRUE}.
#'
#' @section Get data:
#' \code{$logdata()} Returns empty data.frame.
#' 
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @example ../examples/no_log.R
#' 
#' @family loggers
#' @export
no_log <- R6Class("no_log"
  , private = list(
      verbose = NULL
    )
  , public = list(
      label = NULL
    , initialize = function( verbose = TRUE){
        private$verbose <- verbose
    }
    , add = function(meta, input, output){
      # NOP! we don't store anything!
    }
    , dump = function(file=NULL,...){
      log_df <- data.frame()
      if (is.null(file)){ 
        file <- "no_log.csv"
      }
      write.csv(log_df, file=file, row.names = FALSE,...)
      if (is.character(file) && private$verbose ){
          msgf("no_log dumped at %s", normalizePath(file))
      }
    }
    , logdata = function(){
      data.frame()
    }
  )
)
