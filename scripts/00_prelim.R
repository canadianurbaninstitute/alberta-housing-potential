# Preliminary scan of available data and existing methodology
readRenviron("../.env") 

library(msmdata)
library(tidyverse)
library(leaflet)
library(sf)

options(scipen = 999)

msn_network <- read_blob_data("Data/spatialfiles/msn_mainstreets.parquet", type = "geoparquet") |>
  mutate(id = as.character(id))

housing_est_data <- read_csv("input/similar_streets.csv") |>
  mutate(id = as.character(id))

msn_alberta <- msn_network |>
  filter(PRUID == 48)

housing_est_alberta <- housing_est_data |>
  filter(pruid == 48)

msn_alberta <- msn_alberta |>
  inner_join(housing_est_alberta,
             by = "id")

msn_alberta <- msn_alberta |>
  mutate(
    units_low_est =
      (surface_Parking_lots + gas_stations) * 5 +
      Residential +
      Commercial * 11 +
      Mixed.Use +
      civic_count * 25,
    units_high_est =
      (surface_Parking_lots + gas_stations) * 12 +
      Residential * 2 +
      Commercial * 28 +
      Mixed.Use * 3 +
      civic_count * 62
  )

pal <- colorNumeric(palette = "viridis", domain = msn_alberta$total_sites)

leaflet(msn_alberta |> st_transform(crs = 4326)) |>
  addProviderTiles(providers$CartoDB.Positron) |>
  addPolylines(
    color = ~pal(total_sites),
    weight = 3,
    opacity = 0.8,
    label = ~R_STNAM,
    popup = ~paste0(
      "<b>", R_STNAM, "</b><br>",
      "<em>", R_PLACE, "</em>", "<br>",
      "Total opportunity sites: ", total_sites, "<br>",
      "Potential residential units (low estimate): ", units_low_est, "<br>",
      "Potential residential units (high estimate): ", units_high_est
    )
  ) |>
  addLegend(
    pal = pal,
    values = ~total_sites,
    title = "Total sites",
    position = "bottomright"
  )

print(paste0("Potential residential units in Alberta (low, excluding vacant sites): ", format(sum(msn_alberta$units_low_est), big.mark = ",")))
print(paste0("Potential residential units in Alberta (high, excluding vacant sites): ", format(sum(msn_alberta$units_high_est), big.mark = ",")))

ab_city_summary <- msn_alberta |>
  group_by(R_PLACE) |>
  st_drop_geometry() |>
  summarise(total_sites = sum(total_sites, na.rm = TRUE),
            units_low_est = sum(units_low_est, na.rm = TRUE),
            units_high_est = sum(units_high_est, na.rm = TRUE))