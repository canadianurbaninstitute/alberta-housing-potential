readRenviron("../.env")

# Check existing main streets for case study municipalities
library(msmdata)
library(sf)
library(tidyverse)
library(leaflet)

# Data

# Remaking Main Streets data
rms_network <- read_csv("input/similar_streets.csv") |>
  mutate(id = as.character(id))

# Full main street dataset
msn_network <- read_blob_data("Data/spatialfiles/msn_mainstreets.parquet", type = "geoparquet") |>
  mutate(id = as.character(id))

# Airdrie

# Main Street from intersection of Jensen Drive NE/4 Av NW to Ridgegate Way SW/Elk Hill SE: included, but not exact match
# Centre Ave/Railway Ave from Albert Street SE to MacKenzie Way SW: some sections included
# First Ave from Bowers ST NE to 8 ST SW: some sections included
rms_airdrie <- rms_network |>
  filter(city_name == "Airdrie")

msn_airdrie <- msn_network  |>
  filter(R_PLACE == "Airdrie") |>
  left_join(rms_airdrie, by = "id")

msn_airdrie <- msn_airdrie |>
  mutate(suggestion = if_else(
    R_STNAM %in% c("Main Street North", 
    "Main Street South", 
    "Centre Avenue East", 
    "Centre Avenue West", "Railway Avenue South-West",
    "1 Avenue North-East", "1 Avenue North-East"),
    TRUE,
    FALSE
  ),
  rms = if_else(
    !is.na(total_sites), TRUE, FALSE
  ),
  category = case_when(
    rms & !suggestion ~ 1,
    suggestion & !rms ~ 2,
    rms & suggestion ~ 3,
    !rms & !suggestion ~ 4
  )
  )


category_pal <- colorFactor(
  palette = "Dark2",
  domain = c(1, 2, 3, 4)
)

leaflet(msn_airdrie |> st_transform(crs = 4326)) |>
  addTiles() |>
  addPolylines(
    weight = 3,
    opacity = 0.8,
    color = ~category_pal(category),
    label = ~R_PLACE,
    popup = ~paste0(
      "<b>", R_STNAM, "</b><br>",
      "Total sites: ", total_sites, "<br>",
      "<em>", R_PLACE, "</em>", "<br>"
    )
  ) |>
  addLegend(
    position = "bottomright",
    pal = category_pal,
    values = ~category,
    title = "Category",
    labFormat = labelFormat(
      transform = function(x) c(
        "1" = "Remaking Main Streets",
        "2" = "Suggestion",
        "3" = "Both",
        "4" = "Neither"
      )[as.character(x)]
    )
  )
