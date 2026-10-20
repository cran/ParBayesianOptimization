#' Plot a \code{bayesOpt} object
#'
#' Returns 2 stacked plots - the top shows the results from FUN at each iteration.
#' The bottom shows the utility from each point before the search took place.
#'
#' @param x An object of class bayesOpt
#' @param ... Passed to \code{patchwork::plot_layout()}, overriding the
#'   defaults \code{ncol = 1} and \code{guides = "collect"}.
#' @importFrom ggplot2 ggplot aes .data xlab scale_color_discrete geom_point theme guides guide_legend margin element_text unit xlim ylab
#' @importFrom patchwork plot_layout plot_annotation
#' @importFrom graphics plot
#' @return A \code{patchwork} object, returned invisibly after printing.
#' @examples
#' scoringFunction <- function(x) {
#'   a <- exp(-(2-x)^2)*1.5
#'   b <- exp(-(4-x)^2)*2
#'   c <- exp(-(6-x)^2)*1
#'   return(list(Score = a+b+c))
#' }
#'
#' bounds <- list(x = c(0,8))
#'
#' Results <- bayesOpt(
#'     FUN = scoringFunction
#'   , bounds = bounds
#'   , initPoints = 3
#'   , iters.n = 2
#'   , gsPoints = 10
#' )
#' # This plot will also show in real time with parameter plotProgress = TRUE in bayesOpt()
#' plot(Results)
#' @export
plot.bayesOpt <- function(x, ...) {
  acqN <- getAcqInfo(x$optPars$acq)
  scoreSummary <- x$scoreSummary[!is.na(get("Score")), ]

  # Score Plot
  sc <- ggplot(
    scoreSummary,
    aes(x = .data$Epoch, y = .data$Score, color = .data$acqOptimum)
  ) +
    geom_point() +
    xlab("") +
    scale_color_discrete(drop = TRUE, limits = c(TRUE, FALSE)) +
    theme(
      legend.position = 'bottom',
      legend.spacing.x = unit(0.6, 'cm'),
      legend.text = element_text(margin = margin(t = 1)),
      legend.margin = margin(t = 0, b = 10),
      plot.margin = unit(c(1, 1, 0, 0), units = "line")
    ) +
    guides(
      color = guide_legend(
        title = "Local\nOptimum",
        label.position = "bottom",
        title.position = "left",
        title.hjust = 1
      )
    )

  # Utility Plot
  ut <- ggplot(
    scoreSummary[!is.na(get("gpUtility")), ],
    aes(x = .data$Epoch, y = .data$gpUtility, color = .data$acqOptimum)
  ) +
    geom_point() +
    xlim(c(0, max(scoreSummary$Epoch))) +
    ylab("Utility") +
    scale_color_discrete(drop = TRUE, limits = c(TRUE, FALSE)) +
    theme(
      legend.position = 'bottom',
      legend.spacing.x = unit(0.6, 'cm'),
      legend.text = element_text(margin = margin(t = 1)),
      legend.margin = margin(t = 0, b = 10),
      plot.margin = unit(c(0, 1, 1, 0), units = "line")
    ) +
    guides(
      color = guide_legend(
        title = "Local\nOptimum",
        label.position = "bottom",
        title.position = "left",
        title.hjust = 1
      )
    )

  # Arguments in ... override the layout defaults; unnamed ones are kept and
  # abbreviated names count as the plot_layout() argument they match.
  layoutArgs <- list(...)
  given <- names(formals(plot_layout))[
    pmatch(names(layoutArgs), names(formals(plot_layout)))
  ]
  defaults <- list(ncol = 1, guides = "collect")
  defaults <- defaults[setdiff(names(defaults), given)]

  p <- (sc / ut) +
    do.call(plot_layout, c(defaults, layoutArgs)) +
    plot_annotation(
      title = "Bayesian Optimization Results",
      theme = theme(plot.title = element_text(hjust = 0.5))
    ) &
    theme(legend.position = "bottom")

  print(p)
}
