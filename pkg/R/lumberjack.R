#' The pipe operator that smokes!
#' 
#' 
#' 
#' @section Overview:
#' 
#' The lumberjack operator \code{\%>>\%} behaves much like other function
#' composition operators available in R (e.g. \href{https://CRAN.R-project.org/package=magrittr}{magrittr}
#' , \href{https://github.com/piccolbo/yapo}{yapo}, \href{https://CRAN.R-project.org/package=pipeR}{pipeR})
#' with one exception: it allows for logging the changes made to the data
#' by the functions acting on it.
#' 
#' The actual logging mechanism is completely flexible and extensible. Users
#' can create loggers that store information locally, pump it to a database,
#' or send it as an e-mail to their bosses. The limit is your imagination. This
#' package comes with a few predefined relatively simple loggers that are already
#' quite useful. They also serve as coded examples on how to use this package.
#' 
#' For more information, see the \href{../doc/intro.html}{Introductory vignette},
#' or the \href{../doc/extending.html}{extending lumberjack} manual.
#'
#' Happy logging!
#'
#' @docType package
#' @name lumberjack
#' @importFrom R6 R6Class
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
#' @value The data, invisibly
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
#' @section: Definition of the piping action.
#' 
#' The left-hand-side of the lumberjac operator must be an R value (maybe
#' resulting from a previous operation). There are two options for the right-hand-side.
#' First, the right-hand-side can be a call
#' to a function, where the first argument and any dot "\code{.}" will be 
#' replaced with the left-hand-side argument. Second, the right-hand-side can
#' be an expression, enclosed in brackets \code{()} or braces \code{{}}. The
#' expression will be evaluated such that the dot is replaced by the 
#' left-hand side.
#' 
#' If the left-hand-side is logged, the lumberjack will update the 
#' log by calling the logger's \code{add()} method, with arguments
#' \code{meta}, \code{input}, \code{output}. Here, \code{meta} is
#' a list with information on the operations performed, and
#' input and output are the left-hand-side and the result, respectively 
#' (See also: \href{../doc/extending.html}{extending lumberjack}).
#' 
#' 
#' @export 
`%>>%` <- function(lhs, rhs){
  # basic pipe action
  rhs <- substitute(rhs)
  
  # need to pass environment so symbols defined there, and passed
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


