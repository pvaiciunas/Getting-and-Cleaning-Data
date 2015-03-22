library(data.table)
library(reshape2)
library(plyr)

# Merge training and test sets to create one data set
# Read in all the data

test_labels <- read.table("./UCI HAR Dataset/test/y_test.txt")
test_set <- read.table("./UCI HAR Dataset/test/X_test.txt")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_labels <- read.table("./UCI HAR Dataset/train/y_train.txt")
train_set <- read.table("./UCI HAR Dataset/train/X_train.txt")
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")

features <- read.table("./UCI HAR Dataset/features.txt")

all_set <- rbind(train_set, test_set)
all_labels <- rbind(train_labels, test_labels)
all_subject <- rbind(train_subject, test_subject)
colnames(all_set) <- features$V2
colnames(all_subject) <- "subject"

# Extracts only the measurements on the mean and standard deviation for each measruement

desired_features <- features$V2[features$V2 %like% "std()" | features$V2 %like% "mean" & !features$V2 %like% "Freq"]
desired_features <- as.vector(desired_features)
mean_std_set <- all_set[,(colnames(all_set) %in% desired_features)]

# Uses descriptive activity names to name the activities in the ata set
# Appropriately labels the data set with the descriptive variable names

descriptive_names <- read.table("./UCI HAR Dataset/activity_labels.txt")
descriptive_table <- merge(all_labels, descriptive_names, all.x = TRUE)
colnames(descriptive_table) <- c("activity_value","activity_name")
mean_std_set <- cbind(mean_std_set, descriptive_table, all_subject)


# From the data set in step 4, creates a second independent tidy data set with the 
# average of each variable for each activity and each subject
output <- melt(mean_std_set, id = c("activity_value","activity_name","subject"))
output <- output[,2:5]
output <- ddply(output, .(activity_name, subject, variable), summarize, mean_value = mean(value))
write.table(output, "tidy_data.txt", row.names = FALSE)