# MassWateRdata

Supporting data for the [MassWateR](https://massbays-tech.github.io/MassWateR/) R package, includes simplified NHD datsets to support the `anlzMWRmap()` function.

## Logic for creating raw shapefiles

See [R/dat_proc.R](https://github.com/massbays-tech/MassWateRdata/blob/main/R/dat_proc.R) for creating RData objects used by MassWateR.

<ins>Create simplified shapefiles</ins>

1.  Get NHDFlowline, NHDWaterbody, and NHDArea layers for Massachusetts, Vermont, and New Hampshire.
1.  Clip Vermont layers with the WBDHU4 Connecticut River watershed.
1.  Clip New Hampshire layers with WBDHU4 Merrimack River watershed.
1.  Merge MA, VT, NH for each layer type.
1.  *In NHDWaterbody layer, change visibility for Long Island Sound to 1,000,000*
1.  Filter NHDFlowlines to fcode 46006 and visibility \> 100,000
1.  Filter NHDWaterbody to ftypes 390 and 493 and visibility \> 100,000
1.  No filter needed for NHDArea
1.  Export each layer to new layer (with fields ObjectID, fdate, fcode, ftype, visibility)
1. Delete duplicate geometries in each layer
1. Remove extra ponds from Waterbody layer (see note about middle CT River watershed below)
     * Add pond_area field in m<sup>2</sup>
     * Select by location waterbodies within CTWatershed_waterbody_correction polygon
     * Filter within selection waterbodies with pond_area less than 10,000 m<sup>2</sup>
     * Create a temporary clipped layer of Flowlines that intersect the correction polygon (improves performance of next step)
     * Remove from selection by location all waterbodies that touch Flowlines
     * Invert selection and export layer
1. Add dLevel field per logic below
1. Simplify all layers to 10 meters
1. Zip the three sets of shapefiles together

<ins>Logic for NHD dLevels</ins>

NHDArea -- dLevel = 'low' 
NHDWaterbody and NHDFlowline: 
* If visibility \< 500,000 then dLevel = 'high' 
* If visibility \>= 500,000 then dLevel = 'medium' 
* If visibility \>= 1,000,000 then dLevel = 'low' 
* *Code: if("visibility" \>= 1000000,'low', if("visibility" \>= 500000, 'medium', 'high'))*

In the middle CT River watershed, there is a large area where visibility is set to 5,000,000 for all small ponds in the Waterbody layer. This needs to be corrected as follows:

1.  Filter NHDWaterbody for dLevel = **'low'** and pond_area \<= **300,000** m<sup>2</sup>
    -   Code: "dLevel" = 'low' AND "pond_area" \<= 300000
1.  Select waterbodies by location within CTWatershed_waterbody_correction polygon
1.  Filter NHDFlowline to **'low'** (use temporary clipped Flowline layer)
    -   Code: "dLevel" = 'low'
1.  Remove from selection by location all waterbodies that touch Flowlines
1.  Change dLevel to **'medium'** for selected waterbodies
1.  Filter NHDWaterbody for dLevel = **'low'** and **'medium'** and pond_area \<= **85,000** m<sup>2</sup>
    -   Code: ("dLevel" = 'low' OR "dLevel" = 'medium') AND "pond_area" \<= 85000
1.  Select waterbodies by location within CTWatershed_waterbody_correction polygon
1.  Filter NHDFlowline to 'low' and 'medium' (use temporary clipped Flowline layer)
    -   Code: "dLevel" = 'low' OR "dLevel" = 'medium'
1.  Remove from selection by location all waterbodies that touch Flowlines
1. Change dLevel to **'high'** for selected waterbodies

Here is a link to the NHD ftype and fcode definitions. <https://nhd.usgs.gov/userGuide/Robohelpfiles/NHD_User_Guide/Feature_Catalog/Hydrography_Dataset/Complete_FCode_List.htm>
