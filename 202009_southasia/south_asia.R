require(rcrea)
require(dplyr)

dir_results <- file.path("202009_southasia", "results")
dir.create(dir_results, showWarnings = F, recursive = T)

cities_cpcb <- c("Delhi", "Lucknow", "Ghaziabad", "Varanasi", "Srinagar", "Amritsa", "Kolkata")
cities_openaq <- c("Dhaka", "Peshawar", "Lahore", "Karachi", "Islamabad", "Faisalabad", "Kathmandu")


m_cpcb <- rcrea::measurements(source="cpcb",
                              city=cities_cpcb,
                              poll=c("no2","pm10","pm25"),
                              date_from="2016-12-01",
                              deweather=NULL,
                              with_metadata=T)

m_openaq <- rcrea::measurements(source="openaq",
                                city=cities_openaq,
                                poll=c("no2","pm10","pm25"),
                                date_from="2016-12-01",
                                deweather=NULL,
                                with_metadata=T)

m <- rbind(
  m_cpcb,
  m_openaq
)



# Plots -------------------------------------------------------------------
dir_results_obs <- file.path(dir_results, "observations")
dir.create(dir_results_obs, showWarnings = F, recursive = T)
rcrea::plot_recents(meas_raw=m %>% filter(process_id %in% c("city_day_absolute", "city_day_mad")),
             subfile_by = "poll",
             subplot_by = "region_id",
             color_by="year",
             running_days = 30,
             folder = dir_results_obs,
             size = c("m"),
             add_lockdown=T,
             years=seq(2017,2020)
             )

dir_results_deweathered <- file.path(dir_results, "deweathered")
dir.create(dir_results_deweathered, showWarnings = F, recursive = T)
plot_recents(meas_raw=m %>% filter(process_id %in% c("anomaly_offsetted_gbm_lag1_city_mad",
                                                     "anomaly_offsetted_gbm_lag1_city_absolute")),
             subfile_by = "poll",
             subplot_by = "region_id",
             color_by="year",
             running_days = 30,
             folder = dir_results_deweathered,
             size = c("m"),
             years=2020,
             add_lockdown=T
)

dir_results_deweathered_percent <- file.path(dir_results, "deweathered_percent")
dir.create(dir_results_deweathered_percent, showWarnings = F, recursive = T)
plot_recents(meas_raw=m %>% filter(process_id %in% c("anomaly_percent_gbm_lag1_city_mad",
                                                     "anomaly_percent_gbm_lag1_city_absolute")),
             subfile_by = "poll",
             subplot_by = "region_id",
             color_by="year",
             running_days = 30,
             folder = dir_results_deweathered_percent,
             size = c("m"),
             years=2020,
             add_lockdown=T
)


# Export ------------------------------------------------------------------

m.obs <- m %>%
  filter(process_id %in% c("city_day_absolute", "city_day_mad")) %>%
  select(city=region_id, country, date, poll, unit, value, source) %>%
  arrange(country, city, poll, date)
write.csv(m.obs, file = file.path(dir_results, "observations.png"))
