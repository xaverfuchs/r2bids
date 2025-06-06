#' Create BIDS-compliant behavioral data files
#'
#' This function  generates a participants file (`participants.tsv`) or another kind of tsv with information in tabular format.
#'
#' @param data A data frame containing the participant information.
#' @param bids_dir The directory where the BIDS data set will be saved.
#' @param data_type A string defining the data_type for the task files. Default is "participants" which will write a participants.tsv. You could however also repurpose this function to write another tsv file to contain information, for example a "session.tsv".
#' @param exclude_variables A character vector with the variables that should not make it into the file.
#'
#' @return This function does not return anything but writes files to the output directory.
#' @export
#'
#' @examples
#' example_participant_data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
#'                    age = c(25, 25, 30, 30),
#'                    sex = c('m', 'm', 'f', 'f'))
#' write_participants_tsv(example_participant_data, bids_dir = "example_bids")
#' #clean up
#' unlink("example_bids/", recursive = T)

write_participants_tsv <- function(data, bids_dir, data_type = "participants",
                                  exclude_variables = c()) {

  # Create the main BIDS directory if it does not exist
  if (!dir.exists(bids_dir)) {
    dir.create(bids_dir, recursive = TRUE)
    message(paste("Main BIDS directory successfully created:", bids_dir))
  }

  # Convert data to data frame
  data <- as.data.frame(data)

  # Choose selected variables
  selected_variables <- names(data)[!names(data) %in% c(exclude_variables)]

  # Create participants.tsv
  participants_data <- unique(data[, selected_variables, drop=F])

  participants_file <- file.path(bids_dir, paste0(data_type, ".tsv"))
  write.table(participants_data, file = participants_file, sep = "\t", row.names = FALSE, quote = FALSE)
  message(paste("Participants data saved:", participants_file))
}



