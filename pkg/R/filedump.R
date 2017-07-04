
#' The file dumping logger.
#' 
#' The file dumping logger dumps the most recent version of a dataset to csv 
#' in a directory of choice. 
#' 
#' @section Creating a logger:
#' 
#' \code{filedump$new(dir=file.path(tempdir(),"log"), prefix="step\%03d.csv", verbose=TRUE)}
#' \tabular{ll}{
#'   \code{dir}\tab Where to write the file dumps.\cr
#'   \code{filename}\tab filename template, used with \code{\link{sprintf}} 
#'      to create a file name.\cr
#'   \code{verbose}\tab toggle verbosity
#' }
#' 
#' @section Dump options: 
#' 
#' \code{$dump(...)}
#' \tabular{ll}{
#'   \code{...}\tab Currently unused.\cr
#' }
#' 
#' @section Retrieve log data
#'
#' \code{$logdata()} returns a list of data frames, sorted in the order returned by
#'  \code{base::dir()}
#'  
#' @section Details:
#' 
#' If \code{dir} does not exist it is created. If 
#' 
#' 
#' @docType class
#' @format An \code{R6} class object.
#' 
#' 
#' 
#' @family loggers
#' @export
filedump <- R6Class("filedump"
  , public=list(
    n = NULL
    , dir = NULL
    , verbose = NULL
    , filename = NULL
    , initialize = function(dir = file.path(tempdir(), "timber")
       , filename="step%03d.csv", verbose = TRUE){
      self$n <- 0
      self$dir <- dir
      if (!dir.exists(dir)){
        dir.create(dir,recursive = TRUE)
        if (verbose){
          msgf("Created %s", normalizePath(dir))
        }
      }
      self$verbose <- verbose
      self$filename <- filename
    }
    , add = function(meta, input, output){
        outname <- file.path(self$dir,sprintf(self$filename,self$n))
        if (self$n == 0)
          write.csv(input, file=outname, row.names=FALSE)
        self$n <- self$n + 1
        outname <- file.path(self$dir,sprintf(self$filename,self$n))
        write.csv(output, file=outname, row.names=FALSE)
    }
    , dump = function(...){
        if ( self$verbose ){
          msgf("Filedumps were written to %s", normalizePath(self$dir))
        }
    }
   , log.data = function(){
       # this crashes covr
       # if (!dir.exists(self$dir)){
       #   stopf("The directory %s does not exist.",self$dir)
       # }
       fl <- dir(self$dir,full.names = TRUE)
       lapply(fl, read.csv)
    }
))


