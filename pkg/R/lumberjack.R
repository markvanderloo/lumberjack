#' lumberjack
#' 
#' 
#' @docType package
#' @name lumberjack
#' 
#' @description 
#' 
#' A not-a-pipe operator that logs.
#' 
#'
#' @importFrom R6 R6Class
#' @importFrom magrittr %>%
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
#' @export
dump_log <- function(data, stop=FALSE, ...){
  log <- get_log(data)
  log$dump(...)
  if (stop) remove_log(data) else data
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
  out <- pipe(lhs, rhs)
  
  meta <- lapply(as.list(rhs),deparse)
  # update logging if set
  if ( has_log(lhs) ){
    log <- get_log(lhs)
    log$add(meta=meta, input=lhs, output=out)
  }
  
  out
}


