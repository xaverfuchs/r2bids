#' Create BIDS-compliant behavioral data files
#'
#' This function creates BIDS-compliant behavioral data files in `.tsv` format.
#' It generates a participants file (`participants.tsv`) and individual
#' task-based files for each participant and session.
#'
#' @param data A data frame containing the participant information and behavioral data.
#' @param output_dir The directory where the BIDS dataset will be saved.
#' @param task_name Name of the task, which will be used in the filename.
#' @param participant_info_cols A character vector of column names to include in the `participants.tsv` file. These variables will now be included in the tsv files containing the task data.
#' @param file_suffix A string defining the suffix for the task files. In BIDS it is usually "events" or "beh" (the default) for "behavior"
#'
#' @return This function does not return anything but writes files to the output directory.
#' @export
#'
#' @examples
#' data <- data.frame(participant_id = c(1, 1, 2, 2),
#'                    session = c(1, 2, 1, 2),
#'                    age = c(25, 25, 30, 30),
#'                    gender = c('m', 'm', 'f', 'f'),
#'                    response_time = c(100, 200, 150, 180))
#' write_bids(data, output_dir = "bids_dir", task_name = "RTTask", participant_info_cols = c("age", "gender"))
#'
write_bids <- function(data, output_dir, task_name, participant_info_cols, file_suffix="beh") {
  #fixed parameters
  participant_col = "participant_id"
  session_col = "session"

  # Prepare the directory structure
  unique_participants <- unique(data[[participant_col]])
  unique_sessions <- unique(data[[session_col]])

  # Create the main BIDS directory if it does not exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    message(paste("Main BIDS directory successfully created:", output_dir))
  }

  # Create participants.tsv
  participants_data <- unique(data[, c(participant_col, participant_info_cols)])
  participants_file <- file.path(output_dir, "participants.tsv")
  write.table(participants_data, file = participants_file, sep = "\t", row.names = FALSE, quote = FALSE)
  message(paste("Participants data saved:", participants_file))

  # Create behavioral data per participant/session
  for (participant in unique_participants) {
    for (session in unique_sessions) {
      # Create directory structure for each participant/session
      dir_path <- file.path(output_dir, participant, session)

      if (!dir.exists(dir_path)) {
        dir.create(dir_path, recursive = TRUE)
        message(paste("Folder successfully created:", dir_path))
      }

      # Write behavior data to .tsv
      task_file <- file.path(dir_path, sprintf("%s_task-%s_%s.tsv", participant, task_name, file_suffix))
      task_data <- data[ data[participant_col]==participant & data[session_col]==session,
                         (!names(data) %in% participant_info_cols) ]

      write.table(task_data,
                  file = task_file, sep = "\t", row.names = FALSE, quote = FALSE)
      message(paste("Task data saved:", task_file))
    }
  }
}
