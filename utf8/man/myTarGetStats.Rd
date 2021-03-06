\name{myTarGetStats}
\alias{myTarGetStats}

\title{Get stat by any API objects}
\description{Function myTarGetStats load data frame with statistic by any API objects.}
\usage{
myTarGetStats(date_from = Sys.Date() - 7, date_to = Sys.Date(), object_type = "campaigns", object_id = NULL, stat_type = "day", auth = NULL)
}

\arguments{
  \item{date_from}{Start date}
  \item{date_to}{End date}
  \item{object_type}{API object typr, character value, apply one of campaigns, banners,pad_groups,pads,users}
  \item{object_id}{ID of API object (id campaign or any object}
  \item{stat_type}{Time stap, get value day or hour}
  \item{auth}{R auth object}
}
\details{}
\value{
Data frame with statistic.
}

\author{
Alexey Seleznev
}
\note{
}



\seealso{
MyTarget API documentation - https://target.my.com/doc/api/detailed/#resource_statistics
}
\examples{
myCampStat <- myTarGetStats(date_from = "2016-08-01",
                            date_to = "2016-08-10",
                            object_type = "campaigns",
                            object_id = c("6530449","6477678"),
                            stat_type = "day",
                            auth = myTargetAuth)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
