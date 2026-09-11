library(sf)
library(tidyverse)
library(leaflet)
library(rmapshaper)

csd <- read_sf("../../spatialfiles/census/CSDs")

pop_table <- read_csv("output/pop_table.csv")

alberta_csd <- csd |>
  filter(PRUID == 48) |>
  filter(!(CSDNAME == "Taber" & CSDTYPE == "MD"))

alberta_csd <- alberta_csd |>
  inner_join(
    pop_table,
    by = "CSDNAME")

st_write(
  alberta_csd |>
    ms_simplify(keep = 0.05, keep_shapes = TRUE) |>
    st_transform(crs = 4326),
  "map_layers/alberta_csd.geojson",
  delete_dsn = TRUE)
