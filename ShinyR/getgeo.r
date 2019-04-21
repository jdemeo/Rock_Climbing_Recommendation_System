getgeo <- function(cityname){
  
  # Creating parameters for the GET request
  base <- "https://maps.googleapis.com/maps/api/geocode/json?address="
  city <- str_replace_all(cityname, " ", "+")
  key <- "AIzaSyCA4kgXdSCcG0U8e1VGztuTjR9raQC9B-o"
  
  # Creating API call string
  call <- paste(base,city,"&key=",key, sep="")
  
  # Make API request
  get_location <- GET(call, type = "basic")
  
  # Convert results to dataframe 
  get_location_text <- content(get_location, "text")
  get_location_json <- fromJSON(get_location_text, flatten = TRUE)
  
  latitude <- get_location_json$results$geometry.location.lat
  longitude <- get_location_json$results$geometry.location.lng
  
  return (list(latitude, longitude))
}