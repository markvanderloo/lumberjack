
#' The file dumping logger.
#' 
#' The file dumping logger dumps the most recent version of a dataset to csv in
#' a directory of choice. 
#' 
#' @section Creating a logger:
#' 
#' \code{filedump$new(dir=file.path(tempdir(),"filedump"), filename="\%sstep\%03d.csv",verbose=TRUE)}
#' \tabular{ll}{
#'   \code{dir}\tab \code{[character]} Directory location to write the file dumps.\cr
#'   \code{filename}\tab \code{[character]} Template, used to create file names.
#'                       to create a file name.\cr
#'   \code{verbose}\tab \code{[logical]} toggle verbosity.
#' }
#' 
#' File locations are created with \code{file.path(dir, file)}, where
#' \code{file} is generated as \code{sprintf(filename, DATA, STEP)}. In
#' interactive sessions \code{DATA=""}. In sessions where a script is executed
#' using \code{\link{run_file}}, \code{DATA} is the name of the R object being
#' tracked or the \code{label} provided with \code{\link{start_log}}.
#' \code{STEP} is a counter that increases at each dump.
#'
#' @section Dump options: 
#' 
#' \code{$dump(...)}
#' \tabular{ll}{
#'   \code{...}\tab Currently unused.\cr
#' }
#' 
#' @section Retrieve log data:
#'
#' \code{$logdata()} returns a list of data frames, sorted in the order returned by
#'  \code{base::dir()}
#'  
#' @section Details:
#' 
#' If \code{dir} does not exist it is created. 
#' 
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' @examples
#' logger <- filedump$new()
#'
#' out <- women %L>%
#'   start_log(logger) %L>%
#'   within(height <- height * 2) %L>%
#'   within(height <- height * 3) %L>%
#'   dump_log()
#' dir(file.path(tempdir(),"filedump"))
#'
#' 
#' @family loggers
#' @export
filedump <- R6Class("filedump"
  , private=list(
      n = NULL
      , dir = NULL
      , verbose = NULL
      , filename = NULL
    )
  , public = list(
        label=NULL
      , initialize = function(dir = file.path(tempdir(),"filedump")
         , filename="%sstep%03d.csv", verbose = TRUE){
          private$n <- 0
          private$dir <- dir
          if (!dir.exists(dir)){
            dir.create(dir,recursive = TRUE)
            if (verbose){
              msgf("Created %s", normalizePath(dir))
            }
          }
          private$verbose <- verbose
          private$filename <- filename
        }
    , add = function(meta, input, output){
        prefix <- if (is.null(self$label)) "" else paste0(self$label,"_")
        outname <- file.path(private$dir, sprintf(private$filename, prefix, private$n))
        if (private$n == 0)
          write.csv(input, file=outname, row.names=FALSE)
        private$n <- private$n + 1
        outname <- file.path(private$dir, sprintf(private$filename, prefix, private$n))
        write.csv(output, file=outname, row.names=FALSE)
    }
    , dump = function(...){
        
        if ( private$verbose ){
          msgf("Filedumps were written to %s", normalizePath(private$dir))
        }
    }
   , logdata = function(){
       # this crashes covr
       # if (!dir.exists(private$dir)){
       #   stopf("The directory %s does not exist.",private$dir)
       # }
       fl <- dir(private$dir,full.names = TRUE)
       lapply(fl, read.csv)
    }
))


