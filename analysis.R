library(reshape2)

#download dataset & unzip if necessary
filename <- "dataset.zip"

if(!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename)
}

if (!file.exists("UCI HAR Dataset")){
  unzip(filename)
}

#get the labels and features
actlbl <- read.table("UCI HAR Dataset/activity_labels.txt")
feats <- read.table("UCI HAR Dataset/features.txt")

#extract only the features needed (mean & std)
featrows <- grep("mean|std", feats[,2])
featrows.names <- feats[featrows,2]
featrows.names <- gsub('()','', as.character(featrows.names))

#read the training data and columnbind into one dataset
traindata <- read.table("UCI HAR Dataset/train/X_train.txt")[featrows]
trainact <- read.table("UCI HAR Dataset/train/Y_train.txt") 
trainsubj <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainsubj, trainact, traindata)

#same as above for the testdata
testdata <- read.table("UCI HAR Dataset/test/X_test.txt")[featrows]
testact <- read.table("UCI HAR Dataset/test/Y_test.txt") 
testsubj <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testsubj, testact, testdata)

#bind the created datasets into a result dataset and add pretty columnnames
res <- rbind(test, train)
colnames(res) <- c("Subject", "Activity", as.character(featrows.names))

#prepare factors for subject and activity labels
res$Activity <- factor(res$Activity, levels = actlbl[,1], labels = actlbl[,2])
res$Subject <- as.factor(res$Subject)

#melt datasets and get mean
res.melt <- melt(res, id=c("Subject", "Activity"))
res.mean <- dcast(res.melt, Subject + Activity ~ variable, mean)

#write dataset to file
write.table(res.mean, "tidy_dataset.txt", row.names = FALSE, quote = FALSE)

