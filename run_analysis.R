library(reshape2)
library(utils)
library(plyr)

## Download Data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
## Unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")
##path_rf <- file.path("./data" ,"UCI HAR Dataset")
##files<-list.files(path_rf, recursive=TRUE)
# Read XTrain\XTest and YTrain/YTest data
xTrain <- read.table("./data/UCI HAR Dataset/train/X_train.txt") 
xTest <- read.table("./data/UCI HAR Dataset/test/X_test.txt") 
xMerged <- rbind(xTrain, xTest) ##

# Add activities and subject with nice names
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
yMerged <- rbind(yTrain, yTest)[, 1]

subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subjectTest  <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
subjects <- rbind(subjectTrain, subjectTest)[, 1]
# add column name for subject files
names(subjects) <- "subject"
# add column names for measurement files
features <- read.table("./data/UCI HAR Dataset/features.txt")
names(xMerged) <- features$V2
# add column name for label files
names(yMerged) <- "activity"
# Extract only the measurements on the mean and standard deviation for each measurement.
matches <- grep("(mean|std)\\(\\)", names(xMerged))
limited <- xMerged[, matches]
## Use descriptive activity names to name the activities in the data set
activityNames <- c("Walking", "Walking Upstairs", "Walking Downstairs", 
                   "Sitting", "Standing", "Laying")
activities <- activityNames[yMerged]

## Creates a second,independent tidy data set
tidyData <- cbind(Subject = subjects, Activity = activities, limited)
limitedColMeans <- function(data) { 
    colMeans(data[,-c(1,2)]) 
    }
tidyMeans <- ddply(tidyData, .(Subject, Activity), limitedColMeans)
names(tidyMeans)[-c(1,2)] <- paste0("Mean", names(tidyMeans)[-c(1,2)])
# Write file
write.table(tidyMeans, "tidy_data.txt", row.names = FALSE)
library(knitr)
knit2html("codebook.md")


