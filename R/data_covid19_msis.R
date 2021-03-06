
#' data_covid19_msis
#'
#' Get and clean NorMOMO data
#'
#'  @import data.table
#'
#' @export
data_covid19_msis <- function(data, argset, schema){
  # data <- tm_get_data("data_covid19_msis")
  # argset <- tm_get_argset("data_covid19_msis")
  # schema <- tm_get_schema("data_covid19_msis")

  file <- fs::dir_ls("/input/covid19_msis/", regexp="per_municip_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].rds")
  file <- max(file)
  d <- readRDS(file)

  setnames(d, "N", "n")
  d[, location_code := paste0("municip",bostedskommunenr_msis)]
  d[, date:= as.Date(provedato)]

  d[, provedato := NULL]
  d[, bostedskommunenr_msis := NULL]

  skeleton <- expand.grid(
    location_code = fhidata::norway_locations_b2020$municip_code,
    date = seq.Date(
      min(d$date),
      max(d$date),
      by = 1
    ),
    stringsAsFactors = FALSE
  )
  setDT(skeleton)

  d_municip <- merge(
    skeleton,
    d,
    by=c("location_code","date"),
    all.x = T
  )
  d_municip[is.na(n), n:=0]
  d_municip[, granularity_geo := "municip"]

  # now generate county data
  d_county <- copy(d_municip)
  d_county[
    fhidata::norway_locations_b2020,
    on="location_code==municip_code",
    county_code := county_code
  ]
  d_county <- d_county[,.(
    n = sum(n)
  ), keyby=.(
    location_code = county_code,
    date
  )]
  d_county[, granularity_geo := "county"]

  # generate norge data
  d_norge <- d_county[,.(
    n = sum(n)
  ), keyby=.(
    date
  )]
  d_norge[, location_code := "norge"]
  d_norge[, granularity_geo := "nation"]

  d <- rbind(d_municip, d_county, d_norge)

  d[, tag_outcome := "confirmed"]
  d[, granularity_time := "day"]
  d[, border := 2020]
  d[, age := "totalt"]
  d[, sex := "totalt"]
  d[, yrwk := fhi::isoyearweek(date)]
  d[, year:= fhi::isoyear_n(date)]
  d[, week := fhi::isoweek_n(date)]
  d[, month := lubridate::month(date)]
  d[, season := fhi::season(yrwk)]
  d[, x := fhi::x(week)]



  schema$output$db_drop_table()
  schema$output$db_connect()
  schema$output$db_drop_constraint()
  schema$output$db_load_data_infile(d)
  schema$output$db_add_constraint()
}




