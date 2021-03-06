% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ORD.R
\name{ORD}
\alias{ORD}
\title{DIF likelihood ratio statistics for ordinal data.}
\usage{
ORD(Data, group, model = "adjacent", type = "both", match = "zscore",
    anchor = 1:ncol(Data), p.adjust.method = "none", parametrization = "irt",
    alpha = 0.05)
}
\arguments{
\item{Data}{data.frame or matrix: dataset which rows represent ordinaly scored examinee answers and
columns correspond to the items.}

\item{group}{numeric: binary vector of group membership. \code{"0"} for reference group, \code{"1"} for
focal group.}

\item{model}{character: logistic regression model for ordinal data (either \code{"adjacent"} (default) or \code{"cumulative"}).
See \strong{Details}.}

\item{type}{character: type of DIF to be tested. Either \code{"both"} for uniform and non-uniform
DIF (i.e., difference in parameters \code{"a"} and \code{"b"}) (default), or \code{"udif"} for
uniform DIF only (i.e., difference in difficulty parameter \code{"b"}), or \code{"nudif"} for
non-uniform DIF only (i.e., difference in discrimination parameter \code{"a"}). Can be specified
as a single value (for all items) or as an item-specific vector.}

\item{match}{numeric or character: matching criterion to be used as an estimate of trait. Can be
either \code{"zscore"} (default, standardized total score), \code{"score"} (total test score),
or vector of the same length as number of observations in \code{Data}.}

\item{anchor}{character or numeric: specification of DIF free items. A vector of item identifiers
(integers specifying the column  number) specifying which items are currently considered as anchor
(DIF free) items. Argument is ignored if \code{match} is not \code{"zscore"} or \code{"score"}.}

\item{p.adjust.method}{character: method for multiple comparison correction. Possible values are
\code{"holm"}, \code{"hochberg"}, \code{"hommel"}, \code{"bonferroni"}, \code{"BH"}, \code{"BY"},
\code{"fdr"}, and \code{"none"} (default). For more details see \code{\link[stats]{p.adjust}}.}

\item{parametrization}{character: parametrization of regression coefficients. Possible options are
\code{"irt"} for difficulty-discrimination parametrization (default) and \code{"classic"} for
intercept-slope parametrization. See \strong{Details}.}

\item{alpha}{numeric: significance level (default is 0.05).}
}
\value{
A list with the following arguments:
\describe{
  \item{\code{Sval}}{the values of likelihood ratio test statistics.}
  \item{\code{pval}}{the p-values by likelihood ratio test.}
  \item{\code{adj.pval}}{the adjusted p-values by likelihood ratio test using \code{p.adjust.method}.}
  \item{\code{df}}{the degress of freedom of likelihood ratio test.}
  \item{\code{par.m0}}{the estimates of null model.}
  \item{\code{par.m1}}{the estimates of alternative model.}
  \item{\code{se.m0}}{standard errors of parameters in null model.}
  \item{\code{se.m1}}{standard errors of parameters in alternative model.}
  \item{\code{ll.m0}}{log-likelihood of null model.}
  \item{\code{ll.m1}}{log-likelihood of alternative model.}
  \item{\code{AIC.m0}}{AIC of null model.}
  \item{\code{AIC.m1}}{AIC of alternative model.}
  \item{\code{BIC.m0}}{BIC of null model.}
  \item{\code{BIC.m1}}{BIC of alternative model.}
  }
}
\description{
Calculates DIF likelihood ratio statistics for ordinal data based either on adjacent
category logit regression model or on cumulative logit regression model.
}
\details{
Calculates DIF likelihood ratio statistics based either on adjacent category logit model
or on cumulative logit model for ordinal data.

Using adjacent category logit model, logarithm of ratio of probabilities of two adjacent
categories is
\deqn{log(P(y = k)/P(y = k-1)) = (a + aDif*g)*(x - b_k - b_kDif*g),}
where \eqn{x} is by default standardized total score (also called Z-score) and \eqn{g} is a group
membership. Parameter \eqn{a} is a discrimination of the item and parameter \eqn{b_k} is difficulty
for the \eqn{k}-th category of the item. Terms \eqn{a_Dif} and \eqn{b_kDif} then represent differences
between two groups (reference and focal) in relevant parameters.

Using cumulative logit model, probability of gaining at least \eqn{k} points is given by
2PL model, i.e.,
\deqn{P(y >= k) = exp((a + aDif*g)*(x - b_k - b_kDif*g))/(1 + exp((a + aDif*g)*(x - b_k - b_kDif*g))).}
The category probability (i.e., probability of gaining exactly \eqn{k} points) is then
\eqn{P(Y = k) = P(Y >= k) - P(Y >= k + 1)}.

Both models are estimated by iteratively reweighted least squares. For more details see \code{\link[VGAM]{vglm}}.

Argument \code{parametrization} is a character which specifies parametrization of regression parameters.
Default option is \code{"irt"} which returns IRT parametrization (difficulty-discrimination, see above).
Option \code{"classic"} returns intercept-slope parametrization with effect of group membership and
interaction with matching criterion, i.e. \eqn{b_0k + b_1*x + b_2k*g + b_3*x*g} instead of
\eqn{(a + a_Dif*g)*(x - b_k - b_kDif*g))}.
}
\examples{
\dontrun{
# loading data
data(dataMedicalgraded, package = "ShinyItemAnalysis")
df <- dataMedicalgraded[, c(1:5, 101)]
df <- df[complete.cases(df), ]

Data <- df[, 1:5]
group <- df[, 6]

# Testing both DIF effects
ORD(Data, group, type = "both")

# Testing uniform DIF effects
ORD(Data, group, type = "udif")

# Testing non-uniform DIF effects
ORD(Data, group, type = "nudif")

# Testing DIF using cumulative logit model
ORD(Data, group, model = "cumulative")
}

}
\references{
Agresti, A. (2010). Analysis of ordinal categorical data. Second edition. John Wiley & Sons.

Hladka, A. & Martinkova, P. (2020). difNLR: Generalized logistic regression models for DIF and DDF detection.
The R journal, 12(1), 300--323, \doi{10.32614/RJ-2020-014}.
}
\seealso{
\code{\link[stats]{p.adjust}} \code{\link[VGAM]{vglm}}
}
\author{
Adela Hladka (nee Drabinova) \cr
Institute of Computer Science of the Czech Academy of Sciences \cr
Faculty of Mathematics and Physics, Charles University \cr
\email{hladka@cs.cas.cz} \cr

Patricia Martinkova \cr
Institute of Computer Science of the Czech Academy of Sciences \cr
\email{martinkova@cs.cas.cz} \cr
}
\keyword{DIF}
