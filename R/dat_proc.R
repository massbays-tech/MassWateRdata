library(sf)
library(dplyr)
library(here)

tol <- 10

# layers received from BW on 3/2/23 have already been simplified

pondsMWR <- st_read(here('data/data-raw/FullNHDWaterbody_ftype390-493_vis101k_simpl.shp')) %>%
 st_make_valid() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(pondsMWR, file = here('data/pondsMWR.RData'))

riversMWR <- st_read(here('data/data-raw/FullNHDArea_noattrib_simpl.shp')) %>%
 st_make_valid() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(riversMWR, file = here('data/riversMWR.RData'))

streamsMWR <- st_read(here('data/data-raw/FullNHDFlowline_fcode46006_vis101k_simpl.shp')) %>%
 st_zm() %>%
 # st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(streamsMWR, file = here('data/streamsMWR.RData'))

sudburyMWR <- st_read(here('data/data-raw/Sudbury_watershed_singleboundary.shp')) %>%
 st_zm()

save(sudburyMWR, file = 'data/sudburyMWR.RData')
