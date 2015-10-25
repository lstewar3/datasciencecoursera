
## Install and load relevant Packages 
install.packages("reshape2")
library(reshape2)
installed.packages()

## Create directory to house the data 
setwd("~/Coursera/R Functions/Getting_And_Cleaning_Data")
if (!file.exists("CourseAssignment")) {
    dir.create("CourseAssignment")
} else{
    print("file exists")
}

## Set WD for the project
setwd("C:/Users/Katherine/Documents/Coursera/R Functions/Getting_And_Cleaning_Data/CourseAssignment")

##Download and unzip the dataset 
filepath <- "./CourseAssignment/getdata.zip"
filename <- "getdata.zip"

if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL,destfile=filepath,mode="wb")
}else{
    print("the zip file has already been downloaded")
}

if (!file.exists("UCI HAR Dataset")){
    unzip(filename)
}else {
    print("Lyle, you have already downloaded and unzipped the file")
}

## Load activity lables and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <-as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

## Extract only the measurements on the mean and SD for each measurement (6 people)

featuresRequired <- grep(".*mean.*| .*std.*",features[,2])
featuresRequired.names <- features[featuresRequired,2]
featuresRequired.names = gsub('-mean', 'Mean', featuresRequired.names)
featuresRequired.names = gsub('-std', 'Std', featuresRequired.names)
featuresRequired.names <- gsub('[-()]', '', featuresRequired.names)

## Load the data directories into R ("test" and "train") - remember this data is the aggregation of the breakdown of individuals randomly monitored for testing and training as per the read me text
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresRequired]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresRequired]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

## Merge the data tables and insert the labels 
aggregateData <- rbind(train,test)
colnames(aggregateData) <-c("subject","activity",featuresRequired.names)

## make your column names factors 
aggregateData$activity <- factor(aggregateData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
aggregateData$subject <- as.factor(aggregateData$subject)

aggregateData.melted <- melt(aggregateData, id = c("subject", "activity"))
aggregateData.mean <- dcast(aggregateData.melted, subject + activity ~ variable, mean)

if(!file.exists("tidy.txt")){
    write.table(aggregateData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
}else{
    print(" Stop dude, You have already created the tidy text")
}

