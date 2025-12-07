library(sf)
library(dplyr)
library(here)
library(geojsonsf)
library(aws.s3)

Sys.setenv(
  "AWS_ACCESS_KEY_ID" = Sys.getenv("AWS_ACCESS_KEY_ID"),
  "AWS_SECRET_ACCESS_KEY" = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
  "AWS_DEFAULT_REGION" = "us-east-1" 
)

tol <- 10

# layers received from BW on 3/2/23 have already been simplified

pondsMWR <- st_read(here('data/data-raw/FullNHDWaterbody_ftype390-493_vis101k_simpl.shp')) %>%
 st_make_valid() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(pondsMWR, file = here('data/pondsMWR.RData'))
pondsMWR_geojson_string <- sf_geojson(pondsMWR, atomise = TRUE, simplify = TRUE)
write(pondsMWR_geojson_string, here("data/pondsMWR.geojson"))
put_object(
  file = here("data/pondsMWR.geojson"),
  object = 'geojson/pondsMWR.geojson',
  bucket = "masswater-data"
)


riversMWR <- st_read(here('data/data-raw/FullNHDArea_noattrib_simpl.shp')) %>%
 st_make_valid() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(riversMWR, file = here('data/riversMWR.RData'))
riversMWR_geojson_string <- sf_geojson(riversMWR, atomise = TRUE, simplify = TRUE)
write(riversMWR_geojson_string, here("data/riversMWR.geojson"))
put_object(
  file = here("data/riversMWR.geojson"),
  object = 'geojson/riversMWR.geojson',
  bucket = "masswater-data"
)

streamsMWR <- st_read(here('data/data-raw/FullNHDFlowline_fcode46006_vis101k_simpl.shp')) %>%
 st_zm() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(streamsMWR, file = here('data/streamsMWR.RData'))
streamsMWR_geojson_string <- sf_geojson(streamsMWR, atomise = TRUE, simplify = TRUE)
write(streamsMWR_geojson_string, here("data/streamsMWR.geojson"))
put_object(
  file = here("data/streamsMWR.geojson"),
  object = 'geojson/streamsMWR.geojson',
  bucket = "masswater-data"
)

sudburyMWR <- st_read(here('data/data-raw/Sudbury_watershed_singleboundary.shp')) %>%
 st_zm()

save(sudburyMWR, file = 'data/sudburyMWR.RData')
