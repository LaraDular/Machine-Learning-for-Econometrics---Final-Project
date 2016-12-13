library(stringr) #regular expr.
library(rvest)   #html extraction
library(pryr)
library(tm) #For text mining
library(SnowballC) #For text mining

setwd("C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep") 
dataTrain <- read.csv("movie_metadata.csv", stringsAsFactors = FALSE)

#### SCRAPING SUMMARY ####
# summary <- sapply(X=dataTrain$movie_imdb_link, function(weblink){
#   #Extract the title and number
#   title <- str_extract(pattern = "/title/tt[0-9]*/",string=weblink)
#   weblinkPlot <- paste0("https://www.imdb.com",title,"plotsummary")
#   rawpage <- read_html(weblinkPlot)
#   
#   summaryNode <- html_nodes(x=rawpage, xpath ="(//ul[@class = 'zebraList']/li[@class='odd']/p[@class='plotSummary'])[1]")
#   return(html_text(summaryNode))
# })
# 
# summaryVec <- sapply(summary,FUN = function(t){if(length(t)==0){""}else{t}})
# dataTrain$summary <- summaryVec
# 
# write.csv(x=dataTrain, file="movie_metadata_summary.csv", row.names = FALSE)


####PREPROCESS###
dataAll <- read.csv("movie_metadata_summary.csv")
#Remove the annoying letter form the titles (not necesairy but its visualy nicer :) )
dataAll$movie_title <- gsub(pattern = "Â",replacement = "",x = dataAll$movie_title, fixed = T)


#Create a corpus of the summaries and preprocess  
corpusSum <- VCorpus(VectorSource(dataAll$summary) ,readerControl = list(language = "en", reader = readPlain))
as.character(corpusSum[[1]])  #print the first summary

###PREPROCESS###
#remove punctuations
corpusSum <- tm_map(corpusSum, removePunctuation)
#and numbers
corpusSum <- tm_map(corpusSum, removeNumbers)
#and transform the comments to lowercase (we don't want the destinction between lower and upper case strings)
corpusSum <- tm_map(corpusSum, tolower)
#remove english stopwords without analytic value e.g. and, such, as, so,...
corpusSum <- tm_map(corpusSum, removeWords, stopwords("english"))
#Strip additional spaces that might occur and seqeunces such as new line "\n"" 
corpusSum <- tm_map(corpusSum, stripWhitespace)
#Steming the words
#TO CONSIDER: Should documents be stemed of not?
#stemming makes data denser, thus reducing the amount of data required for adequate training.
corpusSum <- tm_map(corpusSum, stemDocument)
#Converting reviews it in to plain text
corpusSum <- tm_map(corpusSum, PlainTextDocument)


 
#Write the files on disk
# 
library(stringr) #for the line bellow
ids <- str_pad(1:length(corpusSum), 4, pad = "0")
# writeCorpus(x = corpusSum
#             ,path = "C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep/data"
#             ,filenames = sapply(ids, function(i) paste0(i,".txt"), USE.NAMES = F))

####WORD2VEC######






