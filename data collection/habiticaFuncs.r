#BUGGY get request with my password/user and a task
library(httr)



getTaskInfo <- function(taskID, user = NULL, pw = NULL){
      ret = NULL
      if(is.null(user)){
            dt <- read.table("../data/habitica/metadata/userpw.txt", sep = "\t")
            user = toString(dt[1,1])
            pw = toString(dt[2,1])
      }
      gr <- GET(paste0("https://habitica.com/api/v3/tasks/", taskID),
                add_headers(.headers = c("x-api-user" = user,"x-api-key" = pw)))
      if(gr$status_code == 200){
            ret = content(gr,"text")
      }
      ret
}