
# ROCK CLIMBING RECOMMENDER APP
# CSE 6242 Group Project
# Spring 2019
# Team 137


####################### SET UP ENVIRONMENT ###############################

# Load libraries
library(shiny)
library(shinythemes)
library(leaflet)
library(DT)
library(ggplot2)
library(ggpubr)
library(ggvis)
library(stringr)
library(httr)
library(jsonlite)
library(mongolite)
library(RcppCNPy)
library(shinyalert)
source("getgeo.r")
source("recommenders.r")
library(dplyr)
library(shinyWidgets)

# Create global variables
print("Opening explorer data")
routesCleaned = data.frame(data.table::fread("routesCleanedWithLoc.csv"))
print("Explorer data ready")



## test code if you want to read any data from localhost
#mp_tick <- mongo(collection= "test3",
#                 db = "MP",
#                 url = "mongodb://localhost:27017",
#                verbose = TRUE)
#ticks <- mp_tick$find('{}')

# get route
ROUTE <- mongo(collection= "route",
               db = "MP",
               url = "mongodb://user1:cse6242@cluster0-shard-00-00-38kfo.mongodb.net:27017/?ssl=true",
               verbose = TRUE)

# routes <- ROUTE$find('{}')
# routes$rating
# 
# # get tick
TICK<- mongo(collection= "tick",
             db = "MP",
             url = "mongodb://user1:cse6242@cluster0-shard-00-00-38kfo.mongodb.net:27017/?ssl=true",
             verbose = TRUE)
# 
# ticks <- TICK$find('{}')
# 
# # get user
USER<- mongo(collection= "user",
             db = "MP",
             url = "mongodb://user1:cse6242@cluster0-shard-00-00-38kfo.mongodb.net:27017/?ssl=true",
             verbose = TRUE)

# users<- USER$find('{}')







####################### TEXT COMPONENTS ###############################

text1 <- ("American rock climbing is enjoying a boom in popularity - ballooning to 4.6 million total climbers in 2016 (CBJ, 2016). 
          The proliferation of rock climbing in recent years is exciting for both novices and seasoned climbers. 
          The large influx of newcomers and intermediate climbers has created an information gap. 
          More specifically, climbers may not have the information on how to advance their climbing skills efficiently and quickly, 
          which local routes to climb, and what routes other climbers around their skill level are climbing.")

text2 <- ("With the growth in climbing comes a vast increase in data collected on the activity. 
          In 2019, we have reached a critical mass of climbers which creates great potential for big data systems and visual analytics to 
          answer these questions and support climbing as a form of sport and recreation. 
          This project seeks to build a visual analytics system to help climbers build 
          their skills with achievable, challenging recommendations.")

text3 <- c("Drawing on the Mountain Project web application, the goal of this project is to build a Recommender System (RS) to help 
           rock climbers find climbing routes that are in their immediate geographical area and at or slightly above their current 
           skill level. This RS will be built by clustering similar users together using several climbing metrics in order to help 
           the user improve their climbing skills. This project will benefit rock climbers of all skill levels by identifying climbing 
           routes that are custom-tailored to their individual interests and skill level. The Mountain Project has a large number of 
           users, a portion of which might be interested in a tool like this.")

text4 <- c("<Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque vehicula facilisis maximus. Mauris dictum leo sed ex 
           elementum tristique. Suspendisse non metus finibus, fringilla ex eget, placerat lectus. Donec sed elit pharetra, bibendum 
           elit eget, pharetra velit. Nullam faucibus tincidunt nulla, in blandit metus tempus sed. Mauris tristique efficitur augue, 
           sed sollicitudin purus porttitor vel. Nam vitae bibendum enim. Donec magna sem, fringilla a quam eget, facilisis finibus mauris. 
           Aliquam et molestie ligula, ut feugiat nisl. Aenean nec semper lacus, eget venenatis leo. Duis libero libero, convallis sed 
           dapibus at, venenatis non augue. Aliquam sed turpis egestas magna facilisis interdum. Nullam imperdiet leo et quam cursus, id 
           porttitor elit pulvinar. Praesent non dapibus urna, nec varius quam. Cras tellus ante, elementum in venenatis id, molestie 
           sed turpis. Sed a ex et mi elementum luctus sed et lacus.")

text5 <- c("This project falls into the general category of designing RSs. RSs are subclasses of information filtering systems that seek to predict the 'rating' or 'preference' 
           a user would give to an item. The study of RSs is relatively new compared to other classical information system tools and techniques. 
           The topic emerged as a research area in the mid-1990s (Goldberg, 1992). 
           Among different techniques, collaborative filtering (CF) is the most popular of these strategies due to its domain-free nature (Dean, 2014). CF is a method of making automatic predictions (filtering) about the interests of a user by collecting preferences or taste information from many users (collaborating).")
text6 <- c("Shardanand and Maes (1995) designed a CF system for music (Ringo) and experimented with a number of measures of distance between users. They compared four different recommendation algorithms based on the Mean Absolute Error of predictions. Throughout the 2000s, RSs primarily focused on singular value decomposition systems, restricted Boltzmann machines, and neighborhood models to create user recommendations. Early RSs developed by Linden et al. (2003) used item-to-item CF, which finds items that have been purchased in tandem and have high similarity, and then recommends one item of the pair to a user who is purchasing or has purchased the other item in the pair. With regards to the project, this would be similar to using data regarding climbing routes and finding similar routes that have been done close in time. Also, Salakhutdinov et al. (2007) proposed restricted Boltzmann machines which essentially use a two-layer neural network that works similarly to an autoencoder by which latent features are learned by the network. Koren (2008) discussed the combination of latent factor and neighborhood recommendations to improve recommendation accuracy on the Netflix dataset. He provides a unique evaluation other than accuracy (RMSE) for the recommendation model by evaluating the top-k recommended items against items that are already highly rated (5-star). Both Salakhutdinov et al. and Koren provide foundational models by which to build our recommender system and metrics with which we can evaluate our models.")
text7 <- c("Shortly after, Koren et al. (2009) published on matrix factorization models that also incorporate normalization, item bias, and user bias to provide accurate recommendations. Cleger-Tamayo et al. (2010) uses a news recommendation sample problem to expand on clustering techniques that can be applied to CF methods. The sample shows how to formulate the calculation for the memory-based clustering algorithm which learns quickly, but is slow to make predictions. The memory-based algorithms predict a user rating for a particular item by using a similarity-weighted sum of the other user ratings. These predictions use the nearest K neighbors method or collaborative filter based on users. We will test our calculation algorithm based on memory and will optimize the algorithm by caching the predictions. Gannod et al. (2019) used a collaborative filtering method whereby recommendations were made using preferences and specified interests of nursing home residents to suggest person-centered care using association rules. While the authors’ sample size was only 255 residents, their recall and precision were both roughly 80%. The methods demonstrated in this paper contribute to the feasibility of the rock climbing project by illustrating ways to enhance preference capture.")
text8 <- c("Beyond CF, there exist alternative RSs that consider similarity distance (neighborhood-based) or explicit user preferences (content-based). Ye et al. (2018) describes how AirBNB uses analytics to suggest prices for listing hosts to optimize income. They split the problem into three parts: classification, regression based on class, and host personalization. This approach is limited to how effectively they can classify unique properties and understand their users. We can use parts of their approach, like personalizing recommendations beyond classification and regression based on how individual users have used the site. Christakopoulou et al. (2018) discusses how they collect user preferences with a chat bot to provide better recommendations to the user. This is limited by what the user prefers, but could be useful for tailoring our recommendations to users’ explicit inputs.")
text9 <- c("Other data sources such as geospatial data are used to make recommendations. Carmen, et al. (2015) provide an overview of Location-Aware RSs (LARS), grounding the mechanics of these systems in mobile computing. LARS utilizes geo-referenced data in order to provide recommendations to target consumers effectively and efficiently; this paper enumerates ways in which the rock climbing RS can use geo-referenced data effectively inside the GUI. Vías et al. (2018) describes a RS to manage the use of protected parks. Utilizing network analysis, multi-criteria decision analysis, and GIS, they determined that 34% of hikes in the mountain range were considered viable for hikers. This paper provides a foundation for outdoor recreation viability which lays the foundation for rock climbing RS in its methods and analysis. However, the authors’ RS is limited in that it focuses on viability rather than custom training routes, which is the primary goal of the rock climbing RS. An alternative approach would be the use of sentiment analysis to classify reviews as illustrated by Glorot et al. (2011). Sentiment analysis is limited by its ability to understand the user’s input which could be a significant limiting factor in areas such as climbing terminology, but could ultimately help distinguish between comparable routes.")
text10 <- c("Data visualization is another issue of the usability of product design. Karni and Shapira (2013) present an interactive visualization for RSs which enables a user to easily locate other users sharing similar interests. Given a user entity within a network, the system draws a graphical layout with users and interests that reflect relevance and similarity to the central user entity, a technique we can emulate in our project.")
text11 <- c("Through this review, CF has shown to be the dominant form of RSs. This technique will serve as a baseline for our model development. Blended models have historically performed with lower error rates (e.g. Netflix prize winners) so a combination of modern RSs that incorporate sentiment analysis, GIS data, and explicit user inputs to an application as presented prior will be tested in hopes of creating better quality recommendations than a CF model alone.")
text12 <- c("Carmen Rodríguez-Hernández, M., Ilarri, S., Lado, R. T., & Hermoso, R. (2015). Location-Aware Recommendation Systems: Where We Are and Where We Recommend to Go. In Proceedings of the 9th ACM Conference on Recommender Systems. Vienna, Austria. ")


cite_Blaszka <- p("Blaszka, D. (2017). Mountain Project Rock Climbing Route Recommmender. Retrieved from ", a("https://github.com/davidblaszka/redpointer/blob/master/CrispDm.md", href = "https://github.com/davidblaszka/redpointer/blob/master/CrispDm.md"))
cite_CBJ <- p("CBJ. (2016). More Climbers Than Ever. Retrieved from", a("http://www.climbingbusinessjournal.com/more-climbers-than-ever/", href = "http://www.climbingbusinessjournal.com/more-climbers-than-ever/"))
cite_Carmen <- p("Carmen Rodríguez-Hernández, M., Ilarri, S., Lado, R. T., & Hermoso, R. (2015). Location-Aware Recommendation Systems: Where We Are and Where e Recommend to Go. In Proceedings of the 9th ACM Conference on Recommender Systems. Vienna, Austria.")
cite_Christakopoulou <- p("Christakopoulou, K., Li, R., Jain, S., & Chi, E. H., (2018). Q&R: A Two-Stage Approach Toward Interactive Recommendation. In 24th ACM SIGKDD Conference on Knowledge Discovery and Data Mining (pp. 139-247). London, UK.")
cite_Cleger <- p("Cleger-Tamayo, S., Fernández-Luna, J. M.d, Huete, J. F., Pérez-Vázquez, R., & Rodríguez Cano, J. C. (2010). A Proposal for News Recommendation Based on Clustering Techniques. In International Conference on Industrial, Engineering and Other Applications of Applied Intelligent Systems (pp. 478–487). Berlin, Heidelberg: Springer Berlin Heidelberg.")
cite_Dean <- p("Dean, J., & Dean, J. (2014). Big Data, Data Mining, and Machine Learning : Value Creation for Business Leaders and Practitioners. Somerset, USA: John Wiley & Sons, Incorporated.")
cite_Gannod <- p("Gannod, G., Abbott, K., Haitsma, K. Martindale, N., & Heppner, A. (2019). A Machine Learning Recommender System to Tailer Preference Assessments to Enhance Person-Centered Care Among Nursing Home Residents. In The Gerontologist, 59(1), (pp. 167-176). Retrieved from ", a("https://doi-org.libproxy.boisestate.edu/10.1093/geront/gny056", href = "https://doi-org.libproxy.boisestate.edu/10.1093/geront/gny056"))
cite_Glorot <- p("Glorot, X., Bordes, A., & Bengio, Y. (2011). Domain Adaptation for Large-scale Sentiment Classification: A Deep Learning Approach. In Proceedings of the 28th International Conference on International Conference on Machine Learning (pp. 513–520). USA: Omnipress.")
cite_Goldberg <- p("Goldberg, D., Nichols, D., Oki, B. M., & Terry, D. (1992). Using Collaborative Filtering to Weave an Information Tapestry. Communications of the ACM, 35(12), 61–70. Retrieved from ", a("https://doi.org/10.1145/138859.138867", href = "https://doi.org/10.1145/138859.138867"))
cite_Karni <- p("Karni, Z., & Shapira, L. (2013). Visualization and exploration for recommender systems in enterprise organization. In Proceedings of Imaging and Printing in a Web 2.0 World IV, (Vol. 8664). Burlingame, USA.", a("https://doi.org/10.1117/12.2013859", href = "https://doi.org/10.1117/12.2013859"))
cite_Koren1 <- p("Koren, Y. (2008). Factorization Meets the Neighborhood: A Multifaceted Collaborative Filtering Model. In Proceedings of the 14th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (pp. 426–434). New York, NY, USA: ACM. Retrieved from ", a("https://doi.org/10.1145/1401890.1401944", href = "https://doi.org/10.1145/1401890.1401944"))
cite_Koren2 <- p("Koren, Y., Bell, R., & Volinsky, C. (2009). Matrix Factorization Techniques for Recommender Systems. Computer, 42(8), 30–37. Retrieved from ", a("https://doi.org/10.1109/MC.2009.263", href = "https://doi.org/10.1109/MC.2009.263"))
cite_Linden <- p("Linden, G., Smith, B., & York, J. (2003). Amazon.com recommendations: item-to-item collaborative filtering. IEEE Internet Computing, 7(1), 76–80. Retrieved from ", a("https://doi.org/10.1109/MIC.2003.1167344", href = "https://doi.org/10.1109/MIC.2003.1167344"))
cite_Salakhutdinov <- p("Salakhutdinov, R., Mnih, A., & Hinton, G. (2007). Restricted Boltzmann Machines for Collaborative Filtering. In Proceedings of the 24th International Conference on Machine Learning (pp. 791–798). New York, NY, USA: ACM. Retrieved from ", a("https://doi.org/10.1145/1273496.1273596", href = "https://doi.org/10.1145/1273496.1273596"))
cite_Shardanand <- p("Shardanand, U., & Maes, P. (1995). Social information filtering: algorithms for automating “word of mouth.” In Proceedings of the SIGCHI Conference on Human Factors in Computing Systems (pp. 210–217). New York, NY, USA: ACM Press/Addison-Wesley Publishing Co. ", a("https://doi.org/10.1145/223904.223931", href = "https://doi.org/10.1145/223904.223931"))
cite_Vias <- p("Vías, J., Rolland, J., Gómez, M. L., Ocaña, C., & Luque, A. (2018). Recommendation system to determine suitable and viable hiking routes: a prototype application in Sierra de las Nieves Nature Reserve (southern Spain). Journal of Geographical Systems, 20(3), 275–294. ", a("https://doi.org/10.1007/s10109-018-0271-8", href = "https://doi.org/10.1007/s10109-018-0271-8"))
cite_Ye <- p("Ye, P., Qian, J., Chen, J., Wu, C., Zhou, Y., & Mars, S. De. (2018). Customized Regression Model for Airbnb Dynamic Pricing. In 24th ACM SIGKDD Conference ON Knowledge Discovery and Data Mining (pp. 936–940). London, UK.")









####################### APP UI ###############################

# Define UI for application
ui <- navbarPage("Rock Climbing Recommender",
                 tabPanel("Overview",
                          sidebarLayout(position = "right",
                                        mainPanel(
                                          h2("Project Overview"),
                                          em("'Each fresh peak ascended teaches something.'"), br(), " -- Sir Michael Convay", br(), br(),
                                          text1, text2, br(), br(),
                                          text3, br(), br(),
                                          h2("How it works"), 
                                          p("Using the user tick data, we created a user-route matrix.  This constituted a sparse matrix where each element in the matrix represents a user’s rating of a route they have done."),
                                          img(src = "sparse_matrix.png"),
                                          br(),
                                          p("Most of the elements have no ratings because of the nature of the data. After preprocessing to remove any duplicate information inherent to the data and removal of ratings of -1 (Mountain Project placeholder for no rating), the final matrix was formed. This was used as the input for SVD to construct the latent factor matrices. SVD is a matrix factorization technique by which a larger matrix can be represented by two smaller matrices. The implementation of SVD used for our final models is that of Koren et al. (2009) where a prediction is given by the equation:"), 
                                          img(src = "equation1.png"),
                                          br(),
                                          p("A prediction for the rating a user gives to a route is given by (rui) which is the summation of the mean rating of all the ratings (), the bias of the user (bu), the bias for the particular route (bi), and the dot product of the latent route matrix (qiT) and latent user matrix (pu). The SVD algorithm goes through a specified number of iterations of stochastic gradient descent to minimize a regularized squared error between the known user-matrix ratings and those predicted for those ratings, which is given by the equation:"),
                                          img(src = "equation2.png"),
                                          p("From these latent factor matrices, a reconstruction of the user-route matrix can be made, which contains predictions of ratings for the routes not attempted by each user. Highly rated routes not attempted by a particular user can then be used as a recommendation for that particular user and it can be further filtered down to only include those routes that are within a certain distance of a location."),
                                          p("In order to ensure an optimal recommendation system, we pursued both a KNN as well as SVD solution. To build the KNN model, we start by cleaning the data and providing a numerical floating point value for the standard rock climbing scale (ie: 5.6+, 5.10a, etc…). This helps with numerically defining a user’s average difficulty and hardest difficulty completed for routes they have done. The number of counts for each type of route completed are determined. These features help to define our users and represent inputs to our model. We then normalize all the data to values between 0 and 1 to allow comparison between dissimilar features. Finally, given a particular user, we calculate distances between their values (primary user) and everyone else’s (comparative user) for 12 attributes (i.e: average difficulty, hardest difficulty, route count, etc…). This is done with the distance function:"),
                                          img(src = "equation3.png"),
                                          p("By using this distance function, the algorithm effectively prioritizes similarity, by making the penalty for dissimilarity quadratic. In practice, this has allowed us to select extremely similar users for our KNN recommender system. After calculating and summing the attributes’ similarity scores, we sort the output and get routes from the most similar users. We then calculate a final score by multiplying the average rating for a route, by the users similarity score, to find the routes that similar users found very enjoyable. These selected routes are then filtered by location and type of climb, based on user input in order to come up with final recommendations."),
                                          br()
                                          
                                          
                                          ),
                                        
                                          sidebarPanel(width = 2, 
                                          img(src ="gt_logo.svg", height = 150, width = 150),
                                          h3("CSE 6242 Team #137"),
                                          h4(em(("Spring 2019"))),
                                          br(),
                                          strong("Damini Ajayi"), br(),
                                          c("User: oajayi34"),
                                          br("Email: daminiajayi@gmail.com"), br(),
                                          strong("Ben Croft"), br(),
                                          c("User: bcroft3"),
                                          br("Email: benjaminhcroft@gmail.com"), br(),
                                          strong("Joshua Demeo"), br(),
                                          c("User: jdemeo3"),
                                          br("Email: jdemeo91@gmail.com"), br(),
                                          strong("Jeff Sayre"), br(),
                                          c("User: jsayre6"),
                                          br("Email: jpsayre@gmail.com"), br(),
                                          strong("Jiandao Zhu"), br(),
                                          c("User: jzhu373"),
                                          br("Email: jiandaoz@gmail.com"), br()
                                        )
                          )
                 ),

                 tabPanel("Recommendation Map",
                          useShinyalert(),
                          sidebarLayout(position = "right", 
                                        mainPanel(
                                          h3("Recommender Map"),
                                          p(),
                                          leafletOutput("mymap", height = 600),
                                          br(),
                                          em("All latitude and longitude coordinates for routes were directly obtained from the Mountain Project and were not verified for location accuracy."),
                                          br(), br(), 
                                          DT::dataTableOutput("table")
                                        ),
                                        sidebarPanel(width = 3,
                                          # Sidebar heading
                                          h3("Recommender"),
                                          em("To receive custom recommendations for future climbs, enter the following fields and press Submit:"), p(), br(),
                                          ## File upload
                                          #fileInput("file", "Upload data"),
                                          # Enter user id
                                          textInput("userid", "User ID:", value = 105794406),
                                          textInput("cityname", "City, State:", value = 'Seattle, WA'),
                                          textInput("searchradius", "Routes search radius (mi)", value = 100),
                                          sliderInput("numofrecom", "Number of recommendations:",
                                                      min = 1, max = 100, value = 5,step =1),
                                          actionButton("search", "Search"),
                                          
                                          h3("Filter"),
                                          em("To narrow down the recommendations, adjust the following parameters:"), p(), br(),
                                          # Minimum rating (stars)
                                          sliderInput("rating", "Minimum Stars", min = 0, max = 5, value = 0,step=0.5),
                                          # Selector for type of climb
                                          radioButtons("type", "Type of Climb", choices = c("All","Aid","Alpine", "Boulder","Ice","Mixed", "Rock","Snow" , "Sport","TR","Trad"), selected = "All"),
                                          sliderInput("pitches", "No. of Pitches", min = 0, max = 10, value = 0,step=1),
                                          # # Slider for V-level (whatever that is)
                                          # sliderInput("vlevel", "V Level", min = 0, max = 14, value = c(3, 5)),
                                          actionButton("filter", "Filter")))),

                 tabPanel("Route Explorer",
                          sidebarLayout(position = "right",
                                        mainPanel(
                                          h2("Route Explorer"),
                                          br(),
                                          p("Use the route explorer as an alternative to the recommender system. You can refine these routes by type, number of pitches, rating, and votes. Once the filters you choose are applied, you can visually see all of the routes that match your choices. The bottom left corner being poorly rated, with less votes, and the top right corner being highly rated with more votes. You can also see the number of pitches represented by color. Just hover any route that interests you for more details."),
                                          br(),
                                          ggvisOutput("explorer_plot")
                                          ),
                                        sidebarPanel(
                                          # Sidebar heading
                                          h2("Controls"),
                                          # Number of pitches
                                          sliderInput("explorer_pitches", "Number of Pitches", min = 0, max = 10, value = c(3, 5)),
                                          # Selector for type of climb
                                          radioButtons("explorer_type", "Type of Climb", choices = c("All","Aid", "Alpine", "Boulder", "Ice", "Mixed", "Rock", "Sport", "Trad"), 
                                                       selected = "All"),
                              
                                          # Star votes
                                          sliderInput("explorer_stars", "Select star votes", min = 0, max = 1606, value = c(500, 700)),
                                          # Star rating
                                          sliderInput("explorer_star_rating", "Select star rating", min = 0, max = 5, value = c(3.5, 4.5))
                                        ))),
                 tabPanel("References",
                          fluidRow(
                            column(1),
                            column(3, 
                                   h2("Works Cited"),
                                   cite_Blaszka, br(), 
                                   cite_CBJ, br(), 
                                   cite_Carmen, br(), 
                                   cite_Christakopoulou, br(), 
                                   cite_Cleger, br(), 
                                   cite_Dean, br(),
                                   cite_Gannod, br(),
                                   cite_Glorot, br(),
                                   cite_Goldberg, br(),
                                   cite_Karni, br(),
                                   cite_Koren1, br(),
                                   cite_Koren2, br(),
                                   cite_Linden, br(),
                                   cite_Salakhutdinov, br(),
                                   cite_Shardanand, br(),
                                   cite_Vias, br(),
                                   cite_Ye 
                            ),
                            column(1),
                            column(5,
                              img(src ="photo.jpg", height = 600, width = 900),
                              h2("Review of Literature"),
                              text5, br(), br(),
                              text6, br(), br(),
                              text7, br(), br(), 
                              text8, br(), br(),
                              text9, br(), br(),
                              text10, br(), br(),
                              text11, br(), p("      "), br(), br()
                            )
                          )
                 ),
                 theme = shinytheme("flatly")
)





####################### APP SERVER ###############################


# Define server logic required to draw a histogram
server <- function(input, output) {
  data <- reactiveValues(dataframe = NULL,df_sub=NULL)

  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      setView(lng = -98, lat = 39, zoom = 4) %>%
      addProviderTiles(providers$Esri.WorldTopoMap, 
                       options = providerTileOptions(noWrap = TRUE)) %>%
      addMiniMap() 
  })
  
  
  # Initital recommender algorithm
  observeEvent(input$search, {
    cityname <- isolate(input$cityname)
    userid <- isolate(input$userid)
    userid=str_replace_all(userid, fixed(" "), "")
    searchradius <- isolate(input$searchradius)
    numofrecom <- isolate(input$numofrecom)
    
    long_lat<- getgeo(cityname)
    #print(paste0("Latitude is: ", long_lat[2][1]))
    
    # Error: Case 1
    if(long_lat[1]=="NULL" | long_lat[2]=="NULL"){
      shinyalert("Oops!", "City not found. Please check spelling.", type = "error")
    }
    

    else{
      #print("Getting tick data for user")
      # userid <- 200220441
      ticks <- TICK$find(paste0('{"user":','"', userid, '"}'))
      
      # Run SVD on power users (users with over 100 routes)
      if(length(ticks$ticks[[1]]$routeId) >= 100){
        print("Running SVD code")
        # svd_setup()

        routeid <- getroutesid(userid, long_lat[[1]], long_lat[[2]], searchradius, numofrecom)
        
      # Run kNN on small users (users with less than 100 routes)
      } else if(length(ticks$ticks[[1]]$routeId) < 100 & length(ticks$ticks[[1]]$routeId) >=2) {
        print("running KNN code")
        routeid <- getKNN(userid, long_lat[[1]], long_lat[[2]], searchradius, numofrecom
        )
      }
      
      # Error: Case 3 - users with less than 2 recommendations
      else{
        shinyalert("Oops!", "You need to have at least two ratings to have recommendations.", type = "error")
      }
      
      
      routeid <- routeid[!is.na(routeid)]
      
      if (length(routeid)==0 |is.null(routeid)){
        shinyalert("Oops!", "No routes are found, please increase search radius or change the city.", type = "error")
        
      }
      else{
        print("Writing output to dataframe")  
        
        dataframe <- NULL
        for (ir in 1:length(routeid)){
          route <- ROUTE$find(paste0('{"id" : ', routeid[ir], '}'))
          # print(colnames(route))
          content<- paste(
            "<b><a href=",
            route$url,
            ">",
            route$name,
            "</a></b>",
            "<br/>Type:",
            route$type,
            "<br/>Stars:",
            route$stars,
            "<br/>Rating:",
            route$rating)
          name <- route$name
          state <- route$location[[1]][1]
          longitude <- route$longitude
          latitude <- route$latitude
          type <- route$type
          stars <- route$stars
          votes <- route$starVotes
          pitches <- route$pitches
          url <- route$url
          id <- route$id
          rating <- route$rating
          
          if (pitches ==""){pitches <- 0}
          dataframe=rbind(dataframe,data.frame(content, longitude, latitude, name, state, type, rating, pitches, stars, votes, url))
        }
        data$dataframe <- dataframe
        createLink <- function(url){
          sprintf(paste0('<a href="', URLdecode(url),'" target="_blank">','</a>'))
          
        }

        output$mymap <- renderLeaflet({
          leaflet(dataframe) %>%
            #setView(lng = longitude, lat = latitude, zoom = 7) %>%
            addProviderTiles(providers$Esri.WorldTopoMap, 
                             options = providerTileOptions(noWrap = TRUE)) %>%
            addPopups(lng = dataframe$longitude, lat = dataframe$latitude, dataframe$content) %>%
            addMarkers(lng = dataframe$longitude, lat = dataframe$latitude, popup = dataframe$content) %>%
            addMiniMap() 
        })
        
        output$table <- DT::renderDataTable({
          
          m <- dataframe[,c("name","state","type","pitches","stars","votes", "rating", "url")]
          m$url <- paste0("<a href='",m$url,"' target='_blank'>",m$url,"</a>")
          my_table <- DT::datatable(m, escape = FALSE, colnames = c("Route Name", "State", "Climb Type", "Pitches", "Stars", "Votes", "Rating", "Link"))
          my_table
          
        })
        
      }
    }
  })


  observeEvent(input$filter, {
    if (!is.null(data$dataframe) ){
      output$mymap <- renderLeaflet({
        selectrating <- isolate(input$rating)
        selectpitches <- isolate(input$pitches)
        # selectlocation <- isolate(input$location)
        selecttype <- isolate(input$type)
        dataframe <- data$dataframe
        print(dataframe)
        df_sub <- subset(dataframe,stars>=selectrating)
        df_sub <- subset(df_sub,pitches>=selectpitches)
        # if(selectlocation !="" & selectlocation !="All"){
        #   df_sub <- subset(df,state==selectlocation)
        # }
        
        if(selecttype !="All"){
          print(selecttype)
          df_sub <- df_sub %>% filter(str_detect(type, selecttype))
        }     
        data$df_sub <- df_sub
        leaflet(data = df_sub) %>%
          #setView(lng = -98, lat = 39, zoom =4) %>%
          
          addProviderTiles(providers$Esri.WorldTopoMap, 
                           options = providerTileOptions(noWrap = TRUE)) %>%  
          
          addMarkers(lng = 	df_sub$longitude, lat = df_sub$latitude, popup = df_sub$content) %>%
          addMiniMap()  
        
      })
      output$table <- DT::renderDataTable({
        DT::datatable(data$df_sub[,c("name","state","type","pitches","stars","votes")])
      })
    }
    else{
      shinyalert("Oops!", "Please run recommendation before filter.", type = "error")
    }
    
  })
  
  
  
  ####################### SERVER: ROUTE EXPLORER ###############################
  
  
  routes <- reactive({
    # Get user inputs
    pitches_min <- input$explorer_pitches[1]
    pitches_max <- input$explorer_pitches[2]
    starVotes_min <- input$explorer_stars[1]
    starVotes_max <- input$explorer_stars[2]
    starRating_min <- input$explorer_star_rating[1]
    starRating_max <- input$explorer_star_rating[2]
    type <- input$explorer_type
    
    # Filter star votes, star rating, and number of pitches
    d <- routesCleaned %>%
      filter(starVotes >= starVotes_min,
             starVotes <= starVotes_max,
             stars >= starRating_min,
             stars <= starRating_max,
             pitches >= pitches_min,
             pitches <= pitches_max
      )
    
    if (type == "Trad"){
      d <- d %>% filter(Trad == 1)
    } else if (type == "Sport"){
      d <- d %>% filter(Sport == 1)
    } else if (type == "Boulder"){
      d <- d %>% filter(Boulder == 1)
    } else if (type == "Alpline"){
      d <- d %>% filter(Alpline == 1)
    } else if (type == "Ice"){
      d <- d %>% filter(Ice == 1)
    } else if (type == "Mixed"){
      d <- d %>% filter(Mixed == 1)
    } else if (type == "Snow"){
      d <- d %>% filter(Snow == 1)
    } else if (type == "All"){
      d <- d
    } else {
      d <- d %>% filter(Aid == 1)
    }
  })
  
  
  # TOOLTIP FOR EXPLORER
  explorer_tooltip <- function(x) {
    if(is.null(x)) return(NULL)
    if(is.null(x$id)) return(NULL)
    dat = routes()
    row = dat[dat$id %in% x$id, ]
    paste0("<b>", "Route Name: ", row$name, "</b><br>",
           "Star Votes: ", row$starVotes, "<br>",
           "Star Score: ", row$stars, "<br>",
           "Rating: ", row$rating, "<br>",
           "Pitches: ", row$pitches)
  }

  vis <- reactive({
    routes %>%
      ggvis(~starVotes, ~stars, key := ~id) %>%
      layer_points(size := 100, size.hover := 200,
                   fillOpacity := 0.2, fillOpacity.hover := 0.5,
                   stroke = ~pitches, fill = ~pitches, key := ~id) %>%
      add_tooltip(explorer_tooltip, "hover") %>%
      add_axis("x", title = "Number of Star Ratings") %>%
      add_axis("y", title = "Star Rating") %>%
      set_options(width = 1000, height = 750)
  })

  vis %>% bind_shiny("explorer_plot")
}







####################### APP EXECUTION ###############################

# Run the application 
shinyApp(ui = ui, server = server)








