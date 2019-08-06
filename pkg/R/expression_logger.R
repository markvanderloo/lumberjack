



#' The expression logger.
#' 
#' Records the result of one or more user-defined expressions that perform
#' calculations on the object being tracked.
#' 
#' @section Creating a logger: 
#' \code{expression_logger$new(..., verbose=TRUE)}
#' \tabular{ll}{
#' \code{...}\tab A comma-separated list of \code{name = expression} pairs. \cr
#' \code{verbose}\tab \code{[logical]} toggle verbosity.
#' }
#'
#' Each expression will be evaluated in the context of the object tracked with
#' this logger. An expression is expected to have a single \code{numeric} or
#' \code{character} output.
#'
#'
#' @section Dump options:
#'
#' \code{$dump(file=NULL)}
#' \tabular{ll}{
#'   \code{file}\tab \code{[character]} location to write final output to.\cr
#' }
#' The default location is \code{"expression.csv"} in an interactive session, and
#' \code{"DATA_expression.csv"} in a script that executed via \code{\link{run}}.
#' Here, \code{DATA} is the variable name of the data being tracked
#' or the \code{label} provided with \code{\link{start_log}}.
#' 
#' 
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @example ../examples/expression_logger.R
#' 
#' @family loggers
#' @export
expression_logger <- R6Class("expression_loggger"
  , public=list(
    step = NULL
    , s=0
    , expr = NULL
    , expression = NULL
    , result = NULL
    , verbose=TRUE
    , label=NULL
    , initialize = function(..., verbose=TRUE){
        self$step       <- c()
        self$expression <- c()
        self$verbose    <- verbose
        self$expr <- as.list(substitute(list(...))[-1])
    }
    , add = function(meta, input, output){
        self$s <- self$s + 1
        self$step   <- append(self$step, self$s)
        self$expression <- append(self$expression, meta$src)
        out <- lapply(self$expr, function(e) with(output, eval(e)))
        out <- do.call(data.frame, out)
        if(is.null(self$result)){
          self$result <- out
        } else {
          self$result <- rbind(self$result, out)
        }
    }
    , dump = function(file=NULL,...){
        if (is.null(file)){
          file <- "expression.csv"
          if (!is.null(self$label) && self$label != "") file <- paste(self$label, file, sep="_")
        }
        d <- cbind(
              step       = self$step
            , expression = self$expression
            , self$result
            , stringsAsFactors = FALSE)
        write.csv(d, file=file , row.names=FALSE)
        if( self$verbose ) lumberjack:::msgf("Dumped a log at %s", file)
    }
  )
)




