# api.R
library(plumber)
library(sf)
library(aws.s3)
library(dplyr)
library(geojsonsf)

# Set up AWS credentials from environment variables
Sys.setenv(
  "AWS_ACCESS_KEY_ID" = Sys.getenv("AWS_ACCESS_KEY_ID"),
  "AWS_SECRET_ACCESS_KEY" = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
  "AWS_DEFAULT_REGION" = Sys.getenv("AWS_DEFAULT_REGION", "us-east-1")
)

# Cache for storing loaded GeoJSON files
cache <- new.env()

#* @apiTitle MassWater Data API
#* @apiDescription API for serving MassWateR GeoJSON data based on bounding box requests

#* Load GeoJSON from S3
load_geojson_from_s3 <- function(file_key) {
  # Check if already in cache
  if (exists(file_key, envir = cache)) {
    message("Returning cached: ", file_key)
    return(get(file_key, envir = cache))
  }
  
  # Download from S3
  message("Downloading from S3: ", file_key)
  
  # Get object from S3
  obj <- get_object(
    object = file_key,
    bucket = "masswater-data"
  )
  
  # Convert raw content to text
  content <- rawToChar(obj)
  
  # Read as sf object
  shapes <- geojsonsf::geojson_sf(content)
  
  # Store in cache
  assign(file_key, shapes, envir = cache)
  
  return(shapes)
}

#* Health check endpoint
#* @get /health
function() {
  list(
    status = "healthy",
    timestamp = Sys.time(),
    files_available = c(
      "pondsMWR.geojson",
      "riversMWR.geojson", 
      "streamsMWR.geojson"
    )
  )
}

#* List available GeoJSON files
#* @get /files
function() {
  files <- get_bucket_df(
    bucket = "masswater-data",
    prefix = "geojson/"
  )
  
  # Filter for .geojson files only
  geojson_files <- files[grep("\\.geojson$", files$Key), ]
  
  return(list(
    files = basename(geojson_files$Key),
    count = nrow(geojson_files)
  ))
}

#* Get features within a bounding box from a specific file
#* @param file The GeoJSON filename (e.g., "pondsMWR.geojson")
#* @param xmin Minimum longitude
#* @param ymin Minimum latitude  
#* @param xmax Maximum longitude
#* @param ymax Maximum latitude
#* @get /bbox/file
function(file, xmin, ymin, xmax, ymax) {
  
  # Validate parameters
  xmin <- as.numeric(xmin)
  ymin <- as.numeric(ymin)
  xmax <- as.numeric(xmax)
  ymax <- as.numeric(ymax)
  
  # Build full S3 key
  s3_key <- paste0("geojson/", file)
  
  # Load the GeoJSON from S3
  tryCatch({
    shapes <- load_geojson_from_s3(s3_key)
    
    # Create bounding box
    bbox <- st_bbox(c(xmin = xmin, ymin = ymin, 
                       xmax = xmax, ymax = ymax), 
                     crs = st_crs(4326))
    bbox_sfc <- st_as_sfc(bbox)
    
    # Filter shapes by bounding box
    filtered_shapes <- shapes %>%
      st_filter(bbox_sfc, .predicate = st_intersects)
    
    # Convert back to GeoJSON
    if (nrow(filtered_shapes) > 0) {
      return(list(
        type = "FeatureCollection",
        features = geojsonsf::sf_geojson(filtered_shapes, atomise = TRUE),
        count = nrow(filtered_shapes),
        source_file = file
      ))
    } else {
      return(list(
        type = "FeatureCollection",
        features = list(),
        count = 0,
        source_file = file,
        message = "No features found in the specified bounding box"
      ))
    }
    
  }, error = function(e) {
    return(list(
      error = TRUE,
      message = paste("Error loading file:", e$message)
    ))
  })
}

#* Get features from ALL files within a bounding box
#* @param xmin Minimum longitude
#* @param ymin Minimum latitude  
#* @param xmax Maximum longitude
#* @param ymax Maximum latitude
#* @get /bbox/all
function(xmin, ymin, xmax, ymax) {
  
  # Validate parameters
  xmin <- as.numeric(xmin)
  ymin <- as.numeric(ymin)
  xmax <- as.numeric(xmax)
  ymax <- as.numeric(ymax)
  
  # List of files to process
  files <- c("pondsMWR.geojson", "riversMWR.geojson", "streamsMWR.geojson")
  
  all_features <- list()
  
  for (file in files) {
    s3_key <- paste0("geojson/", file)
    
    tryCatch({
      shapes <- load_geojson_from_s3(s3_key)
      
      # Create bounding box
      bbox <- st_bbox(c(xmin = xmin, ymin = ymin, 
                         xmax = xmax, ymax = ymax), 
                       crs = st_crs(4326))
      bbox_sfc <- st_as_sfc(bbox)
      
      # Filter shapes
      filtered_shapes <- shapes %>%
        st_filter(bbox_sfc, .predicate = st_intersects)
      
      if (nrow(filtered_shapes) > 0) {
        # Add source file information
        filtered_shapes$source_file <- file
        all_features[[file]] <- filtered_shapes
      }
      
    }, error = function(e) {
      message("Error processing ", file, ": ", e$message)
    })
  }
  
  # Combine all features
  if (length(all_features) > 0) {
    combined <- do.call(rbind, all_features)
    return(list(
      type = "FeatureCollection",
      features = geojsonsf::sf_geojson(combined, atomise = TRUE),
      count = nrow(combined),
      files_included = names(all_features)
    ))
  } else {
    return(list(
      type = "FeatureCollection",
      features = list(),
      count = 0,
      message = "No features found in any file for the specified bounding box"
    ))
  }
}

#* Get full file (no bbox filtering)
#* @param file The GeoJSON filename
#* @get /file
function(file) {
  s3_key <- paste0("geojson/", file)
  
  tryCatch({
    shapes <- load_geojson_from_s3(s3_key)
    
    return(list(
      type = "FeatureCollection",
      features = geojsonsf::sf_geojson(shapes, atomise = TRUE),
      count = nrow(shapes),
      source_file = file
    ))
    
  }, error = function(e) {
    return(list(
      error = TRUE,
      message = paste("Error loading file:", e$message)
    ))
  })
}