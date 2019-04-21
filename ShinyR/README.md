# Rock Climbing Recommender System

## DESCRIPTION 

Drawing on the Mountain Project web application (https://www.mountainproject.com/), the goal of this project is to build a Recommender System (RS) to help rock climbers find climbing routes that are in their immediate geographical area and at or slightly above their current skill level. This RS will be built by clustering similar users together using several climbing metrics in order to help the user improve their climbing skills. This project will benefit rock climbers of all skill levels by identifying climbing routes that are custom-tailored to their individual interests and skill level. The Mountain Project has a large number of users, a portion of which might be interested in a tool like this. 

This repository contains datasets and R code necessary to run the Rock Climbing Recommender System locally. A live version of the web application can be viewed at: https://rockclimbingrecommender.shinyapps.io/RockClimbingRecommender/ 

## INSTALLATION

To install and load the recommender algorithm, download the folder to your local system. The most efficient way to run the app is to load the RockClimbingApp.R file into R Studio. The app has several dependencies in the form of R libraries; to see which packages must be installed, check out the top of the RockClimbingApp.R file. 

## EXECUTION 

As an R Shiny application, R Studio provides functionality to easily run the app locally by pressing the button “Run” button. The app will draw on the getgeo.R file as well as the Recommenders.r file for functions held within those scripts, and will present the app in a default browser.

## PROJECT CONTRIBUTORS
Oluwadamini Ajayi

Benjamin Croft

Joshua Demeo

Jeff Sayre

Jiandao Zhu

