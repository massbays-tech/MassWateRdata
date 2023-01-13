library(sf)
library(dplyr)
library(here)

tol <- 10

pondsMWR <- st_read('~/Desktop/NHD_MA/NHDWaterbody_ftype_390-493_vis_101k_noattr.shp') %>%
 st_make_valid() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(pondsMWR, file = here('data/pondsMWR.RData'), compress = 'xz')

riversMWR <- st_read('~/Desktop/NHD_MA/NHDArea_noattr.shp') %>%
 st_make_valid() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(riversMWR, file = here('data/riversMWR.RData'), compress = 'xz')

streamsMWR <- st_read('~/Desktop/NHD_MA/NHDFlowline_fcode_46006_vis_101k_noattr.shp') %>%
 st_zm() %>%
 st_simplify(dTolerance = tol, preserveTopology = TRUE) %>%
 st_make_valid() %>%
 select(dLevel)

save(streamsMWR, file = here('data/streamsMWR.RData'), compress = 'xz')