#' Performs DDF detection using Multinomial Log-linear Regression model.
#'
#' @aliases ddfMLR print.ddfMLR plot.ddfMR
#'
#' @description Performs DDF detection procedure based on Multinomial Log-linear Regression model and
#' likelihood ratio test of submodel.
#'
#' @param Data character: either the unscored data matrix only, or the unscored data
#' matrix plus the vector of group. See \strong{Details}.
#' @param group numeric or character: either the binary vector of group membership or
#' the column indicator of group membership. See \strong{Details}.
#' @param focal.name numeric or character: indicated the level of \code{group} which corresponds to
#' focal group
#' @param key character: the answer key. See \strong{Details}.
#' @param type character: type of DIF to be tested (either "both" (default), "udif", or "nudif").
#' See \strong{Details}.
#' @param p.adjust.method character: method for multiple comparison correction.
#' See \strong{Details}.
#' @param alpha numeric: significance level (default is 0.05).
#' @param x an object of 'ddfMLR' class
#' @param item either character ("all"), or numeric vector, or single number
#'corresponding to column indicators. See \strong{Details}.
#' @param title string: title of plot.
#' @param ... other generic parameters for \code{print} or \code{plot} functions.
#'
#' @usage ddfMLR(Data, group, focal.name, key, type = "both",
#' alpha = 0.05, p.adjust.method = "none")
#'
#' @details
#' DDF detection procedure based on Multinomial Log-linear model.
#'
#' The \code{Data} is a matrix whose rows represents examinee unscored answers and
#' columns correspond to the items. The \code{group} must be either a vector of the same
#' length as \code{nrow(data)} or column indicator of \code{Data}. The \code{key} must be
#' a vector of correct answers corresponding to columns of \code{Data}.
#'
#' The \code{type} corresponds to type of DIF to be tested. Possible values are \code{"both"}
#' to detect any DIF (uniform and/or non-uniform), \code{"udif"} to detect only uniform DIF or
#' \code{"nudif"} to detect only non-uniform DIF.
#'
#' The \code{p.adjust.method} is a character for \code{p.adjust} function from the
#' \code{stats} package. Possible values are \code{"holm"}, \code{"hochberg"},
#' \code{"hommel"}, \code{"bonferroni"}, \code{"BH"}, \code{"BY"}, \code{"fdr"}, \code{"none"}.
#'
#' The output of the ddfMLR is displayed by the \code{print.ddfMLR} function.
#'
#' The characteristic curve for item specified in \code{item} option can be plotted. For default
#' option \code{"all"} of item, characteristic curves of all converged items are plotted.
#' The drawn curves represent best model.
#'
#' Fitted values are extracted by the \code{fitted.difNLR} function for item(s) specified in
#' \code{item} argument.
#'
#' Predicted values are produced by the \code{predict.difNLR} function for item(s) specified in
#' \code{item} argument. \code{score} represents standardized total score of new subject and
#' \code{group} argument represents group membership of new subject.
#'
#' Missing values are allowed but discarded for item estimation. They must be coded as \code{NA}
#' for both, \code{data} and \code{group} parameters.
#'
#' @return A list of class 'difNLR' with the following arguments:
#' \describe{
#'   \item{\code{Sval}}{the values of likelihood ratio test statistics.}
#'   \item{\code{nlrPAR}}{the estimates of final model.}
#'   \item{\code{parM0}}{the estimates of null model.}
#'   \item{\code{parM1}}{the estimates of alternative model.}
#'   \item{\code{alpha}}{numeric: significance level.}
#'   \item{\code{DDFitems}}{either the column indicators of the items which were detected as DDF, or \code{"No DDF item detected"}.}
#'   \item{\code{type}}{character: type of DIF that was tested.}
#'   \item{\code{p.adjust.method}}{character: method for multiple comparison correction which was applied.}
#'   \item{\code{pval}}{the p-values by likelihood ratio test.}
#'   \item{\code{adj.pval}}{the adjusted p-values by likelihood ratio test using \code{p.adjust.method}.}
#'   \item{\code{df}}{the degress of freedom of likelihood ratio test.}
#'   \item{\code{group}}{the vector of group membership.}
#'   \item{\code{Data}}{the data matrix.}
#'   }
#'
#' @author
#' Adela Drabinova \cr
#' Institute of Computer Science, The Czech Academy of Sciences \cr
#' Faculty of Mathematics and Physics, Charles University \cr
#' adela.drabinova@gmail.com \cr
#'
#' Patricia Martinkova \cr
#' Institute of Computer Science, The Czech Academy of Sciences \cr
#'
#' @seealso \code{\link[stats]{p.adjust}}
#'
#' @examples
#' \dontrun{
#' # loading data based on GMAT
#' data(GMATtest, GMATkey)
#'
#' Data  <- GMATtest[, colnames(GMATtest) != "group"]
#' group <- GMATtest[, "group"]
#' key <- GMATkey
#'
#' # Testing both DIF effects
#' x <- ddfMLR(Data, group, focal.name = 1, key)
#'
#' # Testing both DIF effects with Benjamini-Hochberg adjustment method
#' ddfMLR(Data, group, focal.name = 1, key, type = "both", p.adjust.method = "BH")
#'
#' # Testing uniform DIF effects
#' ddfMLR(Data, group, focal.name = 1, key, type = "udif")
#' # Testing non-uniform DIF effects
#' ddfMLR(Data, group, focal.name = 1, key, type = "nudif")
#'
#' # Graphical devices
#' plot(x, item = 1)
#' plot(x, item = x$DDFitems)
#' plot(x, item = "all")
#' }
#' @keywords DDF
#' @export
#' @importFrom reshape2 melt
#' @importFrom stats relevel

ddfMLR <- function(Data, group, focal.name, key, type = "both",
                alpha = 0.05,
                p.adjust.method = "none")
{
  if (!type %in% c("udif", "nudif", "both") | !is.character(type))
    stop("'type' must be either 'udif', 'nudif' or 'both'",
         call. = FALSE)
  if (alpha > 1 | alpha < 0)
    stop("'alpha' must be between 0 and 1",
         call. = FALSE)
  internalMLR <- function() {
    if (length(group) == 1) {
      if (is.numeric(group)) {
        GROUP <- Data[, group]
        DATA <- Data[, (1:ncol(Data)) != group]
        colnames(DATA) <- colnames(Data)[(1:ncol(Data)) !=  group]
      } else {
        GROUP <- Data[, colnames(Data) == group]
        DATA <- Data[, colnames(Data) != group]
        colnames(DATA) <- colnames(Data)[colnames(Data) !=  group]
      }
    } else {
      GROUP <- group
      DATA <- Data
    }
    if (length(levels(as.factor(GROUP))) != 2)
      stop("'group' must be binary vector", call. = FALSE)
    if (is.matrix(DATA) | is.data.frame(DATA)) {
      if (nrow(DATA) != length(GROUP))
        stop("'Data' must have the same number of rows as is length of vector 'group'",
             call. = FALSE)
    } else {
      stop("'Data' must be data frame or matrix of binary vectors",
           call. = FALSE)
    }
    if (length(key) != ncol(DATA)){
      stop("Number of items in 'Data' is not equal to the length of 'key'.",
           call. = FALSE)
    }

    GROUP <- as.numeric(as.factor(GROUP) == focal.name)

    PROV <- MLR(DATA, GROUP, key = key, type = type,
                p.adjust.method = p.adjust.method,
                alpha = alpha)
    STATS <- PROV$Sval
    ADJ.PVAL <- PROV$adjusted.pval
    significant <- which(ADJ.PVAL < alpha)
    if (length(significant) > 0) {
      DDFitems <- significant
      nlrPAR <- PROV$par.m1
      # nlrSE <- PROV$se.m1
      for (idif in 1:length(DDFitems)) {
        nlrPAR[[DDFitems[idif]]] <- PROV$par.m0[[DDFitems[idif]]]
        # nlrSE[[DDFitems[idif]]] <- PROV$se.m0[[DDFitems[idif]]]
      }

      # colnames(nlrPAR) <- colnames(nlrSE) <- switch(type,
      #                                               "both" = c("a", "b", "c", "aDIF", "bDIF"),
      #                                               "nudif" = c("a", "b", "c", "aDIF", "bDIF"),
      #                                                "udif" = c("a", "b", "c", "bDIF"))
      } else {
        DDFitems <- "No DDF item detected"
        nlrPAR <- PROV$par.m1
        # nlrSE <- PROV$se.m1
      }


    RES <- list(Sval = STATS,
                nlrPAR = nlrPAR,
                # nlrSE = nlrSE,
                parM0 = PROV$par.m0,
                # seM0 = PROV$se.m0, covM0 = PROV$cov.m0,
                parM1 = PROV$par.m1,
                # seM1 = PROV$se.m1, covM1 = PROV$cov.m1,
                alpha = alpha, DDFitems = DDFitems,
                type = type, p.adjust.method = p.adjust.method,
                pval = PROV$pval, adj.pval = PROV$adjusted.pval, df = PROV$df,
                adjusted.p = NULL,
                group = GROUP, Data = DATA, key = key)

    class(RES) <- "ddfMLR"
    return(RES)
  }
  resToReturn <- internalMLR()
  return(resToReturn)
}


#' @rdname ddfMLR
#' @export
print.ddfMLR <- function (x, ...){
  title <- switch(x$type,
                  both = "Detection of both types of Distractor Differential Functioning using Logistic Regression method",
                  udif = "Detection of uniform Distractor Differential Functioning using Logistic Regression method",
                  nudif = "Detection of non-uniform Distractor Differential Functioning using Logistic Regression method")
  cat(paste(strwrap(title, width = 60), collapse = "\n"))
  cat("\n\nLikelihood-ratio chi-square statistics\n")
  if (x$p.adjust.method == "none") {
    cat("No p-value adjustment for multiple comparisons\n\n")
  }
  else {
    cat(paste("Multiple comparisons made with",
              switch(x$p.adjust.method,
                     holm = "Holm", hochberg = "Hochberg", hommel = "Hommel",
                     bonferroni = "Bonferroni", BH = "Benjamini-Hochberg",
                     BY = "Benjamini-Yekutieli", fdr = "FDR"), "adjustment of p-values\n\n"))
  }
  sign <- ifelse(is.na(x$adj.pval), " ",
                 ifelse(x$adj.pval < 0.001, "***",
                        ifelse(x$adj.pval < 0.01, "**",
                               ifelse(x$adj.pval < 0.05, "*",
                                      ifelse(x$adj.pval < 0.1, ".", " ")))))
  if (x$p.adjust.method == "none"){
    tab <- format(round(cbind(x$Sval, x$pval), 4))
    tab <- matrix(cbind(tab, sign), ncol = 3)
    colnames(tab) <- c("Chisq-value", "P-value", "")
  } else {
    tab <- format(round(cbind(x$Sval, x$pval, x$adj.pval), 4))
    tab <- matrix(cbind(tab, sign), ncol = 4)
    colnames(tab) <- c("Chisq-value", "P-value", "Adj. P-value", "")
  }

  rownames(tab) <- paste("Item", 1:length(x$adj.pval))

  print(tab, quote = F, digits = 4, zero.print = F)
  cat("\nSignif. codes: 0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1\n")

  # critical <- ifelse(x$test == "F", qf(1 - x$alpha, x$df[1], x$df[2]), qchisq(1 - x$alpha, x$df))
  # cat(paste("\nDetection thresholds: ", round(critical, 4), " (significance level: ", x$alpha, ")", sep = ""))
  if (is.character(x$DIFitems)) {
    switch(x$type, both = cat("\nNone of items is detected as DDF"),
           udif = cat("\nNone of items is detected as uniform DDF"),
           nudif = cat("\nNone of items is detected as non-uniform DDF"))
  }
  else {
    switch(x$type, both = cat("\n\nItems detected as DDF items:"),
           udif = cat("\n\nItems detected as uniform DDF items:"),
           nudif = cat("\n\nItems detected as non-uniform DDF items:"))
    cat("\n", paste("Item ", x$DIF, "\n", sep = ""))
  }
}




#' @rdname ddfMLR
#' @export
plot.ddfMLR <- function(x, item = "all", title, ...){
  m <- length(x$nlrPAR)
  if (class(item) == "character"){
    if (item != "all")
      stop("'item' must be either numeric vector or character string 'all' ",
           call. = FALSE)
  } else {
    if (class(item) != "integer" & class(item) != "numeric")
      stop("'item' must be either numeric vector or character string 'all' ",
           call. = FALSE)
  }
  if (class(item) == "numeric" & !all(item %in% 1:m))
    stop("invalid number of 'item'",
         call. = FALSE)
  if (class(item) == "integer" & !all(item %in% 1:m))
    stop("'item' must be either numeric vector or character string 'all' ",
         call. = FALSE)

  if (class(item) == "character"){
    items <- 1:m
  } else {
    items <- item
  }

  if (!missing(title)){
    TITLE <- title
  } else {
    TITLE <- paste("Item", i)
  }

  score <- scale(unlist(score(x$Data, x$key)))
  sq <- seq(min(score), max(score), by = 0.1)
  sqR <- as.matrix(data.frame(1, sq, 0, 0))
  sqF <- as.matrix(data.frame(1, sq, 1, sq))
  plot_CC <- list()
  for (i in items){

    if(ncol(x$nlrPAR[[i]]) == 2)
      x$nlrPAR[[i]] <- as.matrix(data.frame(x$nlrPAR[[i]], 0, 0))
    prR <- prF <- c()
    for (j in 1:nrow(x$nlrPAR[[i]])){

      prR <- rbind(prR, exp(x$nlrPAR[[i]][j, ] %*% t(sqR)))
      prF <- rbind(prF, exp(x$nlrPAR[[i]][j, ] %*% t(sqF)))
    }

    prR <- as.data.frame(t(prR)); prF <- as.data.frame(t(prF))
    colnames(prR) <- colnames(prF) <- rownames(x$nlrPAR[[i]])
    prR$sum <- apply(prR, 1, sum) + 1; prF$sum <- apply(prF, 1, sum) + 1

    for (j in 1:nrow(x$nlrPAR[[i]])){
      prR <- data.frame(prR, prR[, j]/prR[, "sum"])
      prF <- data.frame(prF, prF[, j]/prF[, "sum"])
    }

    hvR <- data.frame(1 - apply(prR[, (nrow(x$nlrPAR[[i]])+2):ncol(prR)], 1, sum),
                      prR[, (nrow(x$nlrPAR[[i]])+2):ncol(prR)], "R")
    hvF <- data.frame(1 - apply(prF[, (nrow(x$nlrPAR[[i]])+2):ncol(prF)], 1, sum),
                      prF[, (nrow(x$nlrPAR[[i]])+2):ncol(prF)], "F")
    hvR <- data.frame(hvR, score = sq)
    hvF <- data.frame(hvF, score = sq)
    colnames(hvR) <- colnames(hvF) <- c(x$key[i], rownames(x$nlrPAR[[i]]), "group", "score")
    hv <- rbind(hvR, hvF)

    df <- melt(hv, id = c("score", "group"))
    df$group <- as.factor(df$group)

    df2 <- rbind(data.frame(prop.table(table(x$Data[x$group == 1, i], score[x$group == 1]), 2),
                            table(x$Data[x$group == 1, i], score[x$group == 1]),
                            group = "1"),
                 data.frame(prop.table(table(x$Data[x$group == 0, i], score[x$group == 0]), 2),
                            table(x$Data[x$group == 0, i], score[x$group == 0]),
                            group = "0"))

    df2$score <- as.numeric(levels(df2$Var2))[df2$Var2]
    df2$answ <- relevel(df2$Var1, ref = paste(x$key[i]))
    df2$group <- as.factor(df2$group)

    plot_CC[[i]] <-  ggplot() +
      geom_line(data = df,
                aes_string(x = "score" , y = "value",
                    colour = "variable", linetype = "group")) +
      geom_point(data = df2,
                 aes_string(x = "score", y = "Freq",
                     colour = "answ", fill = "answ",
                     size = "Freq.1"),
                 alpha = 0.5, shape = 21) +

      ylim(0, 1) +
      labs(title = paste("Item", i),
           x = "Standardized Total Score",
           y = "Probability of Correct Answer") +
      scale_linetype_discrete(name = "Group", labels = c("Reference", "Focal")) +
      scale_size_continuous(name = "Counts")  +
      scale_colour_discrete(name = "Answer", breaks = df2$answ) +
      scale_fill_discrete(guide = F) +

      theme_bw() +
      theme(axis.line  = element_line(colour = "black"),
            text = element_text(size = 14),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.background = element_blank(),
            legend.position = c(0, 1),
            legend.justification = c(0, 1),
            legend.background = element_blank(),
            legend.box = "horizontal",
            legend.key = element_rect(colour = "white"),
            plot.title = element_text(face = "bold"),
            legend.key.width = unit(1, "cm"))

  }

  return(plot_CC)
}