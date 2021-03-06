#File Run Analysis.R

library(data.table)

fileurl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
> if (!file.exists('./UCI HAR Dataset.zip')) {
  +     download.file(fileurl, './UCI HAR Dataset.zip', mode = 'wb')
  +     unzip("UCI HAR Dataset.zip", exdir = getwd())
  + }

# Read and Convert Data.
# Data is read file by file and converted into a single data frame.

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
> features <- as.character(features[,2])
> 
  > data.train.x <- read.table('./UCI HAR Dataset/train/X_train.txt')
> data.train.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = '')
> data.train.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt', header = FALSE, sep = '')
> 
  > data.train <- data.frame(data.train.subject, data.train.activity, data.train.x)
> names(data.train) <- c(c('subject', 'activity'), features)
> 
  > data.text.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
> data.test.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
> data.test.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = '')
> data.test.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = '')
> 
  > data.test <- data.frame(data.test.subject, data.test.activity, data.test.x)
> names(data.test) <- c(c('subject', 'activity'), features)

#Step 1: Merging the Training and Testing Sets into 1 Data set called data.all
data.all <- rbind(data.train, data.test)

#Step 2: Extract the measurements of the mean and standard deviation for each measurement
mean_std.select <- grep('mean | std', features)
> data.sub <- data.all[, c(1, 2, mean_std.select + 2)]

#Step 3: Name the activities in the data set using descriptive activity names
#This is done by reading the labels from the activity_labels.txt file
activity.labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
> activity.labels <- as.character(activity.labels[, 2])
> data.sub$activity <- activity.labels[data.sub$activity]

#Step 4: Label the data set with descriptive variable names.
#Replace the names in the data set with names from activity labels.
name.new <- names(data.sub)
> name.new <- gsub("[(][)]", "", name.new)
> name.new <- gsub("^t", "TimeDomain_", name.new)
> name.new <- gsub("^f", "FrequencyDomain_", name.new)
> name.new <- gsub("Acc", "Accelerometer", name.new)
> name.new <- gsub("Gyro", "Gyroscope", name.new)
> name.new <- gsub("Mag", "Magnitude", name.new)
> name.new <- gsub("-mean-", "_Mean_", name.new)
> name.new <- gsub("-std-", "_StandardDeviation_", name.new)
> name.new <- gsub("-", "_", name.new)
> names(data.sub) <- name.new

#Step 5: Using the data set in step 4, create a tidy data set with the mean of each variable per activity and subject.
#Send output of Tidy data to data_tidy.txt file.
data.tidy <- aggregate(data.sub[, 1:2], by = list(activity = data.sub$activity, subject = data.sub$subject), FUN = mean)
write.table(x = data.tidy, file = "data_tidy.txt", row.names = FALSE)
