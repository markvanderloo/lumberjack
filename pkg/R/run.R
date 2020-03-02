# get names of loggers
get_loggers <- function(store, dataset){ 
   a <-  ls(store[[dataset]])
   a[a != "data"]
}


# store: environment to store data and logger.
#
# store$dataset$data
#              $simple
#              $cellwise
log_capture <- function(store){
    function(data, logger, label=NULL){
      dataset <- as.character(substitute(data))
      if (!dataset %in% ls(store)){ 
        store[[dataset]] <- new.env()
        store[[dataset]]$data <- data
      } 
      loggers   <- get_loggers(store, dataset)
      newlogger <- class(logger)[[1]]
      if ( newlogger  %in% loggers ){
        warnf("Can not add a second logger of class '%s' to '%s'. Ignoring."
          , class(logger)[[1]], dataset)
        return(invisible(data))
      }
  
      # loggers that have a 'label' slot have access to
      # the name of the dataset
      if ( "label" %in% ls(logger) ){
        dataset <- as.character(substitute(data))
        lab <- if (!is.null(label)) paste(label,collapse="") 
        else if (length(dataset) == 1) dataset
        else ""
        logger$label <- lab
      }
      store[[dataset]][[newlogger]] <- logger
      invisible(data)
    }
}

# We need some detailed dump options because there may be multiple loggers, for
# multiple datasets and the user may want to choose what logs to dump.
dump_capture <- function(store){
  function(data=NULL, logger = NULL, stop=TRUE, ...){ 

    if (is.null(data) && is.null(logger)){ 
      # dump all loggers for all datasets
      for (dataset in ls(store)){
        loggers <- get_loggers(store, dataset)
        for (lggr in loggers){
          store[[dataset]][[lggr]]$dump(...)
          if (stop) rm(list = lggr, envir = store[[dataset]])
        }
      }
      return(invisible(NULL))
    }
    
    if (!is.null(data)){
      dataset <- as.character(substitute(data))
      if (is.null(store[[dataset]])){ 
        msgf("Note: dataset '%s' is not logged", dataset)
        return(invisible(data))
      }
    }


    if ( is.null(logger) ){
      # dump all loggers for the current dataset
      loggers <- get_loggers(store, dataset)
      for (lggr in loggers){
        store[[dataset]][[lggr]]$dump(...)
        if (stop) rm(list=lggr, envir = store[[dataset]])
      }
      return(invisible(data))
    }

    if (is.character(logger)){
      for (lggr in logger){
        if ( is.null(store[[dataset]][[lggr]]) ){
          warnf("Logger '%s' not found for dataset '%s'", lggr, dataset)
          next
        }
        store[[dataset]][[lggr]]$dump(...)
        if (stop) rm(list=lggr, envir=store[[dataset]])
      } 
      return(invisible(data))
    }
    stop("Invalid input for 'dump'",call.=FALSE)
  }
}

update_loggers <- function(store, envir, expr, src){
  datasets <- ls(store)
  meta     <- list(expr = expr
                 , src  = src)

  for ( dataset in datasets ){
    old <- store[[dataset]]$data
    new <- get(dataset, envir=envir)
    loggers <- get_loggers(store, dataset)
    for ( logger in loggers ){
      store[[datasets]][[logger]]$add(meta, old, new)
    }
    store[[dataset]]$data <- new
  }
  invisible(NULL)
}

#' Run a file while tracking changes in data
#'
#' Run all code in a file. Changes in data that are tracked, (e.g.  with
#' \code{\link{start_log}(data)}) will be followed by the assigned loggers.
#' 
#'
#' @param file \code{[character]} file to run.
#' @param auto_dump \code{[logical]} Toggle automatically dump all remaining logs
#' after executing \code{file}.
#' @param envir \code{[environment]} to run the code in. By default a new environment will be created
#' with \code{.GlobalEnv} as parent.
#'
#'
#' @section Details:
#' \code{run\_file} runs code in a separate environment, and returns the environment with all
#' the variables created by the code. \code{source\_file} acts like \code{\link{source}} and 
#' runs all the code in the current global workspace (\code{.GlobalEnv}).
#' 
#'
#' @return The environment where the code was executed, invisibly.
#'
#'
#' @examples
#' # using 'dontrun'
#' \dontrun{
#' # create an R file, with logging.
#' script <- "
#' library(lumberjack)
#' data(women)
#' start_log(women, logger=simple$new())
#' women$height <- women$height*2.54
#' women$weight <- women$weight*0.453592
#' dump_log()
#' "
#' write(script, file="myscript.R")
#' # run the script
#' lumberjack::run_file("myscript.R")
#' # read the logfile
#' read.csv("women_simple.csv")
#' }
#'
#' @family control
#' @export
run_file <- function(file, auto_dump=TRUE, envir=NULL){
  fname <- basename(file)
  dname <- dirname(file)
  oldwd <- getwd()
  on.exit(setwd(oldwd))
  setwd(dname)


  if (is.null(envir)) envir=new.env(parent=.GlobalEnv)

  store <- new.env()
  
  envir$start_log <- log_capture(store)
  envir$dump_log  <- dump_capture(store)

  prog <- parse(fname, keep.source=TRUE)
  src  <- attr(prog, "srcref")

  for ( i in seq_along(prog) ){
    eval(prog[[i]], envir=envir)
    update_loggers(store, envir, prog[[i]], as.character(src[[i]]))
  }
  # dump everything not dumped yet.
  if (auto_dump) eval(envir$dump_log(), envir=envir)

  rm(list=c("start_log","dump_log"), envir=envir)
  invisible(envir)
}

#' @rdname run_file
#' @export
source_file <- function(file, auto_dump=TRUE){
  run_file(file, auto_dump=auto_dump, envir=.GlobalEnv)
}



