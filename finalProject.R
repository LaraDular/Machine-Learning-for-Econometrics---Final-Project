library(stringr) #regular expr.
library(rvest)   #html extraction
library(pryr)

setwd("C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final") 
dataTrain <- read.csv("movie_metadata.csv", stringsAsFactors = FALSE)

#### SCRAPING SUMMARY ####
summary <- sapply(X=dataTrain$movie_imdb_link, function(weblink){
  #Extract the title and number
  title <- str_extract(pattern = "/title/tt[0-9]*/",string=weblink)
  weblinkPlot <- paste0("https://www.imdb.com",title,"plotsummary")
  rawpage <- read_html(weblinkPlot)
  
  summaryNode <- html_nodes(x=rawpage, xpath ="(//ul[@class = 'zebraList']/li[@class='odd']/p[@class='plotSummary'])[1]")
  return(html_text(summaryNode))
})

summaryVec <- sapply(summary,FUN = function(t){if(length(t)==0){""}else{t}})
dataTrain$summary <- summaryVec

write.csv(x=dataTrain, file="movie_metadata_summary.csv", row.names = FALSE)

