#BUGGY get request with my password/user and a task
library(httr)
library(jsonlite)


# path is path to the data folder.
setup <- function(user, pw, path = "../data"){
      if(!file.exists(paste0(path,"/habitica"))){
            p2 <- paste0(path,"/habitica")
            dir.create(p2)
            
            dir.create(paste0(p2,"/metadata"))
            fc <- file(paste0(p2,"/metadata/userpw.txt"))
            writeLines(c(user,pw),fc)
            close(fc)
            
            fc2 <- file(paste0(p2,"/taskIDs.json"))
            writeLines(c("{\"id\":[]}"), fc2)
            close(fc2)
      }else{
            print("habitica already set up.")
      }
}


#gets username and password to interact with api
readUserPw <- function(){
      dt <- read.table("../data/habitica/metadata/userpw.txt", sep = "\t")
      user = toString(dt[1,1])
      pw = toString(dt[2,1])
      c(user,pw)
}


# getTask via GET request from habitica based on taskID
getTask <- function(taskID, user = NULL, pw = NULL){
      ret = NULL
      if(is.null(user)){
            x <- readUserPw()
            user <- x[1]
            pw <- x[2]
      }
      gr <- GET(paste0("https://habitica.com/api/v3/tasks/", taskID),
                add_headers(.headers = c("x-api-user" = user,"x-api-key" = pw)))
      if(gr$status_code == 200){
            ret = content(gr,"text")
      }
      ret
}

# getTasks gets all task data from user, pw
getTasks <- function(user = NULL, pw = NULL){
      ret = NULL
      if(is.null(user)){
            x <- readUserPw()
            user <- x[1]
            pw <- x[2]
      }
      gr <- GET("https://habitica.com/api/v3/tasks/user",
                add_headers(.headers = c("x-api-user" = user,"x-api-key" = pw)))
      if(gr$status_code == 200){
            ret = content(gr,"text")
      }
      ret
}
