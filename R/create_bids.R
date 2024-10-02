#' Create a BIDS-formatted dataset
#'
#' @param data A data frame that contains participant information, behavioral data, and task measures. It needs to be compliant to the naming conventions and might be the output of the 'check_input()' function.
#' @param output_dir The directory where the BIDS dataset will be saved.
#' @param participant_col Name of the column containing participant IDs.
#' @param session_col Name of the column containing session IDs.
#' @param task_name Name of the task for BIDS naming conventions.
#' @param meta_data A list of metadata information for the behavioral task.
#'
#' @description
#' This function creates a BIDS-formatted dataset, including a participant-level data file (`participants.tsv`),
#' and task-related event data files. It also generates the directory structure necessary for BIDS compatibility.
#'
#' @return It returns the directory structure with the appropriate files.
#'
#' @export
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(participant_id = c(1, 2), session = c(1, 1), response_time = c(100, 200))
#' meta_data <- list(response_time = "Response time in milliseconds")
#' create_bids(example_data, output_dir = tempdir(), task_name = "reaction", meta_data = meta_data)
#'
create_bids <- function(data, output_dir, task_name, meta_data, participant_col = "participant_id", session_col = "session") {
  # Create output directory if not exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message("Output directory created:", output_dir)
  }
  
  # Write participants.tsv
  participants_file <- file.path(output_dir, "participants.tsv")
  participant_data <- unique(data[, c(participant_col, session_col)])
  write.table(participant_data, participants_file, sep = "\t", row.names = FALSE)
  message("Participants file saved:", participants_file)
  
  # Write event data
  event_file <- file.path(output_dir, sprintf("sub-%s_task-%s_beh.tsv", unique(data[[participant_col]]), task_name))
  write.table(data, event_file, sep = "\t", row.names = FALSE)
  message("Task data saved:", event_file)
  
  # Call the JSON metadata function
  create_bids_metadata(data, output_dir, task_name, meta_data)
}
