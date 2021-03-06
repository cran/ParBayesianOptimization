#' Print a \code{bayesOpt} object
#'
#' @rdname print
#' @param x Object of class \code{bayesOpt}
#' @param ... required to use S3 method
#' @return \code{NULL}
#' @method print bayesOpt
#' @export
print.bayesOpt <- function(x,...) {
  acqN <- getAcqInfo(x$optPars$acq)
  spac <- nchar(acqN$disp) + nchar("Final ")
  cat("Class: bayesOpt\n\n")
  cat(rep(" ",spac-6),"Epochs: ",max(x$scoreSummary$Epoch),"\n",sep="")
  cat(rep(" ",spac-10),"Iterations: ",max(x$scoreSummary$Iteration),"\n",sep="")
  cat(rep(" ",spac-19),"Average FUN Seconds: ",round(mean(x$scoreSummary$Elapsed),2),"\n",sep="")
  cat(rep(" ",spac-19),"Highest FUN Seconds: ",round(max(x$scoreSummary$Elapsed),2),"\n",sep="")
  gpUtil <- max(x$scoreSummary[get("Epoch") == max(get("Epoch"))]$gpUtility)
  cat("Final ",acqN$disp,": ",gpUtil,"\n",sep="")
  cat(rep(" ",spac-10),"GP Updated: ",x$GauProList$gpUpToDate,"\n",sep="")
  ss <- if (x$stopStatus == "OK") "OK" else "Stopped Early. See $stopStatus"
  cat(rep(" ",spac-11),"Stop Status: ",ss,"\n",sep="")
  invisible(x)
}
