#' Create BIDS-compliant behavioral data files
#'
#' This function  generates a participants file (`participants.tsv`) or another kind of tsv with information in tabular format.
#'
#' @param data A data frame containing the participant information.
#' @param bids_dir The directory where the BIDS data set will be saved.
#' @param data_type A string defining the data_type for the task files. Default is "participants" which will write a participants.tsv. You could however also repurpose this function to write another tsv file to contain information, for example a "session.tsv".
#' @param include_variables A character vector with the variables that should make it into the file. Default is c("participant_id") but in reality it would rather be something like c("participant_id", "age", "sex").
#'
#' @return This function does not return anything but writes files to the output directory.
#' @export
#'
#' @examples
#' data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
#'                    session = c("ses-1", "ses-2", "ses-1", "ses-2"),
#'                    run = c("run-1", "run-1", "run-1", "run-1"),
#'                    age = c(25, 25, 30, 30),
#'                    sex = c('m', 'm', 'f', 'f'),
#'                    response_time = c(100, 200, 150, 180))
#' write_participants_tsv(data, bids_dir = "BIDS", include_variables = c("participant_id", "age", "sex"))

write_participants_tsv <- function(data, bids_dir, data_type = "participants",
                                  include_variables = c("participant_id")) {
  # Convert data to data frame
  data <- as.data.frame(data)

  # Create participants.tsv
  participants_data <- unique(data[, c(include_variables), drop=F])

  participants_file <- file.path(bids_dir, paste0(data_type, ".tsv"))
  write.table(participants_data, file = participants_file, sep = "\t", row.names = FALSE, quote = FALSE)
  message(paste("Participants data saved:", participants_file))
}



