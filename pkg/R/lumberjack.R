#' Track changes in data
#' 
#' This package allows you to track changes in R objects by defining one or
#' more loggers for each object. There are a number of built-in loggers and
#' users (or package authors) can create their own loggers.  To get started
#' please have a look at the \href{../doc/using_lumbjerjack.pdf}{using
#' lumberjack} vignette.
#' 
#' @author
#' Mark van der Loo
#'
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
#' @param data An R object. 
#' @param logger \code{[character]} scalar. Logger to return. Can be
#'   \code{NULL} when a single logger is attached.
#' @return A logging object, or \code{NULL} if none exists.
#' 
#'
#' @family control
#'
#' @export
get_log <- function(data, logger=NULL){
  store <- attr(data, which=LOGNAME, exact=TRUE)
  dataset <- as.character(substitute(data))

  if ( is.null(store) || ( !is.null(store) & length(ls(store))==0 )){ 
    return(NULL)
  }

  loggers <- ls(store)

  if (is.null(logger)){
    if ( length(loggers) == 1 ){
      return(store[[loggers]])
    } else {
      stopf("Dataset has multiple loggers attached. Specify one of: %s"
        , paste(sprintf("'%s'",loggers), collapse=","))
    }
  }

  if ( is.null(store[[logger]]) ){
    stopf("Dataset is not logged by '%s'", logger)
  }
  store[[logger]]
}

has_log <- function(data){
  !is.null(attr(data,LOGNAME))
}


#' Start tracking an R object
#' 
#' @param data An R object.
#' @param logger A logging object (typically an environment wrapped in an S3 class)
#' @param label \code{[character]} scalar. A label to attach to the logger (for
#'   loggers supporting it).
#'
#'
#' @section Details:
#' All loggers that come with \pkg{lumberjack} support labeling. The label is
#' used by \code{dump} methods to create a unique file name for each
#' object/logger combination.
#'
#' If \code{label} is not supplied, \code{start_log} attemtps to create a label
#' from the name of the \code{data} variable. This probably fails when
#' \code{data} is not a variable but an expression (like \code{read.csv...}). A
#' label is also not created when data is passed via the lumberjack not-a-pipe
#' operator.  In that case the label is (silently) not set. In cases where
#' multiple datasets are logged with the same type of logger, this could lead
#' to overwriting of dump files, unless \code{file} is explicitly defined when
#' calling \code{\link{dump_log}}.
#'
#' @examples
#' logfile <- tempfile(fileext=".csv")
#' women %L>%
#'   start_log(logger=simple$new()) %L>%
#'   transform(height_cm = height*2.52) %L>%
#'   dump_log(file=logfile)
#' logdata <- read.csv(logfile)
#' head(logdata)
#'
#' @family control
#' @export
start_log <- function(data, logger=simple$new(), label=NULL){
  if ( is.null(attr(data, LOGNAME)) ){
    attr(data, LOGNAME) <- new.env()
  }
  store <- attr(data, LOGNAME)
  newlogger <- class(logger)[[1]]
  if ( newlogger %in% ls(store) ){
    warnf("Can not add second logger of class '%s'. Ignoring", newlogger)
    return(invisible(data))
  }
  # loggers that have a 'dataset' slot have access to
  # the name of the dataset
  if ( "label" %in% ls(logger) ){
    dataset <- as.character(substitute(data))
    lab <- if (!is.null(label)) paste(label,collapse="") 
    else if (length(dataset) == 1) dataset
    else ""
    logger$label <- lab
  }
  store[[ class(logger)[[1]] ]] <- logger
  invisible(data)
}

remove_log <- function(data, logger){
  store <- attr(data, LOGNAME)
  if ( is.null(store) ) return(data)
  rm(list=logger, envir=store)
  if (length(ls(store)) == 0)
  attr(data, LOGNAME) <- NULL
  data
}


all_loggers <- function(data){
  store <- attr(data,LOGNAME)
  if (is.null(store)) character(0)
  else ls(store)
}

#' Dump logging data
#' 
#' Calls the \code{$dump(...)} method of logger(s) tracking an R object.
#' 
#' 
#' @param data An R object tracked by one or more loggers.
#' @param logger \code{[character]} vector. Class names of loggers to dump (e.g.
#'   \code{"simple"}).  When \code{loggers=NULL}, all loggers are dumped
#'   for this object.
#' @param stop \code{[logical]} stop logging after the dump? Removes the
#'   logger(s) tracking the object.
#' @param ... Arguments passed to the \code{dump} method of the logger.
#'
#' @return  \code{data}, invisibly.
#' 
#' 
#' @family control 
#' 
#' 
#' @examples
#' logfile <- tempfile(fileext=".csv")
#' women %L>%
#'   start_log(logger=simple$new()) %L>%
#'   transform(height_cm = height*2.52) %L>%
#'   dump_log(file=logfile)
#' logdata <- read.csv(logfile)
#' head(logdata)
#' 
#' 
#' @export
dump_log <- function(data, logger=NULL,stop=TRUE, ...){
  if ( is.null(logger) ) logger <- all_loggers(data)
  for ( lggr in logger ){
    log <- get_log(data, logger=lggr)
    log$dump(...)
    if (stop) return(invisible(remove_log(data,logger=logger)))
  }
  invisible(data)
}

#' Stop logging
#' 
#' Calls the logger's \code{$stop()} method if it exists, and removes
#' the logger as attribute from \code{data}.
#' 
#' @param data An R object.
#' @param logger \code{[character]} vector. Class names of loggers to dump (e.g.
#'   \code{"simple"}).  When \code{loggers=NULL}, all loggers are stopped and
#'   removed for this data.
#' @param ... Passed to the logger's \code{stop} method, if it exists.
#' 
#' @return The data, invisibly.
#'
#'
#' @examples
#' logfile <- tempfile(fileext=".csv")
#' women %L>%
#'   start_log(logger=simple$new()) %L>%
#'   transform(height_cm = height*2.52) %L>%
#'   dump_log(file=logfile)
#' logdata <- read.csv(logfile)
#' head(logdata)
#'
#' @family control
#' @export
stop_log <- function(data, logger=NULL, ...){
  if (is.null(logger)) logger <- all_loggers(data)
  for ( lggr in logger ){
    log <- get_log(data, logger = lggr)
    if (is.function(log$stop)) log$stop(...)
    remove_log(data, lggr)
  }
  invisible(data)
}



#' The lumberjack operator
#' 
#' The not-a-pipe operator that tracks changes in data.
#' 
#'
#' @param lhs Input value
#' @param rhs Function call or 'dotted' expression (see below). 
#'     as value
#' 
#' @section Piping:
#' 
#' The operators \code{\%L>\%} and \code{\%>>\%} are synonyms. The \code{\%L>\%}
#' is the default since version 0.3.0 to avoid confusion with the \code{\%>>\%}
#' operator of the \code{pipeR} package but \code{\%>>\%} still works.
#' 
#' The lumberjack operator behaves as a simplified version of the
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
#'   \item{you cannot do things like \code{x \%>\% sin} (without the brackets).}
#' }
#' 
#' 
#' @section Logging:
#' 
#' If the left-hand-side is tagged for logging, the lumberjack will update the 
#' log by calling the logger's \code{$add()} method, with arguments \code{meta},
#' \code{input}, \code{output}. Here, \code{meta} is a list with information on
#' the operations performed, and input and output are the left-hand-side and the
#' result, respectively. 
#' 
#' @example ../examples/lumberjack.R
#' @family control
#' @export 
`%>>%` <- function(lhs, rhs){
  store <- attr(lhs, LOGNAME)

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
    for (lggr in all_loggers(lhs)){
      log <- get_log(lhs, lggr)
      log$add(meta=meta, input=lhs, output=out)
    }
  }
  # if a naughty function has removed the log-store, we add it back.
  # except when it was removed by dump_log()
  if ( has_log(lhs) && 
      !as.character(rhs[[1]]) %in% c("dump_log","remove_log","stop_log") && 
      !has_log(out)){
    attr(out,LOGNAME) <- store
  }
  out
}


#' @rdname grapes-greater-than-greater-than-grapes
#' @export
`%L>%` <- `%>>%`


