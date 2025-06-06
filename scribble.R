library(devtools)
devtools::load_all() #load functions of package

example_data <- data.frame(ParticipantID = c(1, 2), Bad_Factor=c(NA, ""), Session = c(1, 1), RT = c(435, 876), weird_variable=c("1_2", "3_4"))
check_task_data(data = example_data, participant_col = "ParticipantID", session_col = "Session", ignore_cols=c("weird_variable"))


example_data$Some_Factor <- as.factor(example_data$Some_Factor)

levels(example_data$Some_Factor)



example_task_data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
                   session = c("ses-1", "ses-2", "ses-1", "ses-2"),
                   run = c("run-1", "run-1", "run-1", "run-1"),
                   response_time = c(100, 200, 150, 180))

write_task_tsv(example_task_data, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
               filename_variables = c("participant_id", "session", "RTTask2"="task", "run"))

read_bids(bids_dir = "example_bids", keywords = "RTTask")





example_task_data2 <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
                   session = c("ses-1", "ses-2", "ses-1", "ses-2"),
                   run = c("run-1", "run-1", "run-1", "run-1"),
                   task = c("decisiontask", "decisiontask", "decisiontask", "decisiontask"),
                   accuracy = c(0.6, 0.95, 0.98, 0.67))
#'
write_task_tsv(example_task_data2, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
               filename_variables = c("participant_id", "session", "task", "run"))
#and then read individually (using the "keywords" argument)
read_bids(bids_dir = "example_bids", keywords="decisiontask")



