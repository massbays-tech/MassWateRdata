library(sf)
library(dplyr)
library(here)

tol <- 10

pondsMWR <- st_read(here('data/data-raw/NHDWaterbody_ftype_390-493_vis_101k_noattr.shp')) %>%
 st_make_valid() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(pondsMWR, file = here('data/pondsMWR.RData'))

riversMWR <- st_read(here('data/data-raw/NHDArea_noattr.shp')) %>%
 st_make_valid() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(riversMWR, file = here('data/riversMWR.RData'))

streamsMWR <- st_read(here('data/data-raw/NHDFlowline_fcode_46006_vis_101k_noattr.shp')) %>%
 st_zm() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(streamsMWR, file = here('data/streamsMWR.RData'))

sudburyMWR <- st_read(here('data/data-raw/Sudbury_watershed_singleboundary.shp')) %>%
 st_zm()

save(sudburyMWR, file = 'data/sudburyMWR.RData')
