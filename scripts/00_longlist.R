readRenviron("../.env")
# Data prep for municipality longlist

library(msmdata)
library(tidyverse)
library(leaflet)
library(sf)

options(scipen = 999)

# Data ----------------
pop_est <- read_csv("input/population_estimates.csv")
pop_proj <- read_csv("input/population_projections.csv")

msn_network <- read_blob_data("Data/spatialfiles/msn_mainstreets.parquet", type = "geoparquet") |>
  mutate(id = as.character(id))

msn_alberta <- msn_network |>
  filter(PRUID == 48)

# st_write(
#   msn_alberta |> st_transform(crs = 4326), 
#   "map_layers/msn_alberta.geojson",
#   delete_dsn = TRUE)

# Join ----------------

pop_est <- pop_est |>
  mutate(CSDNAME = str_extract(Geography, "^[^(]+") |> str_trim())

pop_proj <- pop_proj |>
  mutate(CSDNAME = str_extract(Geography, "^[^,]+") |> str_trim())

pop_table <- pop_est |>
  select(CSDNAME, `2021`, `2025`) |>
  inner_join(
    pop_proj |>
      select(CSDNAME, `Projection scenario HG: high-growth 3`),
    by = "CSDNAME"
  ) |>
  rename(
    population_2021 = `2021`,
    population_2025 = `2025`,
    population_2050 = `Projection scenario HG: high-growth 3`
  ) |>
  mutate(
    pop_change_2021_2025 = (population_2025 - population_2021) / population_2021 * 100,
    pop_change_2025_2050 = (population_2050 - population_2025) / population_2025 * 100
  )

# st_write(pop_table, "output/pop_table.csv")

municipalities <- c(
    "Airdrie",
    "Medicine Hat",
    "Drumheller",
    "Chestermere",
    "Calmar",
    "Sturgeon County",
    "Lethbridge",
    "Spruce Grove",
    "Fort Mcmurray")

msn_subset <- msn_alberta |>
  filter(R_PLACE %in% municipalities)

leaflet(msn_subset |> st_transform(crs = 4326)) |>
  addTiles() |>
  addPolylines(
    weight = 3,
    opacity = 0.8,
    label = ~R_PLACE,
    popup = ~paste0(
      "<b>", R_STNAM, "</b><br>",
      "<em>", R_PLACE, "</em>", "<br>"
    )
  )
