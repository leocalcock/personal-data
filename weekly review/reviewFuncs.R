# Script for management of functions for weekly reviews
#
#

library(knitr)

#Assumes posixct or character as class of date
pullReview <- function(date, reviewDir = getwd(), template = "std_template"){
      templ <- file(paste0(reviewDir,"/templates/",template,".Rmd"))
      r <- readLines(templ)
      close(templ)
      if(class(date)!="character"){
            date <- format(date,"%Y-%m-%d")
      }
      r <- gsub("%weekOfDate%",date, r)
      reviewFile <- file(paste0(reviewDir,"/review source/Review",date,".Rmd"))
      writeLines(r, reviewFile)
      close(reviewFile)
}

pubReview <- function(){
      
}