
msgf <- function(fmt,...){
  message(sprintf(fmt,...))
}

stopf <- function(fmt,...){
  stop(sprintf(fmt,...), call. = FALSE)
}

warnf <- function(fmt, ...){
  warning(sprintf(fmt, ...), call.=FALSE)
}

get_srcref <- function(meta){
  if (is.null(meta$file)) return(NA_character_)
  
  sprintf("%s#%d-%d", meta$file, meta$line[1], meta$line[2])
  
}


replace <- function(call, match, sub){
  if (length(call) == 1){
    if ( identical(call,match) ){
      return(sub)
    } else {
      return(call)
    }
    # Skip formulas. We treat them as literals.
  } else if (call[[1]] != "~") {
    for ( i in seq_along(call)[-1] ){
      call[[i]] <- replace(call[[i]], match, sub)
    }
  }
  call
}


# the pipe action.
pipe <- function(x, y, env=sys.parent()){
  
  e <- new.env(parent=env)
  e$. <- x
  
  if ( inherits(y,"call") ){
    y1 <- replace(y, quote(.), quote(x))
    uses_dot <- !identical(y,y1)

    if (uses_dot){
      eval(y, envir=e)
    } else {
      w <- as.list(y1)
      y1 <- as.call(c(w[1],quote(.),w[-1]))
      eval(y1, envir=e)
    }
  } else {
    eval(y, envir = e)
  }
     
    
}

