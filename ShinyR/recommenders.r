########## SVD Setup #############
print('Loading Up SVD data')
start_time <- Sys.time()

# Read in User and Route IDs
user_ids <- scan("users.txt", what="", sep="\n")
route_ids <- scan("routes.txt", what="", sep="\n")

# Read in latent matrix and bias terms
U <- npyLoad("u.npy")
Vt <- npyLoad("vt.npy")
b_u <- npyLoad("b_u.npy")
b_i <- npyLoad("b_i.npy")

# Load in original user, route, rating matrix
df <- data.frame(data.table::fread('user_routes_reduced.csv'))

# Load in route lat long
lat_long_df <- data.frame(data.table::fread('master_routes_lat_long.csv'))
# Subset by relevant routes
lat_long_df <- lat_long_df[lat_long_df$RouteID %in% route_ids, ]

end_time <- Sys.time()
print(end_time - start_time)     # Time to run code


###################################################################


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

getroutesid <- function(cur_user, user_lat, user_long, max_distance, numofrecom){

  max_distance <- as.numeric(max_distance)
  mu = 2.7401829352698774
  
  # Input userID (THIS WOULD BE THE INPUT SPOT FOR THE APP)
  cur_user_index <- match(cur_user, user_ids)

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
  k <- numofrecom
  k_indices <- sorted_ind[1:k]
  top_k_ratings <- user_predicted_ratings[k_indices]
  top_k_routes <- routes_of_interest[k_indices]          ###### THIS IS PROBABLY WHAT YOU WANT
  
  # Return top k routes
  return(top_k_routes)
}



########## KKNN Setup #############
# 
#read data

print('Loading Up KNN data')
start_time <- Sys.time()

print("importing datasets")
KKNN_df <- data.frame(data.table::fread('processed_data.csv'))
end_time <- Sys.time()
print(end_time - start_time)     # Time to run code

KKNN_dfRoute <- data.frame(data.table::fread('route_data.csv'))

end_time <- Sys.time()
print(end_time - start_time)     # Time to run code

#normalize data
KKNN_df$trad <- (KKNN_df$trad-min(KKNN_df$trad))/(max(KKNN_df$trad)-min(KKNN_df$trad))
KKNN_df$sport <- (KKNN_df$sport-min(KKNN_df$sport))/(max(KKNN_df$sport)-min(KKNN_df$sport))
KKNN_df$tr <- (KKNN_df$tr-min(KKNN_df$trad))/(max(KKNN_df$tr)-min(KKNN_df$tr))
KKNN_df$boulder <- (KKNN_df$boulder-min(KKNN_df$boulder))/(max(KKNN_df$boulder)-min(KKNN_df$boulder))
KKNN_df$ice <- (KKNN_df$ice-min(KKNN_df$ice))/(max(KKNN_df$ice)-min(KKNN_df$ice))
KKNN_df$alpine <- (KKNN_df$alpine-min(KKNN_df$alpine))/(max(KKNN_df$alpine)-min(KKNN_df$alpine))
KKNN_df$snow <- (KKNN_df$snow-min(KKNN_df$snow))/(max(KKNN_df$snow)-min(KKNN_df$snow))
KKNN_df$aid <- (KKNN_df$aid-min(KKNN_df$aid))/(max(KKNN_df$aid)-min(KKNN_df$aid))
KKNN_df$mixed <- (KKNN_df$mixed-min(KKNN_df$mixed))/(max(KKNN_df$mixed)-min(KKNN_df$mixed))
KKNN_df$average <- (KKNN_df$average-min(KKNN_df$average))/(max(KKNN_df$average)-min(KKNN_df$average))
KKNN_df$hardest <- (KKNN_df$hardest-min(KKNN_df$hardest))/(max(KKNN_df$hardest)-min(KKNN_df$hardest))
KKNN_df$route_count <- (KKNN_df$route_count-min(KKNN_df$route_count))/(max(KKNN_df$route_count)-min(KKNN_df$route_count))


end_time <- Sys.time()
print(end_time - start_time)     # Time to run code

######################################################################


########## KNN Computation ###################

getKNN <- function(currentUser, lat, lon, dist, numofrecom){
  print("into the KNN code")
  #define current user
  # currentUser <- 108738732
  # lat <- 40.7564
  # lon <- -111.8986
  # dist <- 25.0 #in miles
  print(currentUser)
  print(lat)
  print(lon)
  print(dist)
  dist <- as.numeric(dist)
  #get row for current user
  user_list <- head(KKNN_df[KKNN_df$user == currentUser,], n = 1)
  
  #Only run if route count is less than 200 (normalized to 1)
  
  # ticks <- TICK$find(paste0('{"user":','"', currentUser, '"}'))
  # length(ticks$ticks[[1]]$routeId)
  routeCount <- head(user_list$route_count, n = 1)
  if (routeCount < .5) {
    
    #get route list for current user
    userList <- user_list$route_list[[1]]
    userList <- sapply(userList, function(x) gsub("\\[|\\'|\\]|\\s", "", x) )
    userList <- as.vector(unlist(strsplit(userList,",")),mode="list")
    userList <- do.call(rbind.data.frame, userList)
    names(userList)[1]<-"name"
    
    #define variable for current user
    average <- user_list$average
    hardest <- user_list$hardest
    count <- user_list$route_count
    trad <- user_list$trad
    sport <- user_list$sport
    tr <- user_list$tr
    boulder <- user_list$boulder
    ice <- user_list$ice
    alpine <- user_list$alpine
    snow <- user_list$snow
    aid <- user_list$aid
    mixed <- user_list$mixed
    
    #define closeness to user
    KKNN_df$average_closeness <- sapply(KKNN_df$average, function(x) as.numeric((average-x)**2))
    KKNN_df$hardest_closeness <- sapply(KKNN_df$hardest, function(x) as.numeric((hardest-x)**2))
    KKNN_df$route_count_closeness <- sapply(KKNN_df$route_count, function(x) as.numeric((count-x)**2))
    KKNN_df$trad_closeness <- sapply(KKNN_df$trad, function(x) as.numeric((trad-x)**2))
    KKNN_df$sport_closeness <- sapply(KKNN_df$sport, function(x) as.numeric((sport-x)**2))
    KKNN_df$tr_closeness <- sapply(KKNN_df$tr, function(x) as.numeric((tr-x)**2))
    KKNN_df$boulder_closeness <- sapply(KKNN_df$boulder, function(x) as.numeric((boulder-x)**2))
    KKNN_df$ice_closeness <- sapply(KKNN_df$ice, function(x) as.numeric((ice-x)**2))
    KKNN_df$alpine_closeness <- sapply(KKNN_df$alpine, function(x) as.numeric((alpine-x)**2))
    KKNN_df$snow_closeness <- sapply(KKNN_df$snow, function(x) as.numeric((snow-x)**2))
    KKNN_df$aid_closeness <- sapply(KKNN_df$aid, function(x) as.numeric((aid-x)**2))
    KKNN_df$mixed_closeness <- sapply(KKNN_df$mixed, function(x) as.numeric((mixed-x)**2))
    
    #calculate score
    print('calculating score')
    KKNN_df$score <- KKNN_df$average_closeness + KKNN_df$hardest_closeness + KKNN_df$route_count_closeness + KKNN_df$trad_closeness + KKNN_df$sport_closeness + KKNN_df$tr_closeness + KKNN_df$boulder_closeness + KKNN_df$ice_closeness + KKNN_df$alpine_closeness + KKNN_df$snow_closeness + KKNN_df$aid_closeness + KKNN_df$mixed_closeness
    
    #order by initial score and take first x results
    results <- 5000
    print('obtaining the first x results')
    KKNN_dfSub <- KKNN_df[order(KKNN_df$score),][1:results,]
    rm(KKNN_df)
    #list of routes from users
    print("obtaining list of routes from users")
    combinedList <- KKNN_dfSub$route_list
    combinedList <- sapply(combinedList, function(x) gsub("\\[|\\'|\\]|\\s", "", x) )
    combinedList <- sapply(combinedList, function(x) as.vector(unlist(strsplit(x,",")),mode="list") )
    
    rm(KKNN_dfSub)
    
    #flatten combinedList
    orderedList <- unlist(combinedList, recursive=TRUE, use.name=FALSE)
    
    #create rank list based on order in orderedList
    rank <- rev(seq(0, 1, by=(1/(length(orderedList)-1))))
    
    #combine lists into data frame
    KKNN_df2 <- data.frame(rank,orderedList)
    colnames(KKNN_df2) <- c('rank', 'route')
    
    #merge with route data
    KKNN_df2 <- merge(KKNN_df2, KKNN_dfRoute, all.x = TRUE, by.x ='route', by.y='id')
    
    #remove routes that user has already climbed
    KKNN_df2 <- subset(KKNN_df2, !(route %in% userList$name))
    
    #filter out routes with less than 10 votes
    KKNN_df2 = KKNN_df2[KKNN_df2$starVotes >= 10,]
    
    #calculate final score that will be used for recommendations
    KKNN_df2$final_score <- KKNN_df2$rank * KKNN_df2$stars
    
    #remove duplicate recommended routes
    KKNN_df2 <- KKNN_df2[!duplicated(KKNN_df2$route),]
    
    #replace NA routes with all types so they aren't left out
    # KKNN_df2$type[is.na(KKNN_df2$type)] <- 'Trad, Sport, Tr, Boulder, Ice, Alpine, Snow, Aid, Mixed'
    
    #user inputs
    route_type = 'Sport'
    
    #calculate distance from user location
    KKNN_df2$distance <- sapply(KKNN_df2$latitude, function(x) as.numeric((x-lat)**2)) + sapply(KKNN_df2$longitude, function(x) as.numeric((x-lon)**2))
    KKNN_df2$distance <- sapply(KKNN_df2$distance, function(x) as.numeric(sqrt(x)*69.0))
    
    #filter to results within distance
    KKNN_df2 <- KKNN_df2[KKNN_df2$distance <= dist,]
    
    #filter to results of specified type
    # KKNN_df2 <- KKNN_df2[str_detect(KKNN_df2$type, route_type),]
    
    #print x number of best results
    recommendations <- numofrecom
    final <- KKNN_df2[order(KKNN_df2$final_score, decreasing = TRUE),][1:recommendations,]
    final <- final[,c("route","name","stars","rank","final_score")]
    print(final)
    print(final$route)
    return(final$route)
  }}