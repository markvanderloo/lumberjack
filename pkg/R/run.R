# get names of loggers
get_loggers <- function(store, dataset) ls(store[[dataset]], pattern="^logger")


# store: environment to store data and logger.
#
# store$dataset$data
#              $logger001
#              $logger002
log_capture <- function(store){
    function(data, logger){
      dataset <- as.character(substitute(data))
      if (!dataset %in% ls(store)){ 
        store[[dataset]] <- new.env()
        store[[dataset]]$data <- data
      } 
      loggers   <- get_loggers(store, dataset)
      newlogger <- sprintf("logger%03d", length(loggers)+1)
      store[[dataset]][[newlogger]] <- logger
      invisible(data)
    }
}

dump_capture <- function(store){
  function(data=NULL, loggers = NULL, stop=TRUE, ...){ 

    if (is.null(data) && is.null(loggers)){ 
      # dump all loggers for all datasets
      for (dataset in ls(store)){
        loggers <- get_loggers(store, dataset)
        for (logger in loggers){
          store[[dataset]][[logger]]$dump(...)
          if (stop) rm(list = logger, envir = store[[dataset]])
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


    if ( is.null(loggers) ){
      # dump all loggers for the current dataset
      loggers <- get_loggers(store, dataset)
      for (logger in loggers){
        store[[dataset]][[logger]]$dump(...)
        if (stop) rm(list=logger, envir = store[[dataset]])
      }
      return(invisible(data))
    }

    if (is.character(loggers)){
      for (logger in loggers){
        if ( is.null(store[[dataset]][[logger]]) ){
          warnf("Logger '%s' not found for dataset '%s'", logger, dataset)
          next
        }
        store[[dataset]][[logger]]$dump(...)
        if (stop) rm(list=logger, envir=store[[dataset]])
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
    loggers <- ls(store[[dataset]], pattern="^logger")
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

