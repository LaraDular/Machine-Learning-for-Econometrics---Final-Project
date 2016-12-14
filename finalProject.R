library(stringr) #regular expr.
library(rvest)   #html extraction
library(pryr)

setwd("C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep") 
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

summaryVec <- sapply(summary,FUN = function(t){if(length(t)==0){NA}else{t}})
sum(sapply(summaryVec,is.na))
rm(summary)
dataTrain$summary <- summaryVec
dataTrain <- dataTrain[!sapply(summaryVec,is.na),]

#write on disc
#write.csv(x=dataTrain, file="movie_metadata_summary.csv", row.names = FALSE)


####PREPROCESS###
dataAll <- read.csv("movie_metadata_summary.csv", stringsAsFactors = F)
#Did we catch all summaries? 
#We can see we didn't get 354 summaries, remove those movies
sum(sapply(dataAll$summary,is.na))

#Remove the annoying letter form the titles (not necesairy but its visualy nicer :) )
dataAll$movie_title <- gsub(pattern = "Â",replacement = "",x = dataAll$movie_title, fixed = T)


#Create a corpus of the summaries and preprocess  
library(tm) #For text mining
library(SnowballC) #For text mining
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
writeCorpus(x = corpusSum
            ,path = "C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep/data"
            ,filenames = sapply(ids, function(i) paste0("sum",i,".txt"), USE.NAMES = F))

####WORD2VEC######
#First we need to build a vocabulary of all the files
#Convert corpus to characters
tmp <- sapply(X=corpusSum, FUN = as.character)
#Each element starts with a space and ends with a space. We need to remove one in order to merge them
tmp<- sapply(tmp, function(i)substr(i,2,nchar(i)), USE.NAMES = FALSE)
sum(nchar(tmp))
#paste together and save
tmp<- paste0(tmp, collapse = "")
nchar(tmp)


setwd("C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep/data") 
# write(tmp, file="joint.txt")
#rm(tmp)

library(devtools)
library(rword2vec)
#learn vocab
model <- word2vec(train_file="joint.txt", output_file="joint.bin",save_vocab_file="vocab.txt",min_count = 5, binary=1)

model2 <- word2vec(train_file="sum1160.txt", output_file="vec1160.bin",read_vocab_file="vocab.txt", binary=1)


# for(i in ids[1:3]){
#   print(i)
#   fileIN <- paste0(i,".txt")
#   fileOUT <- paste("vec",i,".bin")
#   model <- word2vec(train_file=fileIN, output_file=fileOUT, binary=1)
# }

#Then we train word2vec on all of the files with the aqcuired vocab
setwd("C:/Users/Lara/Documents/Faks201617/MachineLearn/Assignments/Final/Rep") 




