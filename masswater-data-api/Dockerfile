# Use the rocker/geospatial image which has R and spatial libraries
FROM rocker/geospatial:4.3.2

# Install additional R packages needed for the API
RUN R -e "install.packages(c('plumber', 'aws.s3', 'geojsonsf'), repos='https://cloud.r-project.org/')"

# Create app directory
WORKDIR /app

# Copy the API file to the container
COPY api.R /app/api.R

# Expose the port that plumber will run on
EXPOSE 8000

# Run the API when the container starts
CMD ["R", "-e", "library(plumber); pr <- plumber::plumb('/app/api.R'); pr$run(host='0.0.0.0', port=8000)"]