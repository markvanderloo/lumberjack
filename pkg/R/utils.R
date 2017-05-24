
msgf <- function(fmt,...){
  message(sprintf(fmt,...))
}


# expression to character
as_character <- function(x){
  paste0(capture.output(print(x[[1]])), collapse="\n")
}


replace <- function(call, match, sub){
  if (length(call) == 1){
    if ( identical(call,match) ){
      return(sub)
    } else {
      return(call)
    }
  } else {
    for ( i in seq_along(call)[-1] ){
      call[[i]] <- replace(call[[i]], match, sub)
    }
  }
  call
}



# the pipe action.
pipe <- function(x, y, env=sys.parent()){
  y <- replace(y, quote(.), quote(x))
  if ( class(y) == "call" ){
    L <- as.list(y)
    args <- append(list(x), L[-1])
    for (i in seq_along(args)[-1]){
      args[[i]] <- eval(args[[i]],envir=env)
    } 
    # deparse-parse-eval to resolve possible ::
    fun <- eval(parse(text=deparse(L[[1]])))
    do.call(fun,args)
  } else if (class(y) %in% c("(","{")) {
    e <- new.env()
    e$x <- x
    eval(y, envir=e)
  }
}

