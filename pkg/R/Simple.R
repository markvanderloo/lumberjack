# Implementation of the simple logger.


#' The simple logger.
#' 
#' The simple logger registers the name of the function
#' applied to an object; a \code{POSIXct} timestamp and
#' a logical indicating whether the input is identical to the
#' output.
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @export
simple <- R6Class("simple"
  , public=list(
    n = NULL
    , store = NULL
    , verbose = NULL
    , initialize = function( verbose = TRUE){
      self$n <- 0
      self$store <- new.env()
      self$verbose <- verbose
    }
    , add = function(meta, input, output){
      self$n <- self$n + 1
      logname <- sprintf("step%03d",self$n)
        logdat <- data.frame(step = self$n, time = Sys.time()
                   , expr  = meta$src
                   , changed = !identical(input, output)
                   , stringsAsFactors = FALSE) 
      self$store[[logname]] <- logdat
      
    }
    , dump = function(file="simple_log.csv",...){
        log_df <- do.call(rbind,mget(ls(self$store), self$store))
        write.csv(log_df, file=file, row.names = FALSE,...)
        if (is.character(file) && self$verbose ){
          msgf("Dumped a log at %s", normalizePath(file))
        }
    }
))
