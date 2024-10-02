#' Validate and preprocess the input data for BIDS formatting
#'
#' @param data A data frame that contains the dataset to be validated.
#' @param participant_col Name of the column containing participant IDs (default is "participant_id").
#' @param session_col Name of the column containing session IDs (default is "session").
#' @param gender_col Name of the column containing gender information, if any (default is "gender").
#'
#' @description
#' This function checks that certain requirements are met by the dataset, including variable names in snake_case,
#' valid participant IDs, and proper gender encoding ("m", "f", or "o"). It attempts to convert invalid data and
#' outputs warnings or errors if issues arise.
#'
#' @return A validated and possibly modified data frame with the appropriate formatting.
#'
#' @export
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(ParticipantID = c(1, 2), Session = c(1, 1), Gender = c("Male", "Female"))
#' check_input_data(example_data)
#'
check_input_data <- function(data, participant_col = "participant_id", session_col = "session", gender_col = "gender") {
  # Convert column names to snake_case
  original_names <- colnames(data)
  renamed_names <- sapply(original_names, to_snake_case)
  colnames(data) <- renamed_names
  
  # Print messages for renamed columns
  if (!identical(original_names, renamed_names)) {
    message("The following columns were renamed to snake_case:")
    message(paste(original_names[original_names != renamed_names], " -> ", renamed_names[original_names != renamed_names], collapse = ", "))
  }
  
  # Check for mandatory columns
  if (!(participant_col %in% colnames(data))) {
    stop("Error: The specified participant column does not exist in the data.")
  }
  if (!(session_col %in% colnames(data))) {
    stop("Error: The specified session column does not exist in the data.")
  }
  
  # Check and correct gender column, if present
  if (gender_col %in% colnames(data)) {
    valid_genders <- c("m", "f", "o")
    data[[gender_col]] <- tolower(substr(data[[gender_col]], 1, 1))
    if (any(!data[[gender_col]] %in% valid_genders)) {
      stop(paste("Error: Invalid values found in gender column. Must be 'm', 'f', or 'o'."))
    }
  }
  
  return(data)
}
