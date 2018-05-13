



#' The expression logger.
#' 
#' The expression logger records the result of one or more user defined
#' expressions. It can be used, for example to track aggregates (mean, min, max)
#' of variables as they get processed in the data pipeline.
#' 
#' 
#' 
#' \code{\link{dump_log}(stop=TRUE)} or \code{\link{stop_log}()}.
#' 
#' @section Creating a logger:
#' \code{expression_logger$new(..., file="expression_log.csv"}
#' \tabular{ll}{
#' \code{...}\tab comma-separated \code{name = expression} pairs\cr
#' \code{file}\tab [character] filename for temporaty log storage. \cr
#' }
#' 
#' 
#' @section Dump options:
#' \code{$dump()}
#' \tabular{ll}{
#'   \code{}\tab Currently no options are implemented.
#' }
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
    , file=NULL
    , initialize = function(..., file="expression_log.csv"){
        self$step       = c()
        self$expression = c()
        self$file       = file
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
    , dump = function(...){
      write.csv(cbind(
            step=self$step
          , expression= self$expression
          , self$result, stringsAsFactors = FALSE)
        , file=self$file
        , row.names=FALSE)
      lumberjack:::msgf("Dumped a log at %s",self$file)
    }
  )
)




