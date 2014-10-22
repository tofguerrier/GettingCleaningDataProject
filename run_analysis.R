#Here are the data for the project: 
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# You should create one R script called run_analysis.R that does the following. 
# 1.Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 

#Assume data is downloaded and present.
#Library
library(dplyr)
library(reshape2)
library(data.table)
#Load all data
features_names = c("tBodyAcc-XYZ","tGravityAcc-XYZ",
                  "tBodyAccJerk-XYZ",
                  "tBodyGyro-XYZ",
                  "tBodyGyroJerk-XYZ",
                  "tBodyAccMag",
                  "tGravityAccMag",
                  "tBodyAccJerkMag",
                  "tBodyGyroMag",
                  "tBodyGyroJerkMag",
                  "fBodyAcc-XYZ",
                  "fBodyAccJerk-XYZ",
                  "fBodyGyro-XYZ",
                  "fBodyAccMag",
                  "fBodyAccJerkMag",
                  "fBodyGyroMag",
                  "fBodyGyroJerkMag")

varset = c("mean", "std",  "mad", "max", "min","sma", "energy",
          "iqr", "entropy", "arCoeff", "correlation", "maxInds",
          "meanFreq", "skewness", "kurtosis", "bandsEnergy", "angle")

#Creating vector name list for data
namesdata = c()
for (feat in features_names) {
  #print(paste0(feat,".",varset))
  namesdata = append(namesdata,paste0(feat,".",varset))
}


for (type in c("train", "test")){
  activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
  names(activity_labels) <- c("num", "act")
  x <- read.table(paste0("./UCI HAR Dataset/",type,"/X_",type,".txt"))
  names(x) <- namesdata
  y <- read.table(paste0("./UCI HAR Dataset/",type,"/y_",type,".txt"))
  names(y) <- c("activity.number")
  y$activity = activity_labels[y$activity.number,"act"]
  subject <- read.table(paste0("./UCI HAR Dataset/",type,"/subject_",type,".txt"))
  names(subject) <- c("subject")
  #No need for those files
  #filesInertia = list.files(paste0("./UCI HAR Dataset/",type,"/Inertial Signals/"))
  #we only want the mean and std
  if (type == "test"){
    data_test <- cbind(y$activity, subject$subject,
                        x[,c(grep(".mean$",names(x)),grep(".std$",names(x)))])
  } else if (type == "train"){
    data_train <- cbind(y$activity, subject$subject,
                       x[,c(grep(".mean$",names(x)),grep(".std$",names(x)))])
  }
  rm("x","y","subject","activity_labels")
}

data <- rbind(data_train,data_test)
#Tidy up names
names(data) <- sub("y\\$activity", "activity", names(data))
names(data) <- sub("subject\\$subject", "subject", names(data))

rm("data_train", "data_test")

#Now step 5
DT <- data.table(group_by(data, subject, activity))
tinyData <- DT[, lapply(.SD, mean), by = c("activity","subject")]

write.table(tinyData, row.names=FALSE,file = "tiny.txt")


