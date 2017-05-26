source("habiticaFuncs.r")
#testing getting a task which is daily
testDaily <- function(id){
      g <- getTask(id)
      lst <- fromJSON(g)
      if(lst$data$type!="daily")print("This task is not a daily!!")
      dt <- as.data.table(lst$data$history)
      dt[,dateChar := as.character(as.POSIXlt(date/1000,origin = "1970-01-01"))]
      dt
}