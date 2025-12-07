library(httr)
library(sf)
library(jsonlite)

# build docker image: 
# docker build -t data-api .

# run locally
# docker run -p 8000:8000 --env-file .env data-api

# to do:
# check if .env file is absolutely necessary
# deploy on a server, e.g., lightsail

sitpth <- system.file('extdata/ExampleSites.xlsx', package = 'MassWateR')

# site data
sitdat <- MassWateR::readMWRsites(sitpth)

dat_ext <- sitdat %>% 
  sf::st_as_sf(coords = c('Monitoring Location Longitude', 'Monitoring Location Latitude'), crs = 4326) %>%
  sf::st_as_sfc() %>% 
  sf::st_bbox()

# Base URL of your API
base_url <- "http://localhost:8000"

# Test 1: Check health
health <- GET(paste0(base_url, "/health"))
content(health)

files <- GET(paste0(base_url, "/files"))
content(files)

response <- GET(
  paste0(base_url, "/bbox/file"),
  query = list(
    file = "pondsMWR.geojson",
    xmin = dat_ext[['xmin']],
    ymin = dat_ext[['ymin']],
    xmax = dat_ext[['xmax']],
    ymax = dat_ext[['ymax']]
  )
)
data <- content(response)
print(paste("Found", data$count, "features"))

# Build FeatureCollection string
fc <- paste0(
  '{"type":"FeatureCollection","features":[',
  paste(data$features, collapse = ","),
  ']}'
)

spatial_data <- st_read(I(fc), quiet = TRUE)
plot(spatial_data$geometry)

response <- GET(
  paste0(base_url, "/bbox/all"),
  query = list(
    xmin = dat_ext[['xmin']],
    ymin = dat_ext[['ymin']],
    xmax = dat_ext[['xmax']],
    ymax = dat_ext[['ymax']]
  )
)
data <- content(response)
print(paste("Found", data$count, "features"))

# Build FeatureCollection string
fc <- paste0(
  '{"type":"FeatureCollection","features":[',
  paste(data$features, collapse = ","),
  ']}'
)

spatial_data <- st_read(I(fc), quiet = TRUE)

plot(spatial_data$geometry)
# # Write to a temp .geojson file
# tmp <- tempfile(fileext = ".geojson")
# writeLines(fc, tmp)

# # Read with GDAL
# spatial_data <- st_read(tmp, quiet = TRUE)
# unlink(tmp)
