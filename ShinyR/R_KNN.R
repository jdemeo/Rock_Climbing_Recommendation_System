setwd("~/Documents/CSE6242")
library("stringr", lib.loc="/Library/Frameworks/R.framework/Versions/3.5/Resources/library")

#read data
df <- read.csv('processedData.csv')
dfRoute <- read.csv('routeData.csv')

#normalize data
df$trad <- (df$trad-min(df$trad))/(max(df$trad)-min(df$trad))
df$sport <- (df$sport-min(df$sport))/(max(df$sport)-min(df$sport))
df$tr <- (df$tr-min(df$trad))/(max(df$tr)-min(df$tr))
df$boulder <- (df$boulder-min(df$boulder))/(max(df$boulder)-min(df$boulder))
df$ice <- (df$ice-min(df$ice))/(max(df$ice)-min(df$ice))
df$alpine <- (df$alpine-min(df$alpine))/(max(df$alpine)-min(df$alpine))
df$snow <- (df$snow-min(df$snow))/(max(df$snow)-min(df$snow))
df$aid <- (df$aid-min(df$aid))/(max(df$aid)-min(df$aid))
df$mixed <- (df$mixed-min(df$mixed))/(max(df$mixed)-min(df$mixed))
df$average <- (df$average-min(df$average))/(max(df$average)-min(df$average))
df$hardest <- (df$hardest-min(df$hardest))/(max(df$hardest)-min(df$hardest))
df$route_count <- (df$route_count-min(df$route_count))/(max(df$route_count)-min(df$route_count))

#define current user
currentUser <- 107829049

#get row for current user
user_list <- head(df[df$user == currentUser,], n = 1)

#Only run if route count is less than specified (normalized on 0 to 200 scale)
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
df$average_closeness <- sapply(df$average, function(x) as.numeric((average-x)**2))
df$hardest_closeness <- sapply(df$hardest, function(x) as.numeric((hardest-x)**2))
df$route_count_closeness <- sapply(df$route_count, function(x) as.numeric((count-x)**2))
df$trad_closeness <- sapply(df$trad, function(x) as.numeric((trad-x)**2))
df$sport_closeness <- sapply(df$sport, function(x) as.numeric((sport-x)**2))
df$tr_closeness <- sapply(df$tr, function(x) as.numeric((tr-x)**2))
df$boulder_closeness <- sapply(df$boulder, function(x) as.numeric((boulder-x)**2))
df$ice_closeness <- sapply(df$ice, function(x) as.numeric((ice-x)**2))
df$alpine_closeness <- sapply(df$alpine, function(x) as.numeric((alpine-x)**2))
df$snow_closeness <- sapply(df$snow, function(x) as.numeric((snow-x)**2))
df$aid_closeness <- sapply(df$aid, function(x) as.numeric((aid-x)**2))
df$mixed_closeness <- sapply(df$mixed, function(x) as.numeric((mixed-x)**2))

#calculate score
df$score <- df$average_closeness + df$hardest_closeness + df$route_count_closeness + df$trad_closeness + df$sport_closeness + df$tr_closeness + df$boulder_closeness + df$ice_closeness + df$alpine_closeness + df$snow_closeness + df$aid_closeness + df$mixed_closeness

#order by initial score and take first x results
results <- 5000
dfSub <- df[order(df$score),][1:results,]

#list of routes from users
combinedList <- dfSub$route_list
combinedList <- sapply(combinedList, function(x) gsub("\\[|\\'|\\]|\\s", "", x) )
combinedList <- sapply(combinedList, function(x) as.vector(unlist(strsplit(x,",")),mode="list") )

#flatten combinedList
orderedList <- unlist(combinedList, recursive=TRUE, use.name=FALSE)

#create rank list based on order in orderedList
rank <- rev(seq(0, 1, by=(1/(length(orderedList)-1))))

#combine lists into data frame
df2 <- data.frame(rank,orderedList)
colnames(df2) <- c('rank', 'route')

#merge with route data
df2 <- merge(df2, dfRoute, all.x = TRUE, by.x ='route', by.y='id')

#remove routes that user has already climbed
df2 <- subset(df2, !(route %in% userList$name))

#filter out routes with less than 10 votes
df2 = df2[df2$starVotes >= 10,]

#calculate final score that will be used for recommendations
df2$final_score <- df2$rank * df2$stars

#remove duplicate recommended routes
df2 <- df2[!duplicated(df2$route),]

#replace NA routes with all types so they aren't left out
# df2$type[is.na(df2$type)] <- 'Trad, Sport, Tr, Boulder, Ice, Alpine, Snow, Aid, Mixed'

#user inputs
lat <- 40.7564
lon <- -111.8986
dist <- 25.0 #in miles
route_type = 'Sport'

#calculate distance from user location
df2$distance <- sapply(df2$latitude, function(x) as.numeric((x-lat)**2)) + sapply(df2$longitude, function(x) as.numeric((x-lon)**2))
df2$distance <- sapply(df2$distance, function(x) as.numeric(sqrt(x)*69.0))

#filter to results within distance
df2 <- df2[df2$distance <= dist,]

#filter to results of specified type
df2 <- df2[str_detect(df2$type, route_type),]

#print x number of best results
recommendations <- 10
final <- df2[order(df2$final_score, decreasing = TRUE),][1:recommendations,]
final <- final[,c("route","name","stars","rank","final_score")]
print(final)

}
