#BUGGY get request with my password/user and a task
library(httr)
library(jsonlite)


# path is path to the data folder. currently does not install R packages
setup <- function(user, pw, path = "../data"){
      if(!file.exists(paste0(path,"/habitica"))){
            p2 <- paste0(path,"/habitica")
            dir.create(p2)
            
            dir.create(paste0(p2,"/metadata"))
            fc <- file(paste0(p2,"/metadata/userpw.txt"))
            writeLines(c(user,pw),fc)
            close(fc)
            
            fc2 <- file(paste0(p2,"/taskIDs.json"))
            writeLines(c("{\"ids\":[]}, \"variables\":[]}"), fc2)
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
            ret = content(gr,"text","fromJSON")
      }
      ret
}

#id extraction to inform what to keep track of! ! !
#for now, a task can only be linked to one variable (I'll almost certainly change this.)
setTasks <- function(uspw = NULL, overwrite = T, path = "../data/habitica"){
      gt <- NULL
      if(is.null(uspw)){
            gt <- getTasks()
      }else {
            gt <- getTasks(uspw[1],uspw[2])
      }
      
      data <- fromJSON(gt)$data
      notes <- data$notes
      ids <- data$id
      #finds which vars to track based on note
      track <- function(note){
            if(note==""){
                  c(F, NULL)
            }else{
                  splt <- strsplit(note,"\n")[[1]]
                  line <- splt[length(splt)]
                  c(substr(line,1,1)=="#", substr(line,2,nchar(line)))
            }    
      }
      #go through notes to find ids, and etc. to append
      idLs <- vector("character",0)
      varLs <- vector("character",0)
      vars <- list()
      #looping through entries
      for(i in 1:length(notes)){
            t <- track(notes[i])
            if(t[1]){
                  #print(paste("SUCCESSSSS",ids[i]))
                  idLs <- c(idLs,as.character(ids[i]))
                  v <- t[2]
                  if(v %in% varLs){
                        print("WHYYYY")
                        index <- which(v==varLs)
                        vars[[index]]$ids <- c(vars[[index]]$ids,ids[i])
                  }else{
                        varLs <- c(varLs,v)
                        vars[[length(varLs)]] <- list(varname = as.character(v), ids = c(ids[i]))
                  }
            }
      }
      js <- as.character(toJSON(list(ids = idLs,variables = vars), pretty = T))
      fc <- file(paste0(path,"/taskIDs.json"))
      writeLines(js,fc)
      close(fc)
}


