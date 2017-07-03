#' The pipe operator that logs
#' 
#' 
#' 
#' 
#' @section Overview:
#' 
#' The lumberjack \code{\%>>\%} behaves much like other function
#' composition ('pipe') operators available in R (e.g. \href{https://CRAN.R-project.org/package=magrittr}{magrittr}
#' , \href{https://github.com/piccolbo/yapo}{yapo}, \href{https://CRAN.R-project.org/package=pipeR}{pipeR})
#' with one exception: it allows for logging the changes made to the data
#' by the functions acting on it.
#' 
#' The actual logging mechanism is completely flexible and extensible. This
#' package comes with a few predefined loggers, but users and package authors
#' can write their own logger that follows the lumberjack API.
#' 
#' See the \href{../doc/intro.html}{Introductory vignette} to start logging
#' or the \href{../doc/extending.html}{extending lumberjack} manual to start 
#' writing your own loggers.
#'
#' Happy logging!
#'
#' @docType package
#' @name lumberjack
#' @importFrom R6 R6Class
#' @importFrom utils capture.output
#' 
{}



LOGNAME <- "__log__"

#' Get log object from a data item
#'
#'
#' @param data An R object carrying data.
#' 
#' @return A logging object, or \code{NULL} if none exists.
#' 
#' @export
get_log <- function(data){
  attr(data, which=LOGNAME, exact=TRUE)
}

has_log <- function(data){
  !is.null(get_log(data))
}


#' Start logging changes on a dataset.
#' 
#' @param data An R object carrying data.
#' @param log A logging object (typically an environment wrapped in an S3 class)
#'
#' @export
start_log <- function(data, log=simple$new()){
  attr(data, LOGNAME) <- log
  invisible(data)
}

remove_log <- function(data){
  attr(data, which=LOGNAME) <- NULL
  data
}

#' Dump a log
#' 
#' @param data data set containing a log
#' @param stop stop logging after the dump?
#' @param ... Arguments past to the \code{dump} method of the logger.
#'
#' @return  The data, invisibly
#' 
#' @export
dump_log <- function(data, stop=FALSE, ...){
  log <- get_log(data)
  log$dump(...)
  if (stop) invisible(remove_log(data)) else invisible(data)
}

#' Stop logging
#' 
#' @param data An R object carrying data
#' @param ... currently unused
#' 
#' @export
stop_log <- function(data, ...){
  remove_log(data)
}



#' The lumberjack operator
#' 
#' A not-a-pipe operator that logs
#' 
#'
#'
#' @param lhs Input value
#' @param rhs Function call or 'dotted' expression (see below). 
#'     as value
#' 
#' @section Piping:
#' 
#' The operators \code{\%>>\%} and \code{\%L>\%} are synonyms. The \code{\%L>\%}
#' can be used to avoid confusion with the \code{\%>>\%} operator of the
#' \code{pipeR} package.
#' 
#' The lumberjack operator behaves more or less as a simplified version of the 
#' \code{magrittr} pipe operator. The basic behavior of \code{lhs \%>>\% rhs} is
#' the following:
#'
#'\itemize{
#'  \item{If the \code{rhs} uses dot-variables (\code{.}), these are interpreted
#'  as the left-hand side, except in formulas where dots already have a special 
#'  meaning.}
#'  \item{If the \code{rhs} is a function call, with no dot-variables used, the
#'  \code{lhs} is used as its first argument.}
#' }
#' The most notable differences with `magrittr` are the following.
#' \itemize{
#'   \item{ it does not allow you to define functions in the magrittr style,
#'   like \code{a <- . \%>\% sin(.) } 
#'   }
#'   \item{there is no assignment-pipe like \code{\%<>\%}.}
#' }
#' 
#' 
#' @section Logging:
#' 
#' If the left-hand-side is tagged for logging, the lumberjack will update the 
#' log by calling the logger's \code{$add()} method, with arguments \code{meta},
#' \code{input}, \code{output}. Here, \code{meta} is a list with information on
#' the operations performed, and input and output are the left-hand-side and the
#' result, respectively (See also: \href{../doc/extending.html}{extending
#' lumberjack}).
#' 
#' @example ../examples/lumberjack.R
#' 
#' @export 
`%>>%` <- function(lhs, rhs){
  # basic pipe action
  rhs <- substitute(rhs)
  
  # need to pass environment so symbols defined there and passed
  # as argument can be resolved in NSE situations (see test_simple
  # for an example).
  out <- pipe(lhs, rhs, env=parent.frame())
  
  meta <- list(
    expr = as.expression(rhs)
    , src = as.character(as.expression(rhs))
  )
  # update logging if set
  if ( has_log(lhs) ){
    log <- get_log(lhs)
    log$add(meta=meta, input=lhs, output=out)
  }
  
  out
}


#' @rdname grapes-greater-than-greater-than-grapes
`%L>%` <- `%>>%`


