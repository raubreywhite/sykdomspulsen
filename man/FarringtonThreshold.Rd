% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_qp.R
\name{FarringtonThreshold}
\alias{FarringtonThreshold}
\title{Calculate Farrington threshold}
\usage{
FarringtonThreshold(pred, phi, alpha = NULL, z = NULL,
  skewness.transform = "none")
}
\arguments{
\item{pred}{Point estimate}

\item{phi}{Dispersion}

\item{alpha}{Alpha (e.g 0.05)}

\item{z}{Similar to \code{alpha} (e.g. 1.96)}

\item{skewness.transform}{"none"/"1/2","2/3"}
}
\description{
Calculate Farrington threshold
}
