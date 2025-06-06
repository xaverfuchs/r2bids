library(devtools)
devtools::load_all() #load functions of package

example_task_data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
                   session = c("ses-1", "ses-2", "ses-1", "ses-2"),
                   run = c("run-1", "run-1", "run-1", "run-1"),
                   response_time = c(100, 200, 150, 180))
#'
write_task_tsv(example_task_data, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
               filename_variables = c("participant_id", "session", "RTTask"="task", "run"))
#'
read_bids(bids_dir = "example_bids")

#clean up
unlink("example_bids/", recursive = T)
#'
#'
# it is also possible to write to separate sets of behavioral data
#'
example_task_data2 <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
                   session = c("ses-1", "ses-2", "ses-1", "ses-2"),
                   run = c("run-1", "run-1", "run-1", "run-1"),
                   task = c("decisiontask", "decisiontask", "decisiontask", "decisiontask"),
                   accuracy = c(0.6, 0.95, 0.98, 0.67))
#'
write_task_tsv(example_task_data2, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
               filename_variables = c("participant_id", "session", "task", "run"))

write_task_tsv(example_task_data, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
               filename_variables = c("participant_id", "session", "RTTask"="task", "run"))
#and then read individually (using the "keywords" argument)
read_bids(bids_dir = "example_bids", keywords="decisiontask")
#'
#clean up
unlink("example_bids/", recursive = T)


