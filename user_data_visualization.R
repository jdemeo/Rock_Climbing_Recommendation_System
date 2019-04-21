setwd("/Users/jad/apptown/CSE_6242/climbing")

library(mongolite)
library(ggplot2)

# Setup connection to routes collection
ROUTES <- mongo(collection= "route",
               db = "MP",
               url = "mongodb://user1:cse6242@cluster0-shard-00-00-38kfo.mongodb.net:27017/?ssl=true",
               verbose = TRUE)

# Get Ticks of Current User
TICKS <- mongo(collection= "tick",
             db = "MP",
             url = "mongodb://user1:cse6242@cluster0-shard-00-00-38kfo.mongodb.net:27017/?ssl=true",
             verbose = TRUE)

start_time <- Sys.time()

# Collect Routes the User has completed
userID <- "107153125"
user_tick_data <- TICKS$find(paste0('{"user":\"', userID, '"}'))
user_ticks_df <- data.frame()
# Collect ticks from each document and add to dataframe
for (tick_document in user_tick_data$ticks) {
  user_ticks_df <- rbind(user_ticks_df, tick_document)
}

# Get list of routes in a proper string format for mongodb query
long_string <- "["
for (route in user_ticks_df$routeId) {
  long_string <- paste0(long_string, route, ", ")
}
long_string <- substr(long_string, start=1, stop = nchar(long_string) - 2)
long_string <- paste0(long_string, "]")

# Get Route data
route_df <- ROUTES$find(paste0('{"id":{"$in":', long_string,'}}'))
route_df$routeId <- route_df$id   # For easier merging of datasets

# Merge DataFrames; essentially 
routes_completed_df <- merge(user_ticks_df[c("routeId", "date")], route_df, by="routeId")
routes_completed_df <- routes_completed_df[c("routeId", "date", "stars", "starVotes", "pitches")]

# Load in cleaned up difficulty ratings
cleaned_ratings <- read.csv("cleaned_route_difficulty.csv")
cleaned_ratings <- cleaned_ratings[c("id", "rating", "type")]       #subset
cleaned_ratings$routeId <- cleaned_ratings$id

routes_completed_df <- merge(routes_completed_df, cleaned_ratings, by="routeId")
routes_completed_df $date <- as.Date(routes_completed_df$date, '%Y-%m-%d')


# Subset data by type completed
climbing_types <- unique(routes_completed_df$type)

# IDK HOW TO MAKE SUBPLOTS
# Make plot for each type of climbing; y-metrics = ["rating", "stars", "starVotes", "pitches"]
# rating == difficult of route; currently data is too dirty to be useful
y_metric <- "rating"
for (climb_type in climbing_types[1]) {
  print(climb_type)
  # Build time series plot
  plot <- ggplot(data = routes_completed_df[routes_completed_df$type == climb_type, ], 
                 aes_string(x="date", y=y_metric)) +
    geom_point(shape=1) +
    scale_x_date(date_breaks = "1 month") + 
    theme(axis.text.x = element_text(angle=90, hjust=1))
  print(plot)
}

end_time <- Sys.time()
end_time - start_time      # Time to run code

