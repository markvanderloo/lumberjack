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
    function(data, logger){
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

update_loggers <- function(store, envir, expr){
  datasets <- ls(store)
  meta     <- list(expr = expr
                 , src = paste(capture.output(print(expr)),collapse="\n"))

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

#' Run a file with loggers enabled.
#'
#' @param file \code{[character]} file to run.
#'
#'
#' @export
run <- function(file){
  fname <- basename(file)
  dname <- dirname(file)
  oldwd <- getwd()
  on.exit(setwd(oldwd))
  setwd(dname)


  envir=new.env(parent=.GlobalEnv)

  store <- new.env()
  
  envir$start_log <- log_capture(store)
  envir$dump_log  <- dump_capture(store)

  prog <- parse(fname)
 
  for ( i in seq_along(prog) ){
    eval(prog[[i]], envir=envir)
    update_loggers(store, envir, prog[[i]])
  }

  rm(list=c("start_log","dump_log"), envir=envir)
  envir
}
