# The functions in this file are all internal.

# Determine if a set of parameters is within the bounds.
checkBounds <- function(tab, bounds) {
  return(
    sapply(
      names(bounds),
      function(paramName) {
        tab[[paramName]] >= bounds[[paramName]][[1]] &
          tab[[paramName]] <= bounds[[paramName]][[2]]
      }
    )
  )
}

# Draw random parameters with LHS
randParams <- function(boundsDT, rPoints, FAIL = TRUE) {
  # Attempt to procure rPoints unique parameter sets by lhs.
  attempt <- 1
  newPars <- data.table()
  poi <- rPoints

  while (attempt <= 100) {
    latinCube <- data.table(lhs::improvedLHS(n = poi, k = nrow(boundsDT)))

    setnames(latinCube, boundsDT$N)

    newPars <- unique(rbind(unMMScale(latinCube, boundsDT), newPars))

    if (nrow(newPars) == rPoints) {
      break
    } else {
      poi <- rPoints - nrow(newPars)
    }

    if (attempt >= 100 && FAIL) {
      cli::cli_abort(c(
        "Latin Hypercube Sampling could not produce the required distinct parameter sets.",
        i = "Try decreasing {.arg gsPoints} or {.arg initPoints}."
      ))
    }

    attempt <- attempt + 1
  }

  setnames(newPars, boundsDT$N)
  return(newPars)
}

# Scale parameters to 0-1 between their bounds.
minMaxScale <- function(tabl, boundsDT) {
  # tabl <- newD

  mms <- lapply(boundsDT$N, function(x) {
    (tabl[[x]] - boundsDT[get("N") == x, ]$L) / boundsDT[get("N") == x, ]$R
  })

  setDT(mms)
  setnames(mms, boundsDT$N)
  return(mms)
}

# Do the reverse of minMaxScale
unMMScale <- function(tabl, boundsDT) {
  umms <- lapply(boundsDT$N, function(x) {
    B <- boundsDT[get("N") == x, ]

    n <- tabl[[x]] * B$R + B$L

    if (B$C == "integer") {
      n <- round(n)
    }

    return(n)
  })

  setDT(umms)
  if (!identical(names(tabl), boundsDT$N)) {
    umms <- cbind(umms, tabl[, -boundsDT$N, with = FALSE])
  }
  setnames(umms, names(tabl))
  return(umms)
}

# Scale a vector between 0-1
zeroOneScale <- function(vec) {
  r <- max(vec) - min(vec)

  # If the scoring function returned the same results
  # this results in the function a vector of 1s.
  if (r == 0) {
    cli::cli_abort("Results from {.fn FUN} have 0 variance, cannot build GP.")
  }

  vec <- (vec - min(vec)) / r

  return(vec)
}

# Check to see if any rows from tab1 are exact duplicates of rows in tab2.
checkDup <- function(tab1, tab2) {
  sapply(seq_len(nrow(tab1)), function(i) {
    tab2 <- rbind(tab2, tab1[0:(i - 1), ])
    nrow(fintersect(tab2, tab1[i, ])) > 0
  })
}

# Return a data.table from a bounds list. Easier to work with.
boundsToDT <- function(bounds) {
  data.table(
    N = names(bounds),
    L = sapply(bounds, function(x) x[1]),
    U = sapply(bounds, function(x) x[2]),
    R = sapply(bounds, function(x) x[2]) - sapply(bounds, function(x) x[1]),
    C = sapply(bounds, function(x) class(x))
  )
}

# Attempt to save bayesOpt object between optimization steps.
saveSoFar <- function(optObj, verbose) {
  if (!is.null(optObj$saveFile)) {
    tryCatch(
      {
        suppressWarnings(saveRDS(optObj, file = optObj$saveFile))
        if (verbose > 0) {
          cli::cli_inform(c(
            " " = "4) Saved intermediary results to {.file {optObj$saveFile}}."
          ))
        }
      },
      error = function(e) {
        if (verbose > 0) {
          cli::cli_inform(c(
            x = "4) Failed to save intermediary results. Please check file path."
          ))
        }
      }
    )
  }
}

# Cannot pass `%dopar%` so we recreate it with this function.
ParMethod <- function(x) {
  if (x) {
    `%dopar%`
  } else {
    `%do%`
  }
}

# Get information about the acquisition functions.
getAcqInfo <- function(acq) {
  return(
    data.table(
      nam = c("ei", "eips", "poi", "ucb"),
      disp = c(
        "Expected Improvement",
        "Expct. Imprvmt./Second",
        "Prob. of Improvement",
        "Upper Conf. Bound"
      ),
      base = c(0, 0, 0, 1)
    )[get("nam") == acq, ]
  )
}

# Early checks for parameters.
checkParameters <- function(
  bounds,
  iters.n,
  iters.k,
  otherHalting,
  acq,
  acqThresh,
  errorHandling,
  plotProgress,
  parallel,
  verbose,
  call = rlang::caller_env()
) {
  if (iters.n < iters.k) {
    cli::cli_abort(
      c(
        "{.arg iters.n} cannot be less than {.arg iters.k}.",
        i = "See {.help [?bayesOpt](ParBayesianOptimization::bayesOpt)} for parameter definitions."
      ),
      call = call
    )
  }
  if (iters.n %% 1 != 0 || iters.k %% 1 != 0) {
    cli::cli_abort(
      "{.arg iters.n} and {.arg iters.k} must be integers.",
      call = call
    )
  }
  if (
    !is.character(acq) ||
      length(acq) != 1 ||
      !acq %in% c("ucb", "ei", "eips", "poi")
  ) {
    cli::cli_abort(
      c(
        "Acquisition function not recognized.",
        i = "{.arg acq} must be one of {.or {.val {c('ucb', 'ei', 'eips', 'poi')}}}."
      ),
      call = call
    )
  }
  if (parallel && (getDoParWorkers() == 1)) {
    cli::cli_abort(
      "{.arg parallel} is set to TRUE but no back end is registered.",
      call = call
    )
  }
  if (!parallel && getDoParWorkers() > 1 && verbose > 0) {
    cli::cli_inform(
      "A parallel back end is registered, but {.arg parallel} is FALSE. Process will not be run in parallel."
    )
  }
  if (!all(names(otherHalting) %in% c("timeLimit", "minUtility"))) {
    cli::cli_abort(
      c(
        "{.arg otherHalting} element not recognized.",
        i = "Must be one of {.val timeLimit} and {.val minUtility}."
      ),
      call = call
    )
  }
  if (!inherits(x = bounds, what = "list")) {
    cli::cli_abort(
      "{.arg bounds} must be a list of parameter bounds with the same arguments as {.fn FUN}.",
      call = call
    )
  }
  if (any(lengths(bounds) != 2)) {
    cli::cli_abort(
      "Not all elements in {.arg bounds} are length 2.",
      call = call
    )
  }
  if (acqThresh > 1 || acqThresh < 0) {
    cli::cli_abort("{.arg acqThresh} must be in [0,1].", call = call)
  }
  if (!is.logical(plotProgress)) {
    cli::cli_abort("{.arg plotProgress} must be logical.", call = call)
  }
  if (!errorHandling %in% c("stop", "continue") && !is.numeric(errorHandling)) {
    cli::cli_abort(
      "{.arg errorHandling} is malformed: Must be one of {.val stop}, {.val continue}, or an integer.",
      call = call
    )
  }
}

# Arguments in ... are passed to DiceKriging::km(). Catch misspelled or
# unsupported names before FUN runs, instead of when the GP is fitted.
checkKmArgs <- function(..., call = rlang::caller_env()) {
  argNames <- names(list(...))
  if (is.null(argNames) && ...length() > 0) {
    argNames <- rep("", ...length())
  }
  # Match like R does: exact names first, then unique prefixes, each formal
  # at most once. updateGP() always sets design, response and control, so
  # they claim their formals first.
  kmArgs <- names(formals(DiceKriging::km))
  matched <- pmatch(c("design", "response", "control", argNames), kmArgs)
  unmatched <- is.na(matched[-(1:3)])
  # Names that match a formal only when it may be used twice collide with
  # another argument; the rest are not km() arguments at all.
  collides <- unmatched &
    !is.na(pmatch(argNames, kmArgs, duplicates.ok = TRUE)) &
    argNames != ""
  if (any(collides)) {
    cli::cli_abort(
      c(
        "Arguments in {.arg ...} match a {.fn DiceKriging::km} argument that is already supplied or set by {.fn updateGP} (design, response, control): {argNames[collides]}."
      ),
      call = call
    )
  }
  bad <- argNames[unmatched]
  if (length(bad) > 0) {
    bad[bad == ""] <- "<unnamed>"
    cli::cli_abort(
      c(
        "Arguments in {.arg ...} are passed to {.fn DiceKriging::km}, which does not accept: {bad}.",
        i = "Check for misspelled arguments."
      ),
      call = call
    )
  }
}

# Get the total time run of an object given the time it was started.
totalTime <- function(optObj, startT) {
  optObj$elapsedTime + as.numeric(difftime(Sys.time(), startT, units = "secs"))
}

# Fill in any missing elements of otherHalting we need.
formatOtherHalting <- function(otherHalting) {
  if (is.null(otherHalting$timeLimit)) {
    otherHalting$timeLimit <- Inf
  }
  if (is.null(otherHalting$minUtility)) {
    otherHalting$minUtility <- 0
  }
  return(otherHalting)
}

# Constructor for stopEarlyMsg class.
makeStopEarlyMessage <- function(msg) {
  class(msg) <- "stopEarlyMsg"
  return(msg)
}

# Multiple places the process can stop early. This just prints the message.
printStopStatus <- function(optObj, verbose) {
  if (verbose > 0) cli::cli_inform(c("!" = "{unclass(optObj$stopStatus)}"))
}

# Printed lines of a table. Messages built from them keep the table layout,
# which cli formatting would collapse.
tableLines <- function(tbl, ...) capture.output(print(tbl, ...))

# Combining function for foreach. Allows the return of message without scores.
rbindFE <- function(...) rbind(..., fill = TRUE)

# What to do if FUN produced errors?
getEarlyStoppingErrorStatus <- function(
  NewResults,
  scoreSummary,
  errorHandling,
  verbose
) {
  newErrors <- sum(!is.na(NewResults$errorMessage))
  allErrors <- newErrors + sum(!is.na(scoreSummary$errorMessage))
  if (errorHandling == "stop" && allErrors > 0) {
    return(makeStopEarlyMessage("Errors encountered in FUN"))
  } else if (errorHandling == "continue") {
    return("OK")
  } else if (errorHandling <= allErrors) {
    return(makeStopEarlyMessage("Errors from FUN exceeded errorHandling limit"))
  } else {
    return("OK")
  }
}
