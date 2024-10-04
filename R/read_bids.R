#' Read BIDS-formatted data
#'
#' @param bids_dir The root directory of the BIDS dataset.
#' @param task_name The name of the task (e.g., "reaction").
#' @param file_suffix The suffix of the task files (e.g., "beh", "events"). Default is "beh".
#' @return A list containing the participant data and the task data.
#' @export
#'
#' @description
#' This function searches the BIDS directory for all task-related `.tsv` files and reads the data into R.
#' It handles cases where session folders are present as well as cases where there are no session folders.
#'
#' @examples
#' data <- data.frame(participant_id = c(1, 1, 2, 2),
#'                    session = c(1, 2, 1, 2),
#'                    age = c(25, 25, 30, 30),
#'                    gender = c('m', 'm', 'f', 'f'),
#'                    response_time = c(100, 200, 150, 180))
#' write_bids(data, output_dir = "bids_dir", task_name = "RTTask", participant_info_cols = c("age", "gender"))
#' read_bids(bids_dir = "bids_dir", task_name = "RTTask")
#'
read_bids <- function(bids_dir, task_name, file_suffix = "beh") {
  # 1. Read the participants.tsv file
  participants_file <- file.path(bids_dir, "participants.tsv")
  if (!file.exists(participants_file)) {
    stop("Error: No participants.tsv file found in the BIDS directory.")
  }

  participants_data <- tryCatch({
    read.table(participants_file, sep = "\t", header = TRUE)
  }, error = function(e) {
    stop(paste("Error: Failed to read participants.tsv file. Reason:", e$message))
  })

  message("Participants data loaded from: ", participants_file)

  # 2. Search for all task-related .tsv files recursively
  # Adapt the search pattern to use the user-specified file suffix
  task_files <- list.files(bids_dir, pattern = paste0("task-", task_name, "_", file_suffix, "\\.tsv$"),
                           recursive = TRUE, full.names = TRUE)

  if (length(task_files) == 0) {
    stop("Error: No BIDS task files found for the specified task and file suffix.")
  }

  # Initialize an empty list to store task data
  task_data_list <- list()

  # Loop through each task file
  for (file in task_files) {
    # Extract participant and session info from the file path
    path_parts <- unlist(strsplit(dirname(file), split = "/|\\\\"))  # Handle different OS path separators
    participant_str <- path_parts[grep("^sub-", path_parts)]
    session_str <- path_parts[grep("^ses-", path_parts)]

    # Read the task file
    task_data <- tryCatch({
      read.table(file, sep = "\t", header = TRUE)
    }, error = function(e) {
      stop(paste("Error: Failed to read task file:", file, ". Reason:", e$message))
    })

    # Add participant_id and session to the task data
    task_data$participant_id <- participant_str

    if (length(session_str) > 0) {
      task_data$session <- session_str
    } else {
      task_data$session <- NA  # No session folder present
    }

    # Append the task data to the list
    task_data_list[[length(task_data_list) + 1]] <- task_data
  }


  # Combine all task data into one data frame
  all_task_data <- do.call(rbind, task_data_list)

  message("Task data loaded from all task files.")

  # 3. Return a list with participants data and the task data
  return(list(
    participants = participants_data,
    task_data = all_task_data
  ))
}
