#BUGGY get request with my password/user and a task
library(httr)
library(jsonlite)
library(data.table)

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
            ret = content(gr,"text","fromJSON")
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
                  idLs <- c(idLs,as.character(ids[i]))
                  v <- t[2]
                  if(v %in% varLs){
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

#Beginning of collecting data (to be run after setTasks()) weekOf in format %Y-%m-%d
collectData <- function(weekOf = "",tz = Sys.timezone(), pathPre = "../data/habitica/data"){
      day = 86400 # number of seconds in a week. 
      if(weekOf!=""){
            t1 <- as.POSIXct(weekOf)
            DT <-cData(t1,7, path = paste0(pathPre,"/Hab",weekOf,".csv"))
            DT
      }else{
      NULL}
}
#t1, POSIXct format, path = path to file to write data to. for now collects tables for day by day. 
cData <- function(t1, days, path, uspw = NULL){
      if(is.null(uspw))uspw <- readUserPw()
      day <- 86400
      fi <- file("../data/habitica/taskIDs.json")# made need to add an argument for this.
      txt <- readLines(fi)
      close(fi)
      taskMeta <- fromJSON(txt)$variables
      d1 <- as.numeric(t1)
      unT <- vector(mode = "numeric",length = 0)
      for(i in 1:days){
            unT <- c(unT,d1)
            d1 <- d1+day
      }
      #print(taskMeta)
      vars <- taskMeta$varname
      DT <- data.table(unixTime = unT)
      DT[,date:=format(as.POSIXct(unixTime,origin = "1970-01-01"),"%Y-%m-%d")]
      #use setnamesx
      t1Num <- as.numeric(t1)
      for(i in seq_along(vars)){
            var <- taskMeta$varname[i]
            DTC <- vector("numeric",days)
            # to subset add an argument at end with = F
            idsC <- taskMeta[i,]$ids[[1]]
            for(j in seq_along(idsC)){
                  task <- getTask(idsC[j], uspw[1],uspw[2])
                  if(!is.null(task)){
                  taskDate <- fromJSON(task)$data$history$date
                  for(k in seq_along(taskDate)){
                        reduced <- floor((taskDate[k]-1000*t1Num)/(1000*day)) 
                        #print(reduced)
                        if(0<=reduced&reduced < days){
                              DTC[reduced+1] <- DTC[reduced+1]+1
                              #if(vars[i]=="lectures")print(as.POSIXlt(taskDate[k]/1000,orig = "1970-01-01"))
                        }
                  }
                  }else{ print("You have deleted tasks;should rerun setTasks()")}
            }
            
            DT[,t:=DTC]
            setnames(DT,"t",vars[i][[1]])
      }
      write.csv(DT,file = path)
      DT
}

