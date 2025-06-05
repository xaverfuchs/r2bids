#' Read BIDS-formatted (behavioral) data
#'
#' @param bids_dir The root directory of the BIDS data set.
#' @param data_type A string defining the data_type for the task files. In BIDS it is usually "events" or "beh" (the default) for "behavior".
#' @param filename_prefixes A character string defining the variables that are contained in the data file name and that should then appear as columns in the data. Default is c("sub-", "ses-") assuming that the file name will at least contain the participant code and the session.
#' @param filename_variables A character string defining how the variables defined in 'filename_prefixes' should be called in the data Default is c("participant", "session").
#' @param strip_prefixes Defines whether or not prefixes like "sub-" should be stripped or maintained. Default is FALSE which would maintain the prefixes.
#' @param keywords A vector of keywords that appear in the file names of the task files to identify them. This can be used when there are multiple sessions or tasks that you want to read separately.
#'
#' @return A list containing the participant data and the task data.
#' @export
#'
#' @description
#' This function searches the BIDS directory for all task-related `.tsv` files and reads the data into R.
#' It handles cases where session folders are present as well as cases where there are no session folders.
#'
#' @examples
#' example_task_data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
#'                    session = c("ses-1", "ses-2", "ses-1", "ses-2"),
#'                    run = c("run-1", "run-1", "run-1", "run-1"),
#'                    response_time = c(100, 200, 150, 180))
#'
#' write_task_tsv(example_task_data, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
#'                filename_variables = c("participant_id", "session", "RTTask"="task", "run"))

#' read_bids(bids_dir = "example_bids")

read_bids <- function(bids_dir, data_type="beh", filename_prefixes=c("sub-", "ses-"), filename_variables=c("participant", "session"), strip_prefixes=F, keywords=NULL) {

  # Search for all task-related .tsv files recursively
  task_files <- list.files(bids_dir, pattern = paste0("_", data_type, "\\.tsv$"),
                           recursive = TRUE, full.names = TRUE)

  if (!is.null(keywords)) {
    # recursively check that all filename prefixes are present
    for (i in keywords) {
      task_files <- task_files[grep(i, task_files)]
    }
  }


  # check that there are files, and if so, read them one by one
  if (length(task_files) == 0) {
    warning("No BIDS task files found for the specified task and file suffix.")
    all_task_data <- list() # empty object
  } else {
    # Initialize an empty list to store task data
    task_data_list <- list()

    # Loop through each task file
    for (file in task_files) {
      # Read the task file
      task_data <- tryCatch({
        read.table(file, sep = "\t", header = TRUE)
      }, error = function(e) {
        stop(paste("Error: Failed to read task file:", file, ". Reason:", e$message))
      })

      # Extract participant and session info from the file path
      file_variables <- unlist(strsplit(basename(file), split = "_")) # By convention the variables are separated by _

      # Add variable to the data
      for (i in 1:length(filename_prefixes)) {
        var <- filename_prefixes[i]
        var_name <- filename_variables[i]
        if (strip_prefixes==T) {
          task_data[, var_name] <- gsub(var, "", grep(var, file_variables, value = T))
        } else {
          task_data[, var_name] <- grep(var, file_variables, value = T)
        }
      }

      # Append the task data to the list
      task_data_list[[length(task_data_list) + 1]] <- task_data
    }

    # Combine all task data into one data frame
    all_task_data <- do.call(rbind, task_data_list)

    # Do some rearrangements
    all_task_data <- cbind(all_task_data[, filename_variables], all_task_data[, !names(all_task_data) %in% filename_variables, drop=F])

    # Report on progress
    message("Task data loaded from all task files.")

  }

  # Read the participants.tsv file
  participants_file <- file.path(bids_dir, "participants.tsv")
  if (!file.exists(participants_file)) {
    participants_data <- list() #empty object
    warning("No participants.tsv file found in the BIDS directory.")
  } else {
    participants_data <- tryCatch({
      read.table(participants_file, sep = "\t", header = TRUE)
    }, error = function(e) {
      stop(paste("Error: Failed to read participants.tsv file. Reason:", e$message))
    })

    message("Participants data loaded from: ", participants_file)
  }

  # Return a list with participants data and the task data
  return(list(
    participants = participants_data,
    task_data = all_task_data
  ))
}
