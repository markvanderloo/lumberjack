

# store: environment to store data and logger.
log_capture <- function(store){
    function(data, logger){
      store$dataname <- as.character(substitute(data))
      store$data <- data
      store$logger <- logger
      start_log(data, logger)
    }
}

dump_capture <- function(store){
  function(...) store$logger$dump(...)
}


#' Run a file with loggers enabled.
#'
#' @param file \code{[character]} file to run.
#'
#'
#' @export
run <- function(file, envir=new.env(), parent=.GlobalEnv){
  # Environment to capture copy of data and logger.
  store <- new.env()
  

  envir$start_log <- log_capture(store)
  envir$dump_log  <- dump_capture(store)


  # parse expressions
  prog <- parse(file)
  for ( i in seq_along(prog) ){
    old <- if (is.null(store$data)) NULL else store$data
    eval(prog[[i]], envir=envir)
    if (!is.null(store$data) && !is.null(old) ){
      new <- get(store$dataname, envir)
      L <- list(expr = prog[[i]]
              , src=paste0(capture.output(print(prog[[i]])), collapse="\n") 
            )        
      store$logger$add(meta=L, input=old, output=new)
      store$data <- new
    }
  }

  envir$start_log <- NULL
  envir$dump_log  <- NULL
  envir
}

