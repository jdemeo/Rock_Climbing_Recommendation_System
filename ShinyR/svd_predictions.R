library(RcppCNPy)
setwd("/Users/jad/apptown/CSE_6242/climbing/svd_r/")

# Read in User and Route IDs
user_ids <- scan("users.txt", what="", sep="\n")
route_ids <- scan("routes.txt", what="", sep="\n")

# Read in latent matrix and bias terms
U <- npyLoad("u.npy")
Vt <- npyLoad("vt.npy")
b_u <- npyLoad("b_u.npy")
b_i <- npyLoad("b_i.npy")
mu = 2.7401829352698774

# Load in original user, route, rating matrix
df <- read.csv('user_routes_reduced.csv')

# Load in route lat long
lat_long_df <- read.csv('master_routes_lat_long.csv')
# Subset by relevant routes
lat_long_df <- lat_long_df[lat_long_df$RouteID %in% route_ids, ]


###################################################################

# Input userID (THIS WOULD BE THE INPUT SPOT FOR THE APP)
cur_user <- '107153125'
cur_user_index <- match(cur_user, user_ids)

# User collected data
user_lat <- 40.7564
user_long <- -111.8986
max_distance <- 25

# FUNCTION: Calculate distance from two points (in miles)
haversine <- function(lat1, lon1, lat2, lon2) {
  lat1 <- lat1 * pi / 180
  lon1 <- lon1 * pi / 180
  lat2 <- lat2 * pi / 180
  lon2 <- lon2 * pi / 180
  earth_radius <- 6371
  a <- sin((lat2-lat1)/ 2.0)^2 + cos(lat1) * cos(lat2) * sin((lon2-lon1)/2.0)^2
  earth_radius * 2 * asin(sqrt(a))
}

# Calculate distances from user to all routes
distances <- sapply(lat_long_df[c('Latitude')], function(lat, long) {
  haversine(user_lat, user_long, lat, long)
}, long=lat_long_df[c('Longitude')])
distances <- as.data.frame(distances) 
lat_long_df$Distance <- distances

# Get routes within max distance
close_routes <- lat_long_df[lat_long_df$Distance <= max_distance, ]$RouteID

# Keep routes only in proximity to specified location and drop routes the user has already done
completed_routes <- df[df$UserID == as.numeric(cur_user),]$RouteID
routes_of_interest <- c()
for (route in close_routes) {
  if (route %in% completed_routes) {
  } else {
    routes_of_interest <- c(routes_of_interest, route)
  }
}
roi_indices <- match(routes_of_interest, route_ids)

reduced_Vt <- Vt[roi_indices]
reduced_b_i <- b_i[roi_indices]

# Create prediction vector
user_predicted_ratings = U[c(cur_user_index),] %*% reduced_Vt + b_u[c(cur_user_index)] + reduced_b_i + mu

# Get indices sorted corresponding from highest to lowest values in array
sorted_ind <- order(user_predicted_ratings, decreasing=TRUE)

# Collect top k-values
k <- 5
k_indices <- sorted_ind[1:k]
top_k_ratings <- user_predicted_ratings[k_indices]
top_k_routes <- routes_of_interest[k_indices]          ###### THIS IS PROBABLY WHAT YOU WANT

print("Recommendations:")
for (i in 1:k) {
  print(paste('Route:', top_k_routes[i]))
  print(paste('Rating:', top_k_ratings[i]))
}









