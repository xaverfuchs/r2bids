#' Validate and preprocess the input data for BIDS formatting
#'
#' @param data A data frame that contains the dataset to be validated.
#' @param participant_col Name of the column containing participant IDs (default is "participant_id").
#' @param session_col Name of the column containing session IDs (default is "session").
#' @param gender_col Name of the column containing gender information, if any (default is NULL, assuming there is no gender column).
#' @param ignore_cols Character vector with variable names to ignore. Sometimes the function will not rename the data in a desirable way (for example when special characters DO have a meaning in a factor). In this case you can ignore variables and rename/recode them manually instead.
#'
#' @description
#' This function checks that certain requirements are met by the dataset, including variable names in snake_case,
#' valid participant IDs, and session description. The function can optionally also check for proper gender encoding ("m", "f", or "o"). It attempts to convert invalid data and
#' outputs warnings or errors if issues arise.
#'
#' @return A validated and possibly modified data frame with the appropriate formatting.
#'
#' @export
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(ParticipantID = c(1, 2), Session = c(1, 1), Gender = c("Male", "Female"), weird_variable=c("1_2", "3_4"))
#' check_input_data(data = example_data, participant_col = "ParticipantID", session_col = "Session", gender_col = "Gender", ignore_cols=c("weird_variable"))
#'
check_input_data <- function(data, participant_col = "participant_id", session_col = "session", gender_col = NULL, ignore_cols=NULL) {

  # Step 1: convert all character variables to snake_case
  message("\nStep 1: checking variable labels")

  character_cols <- sapply(data, is.character) | sapply(data, is.factor)
  character_cols <- names(data)[character_cols]

  if (!is.null(ignore_cols)) {
    character_cols <- character_cols[!character_cols %in% ignore_cols]
  }

  for (i in character_cols) {
    message(paste("checking variable", i))

    orig_labels <- data[[i]]
    renamed_labels <- to_snake_case(orig_labels)

    #message which labels were renamed
    renamed_labels_index <- orig_labels != renamed_labels
    renamed_labels_df <- unique(data.frame(original=orig_labels, renamed=renamed_labels)[renamed_labels_index, ])

    if (nrow(renamed_labels_df)>0) {
      for (k in 1:nrow(renamed_labels_df)) {
        message(paste("renamed variable label:", renamed_labels_df[k, "original"], "->", renamed_labels_df[k, "renamed"]))
      }
    }
  }

  # Step 2: check if participant and session variables are spelled correctly and numeric
  message("\nStep 2: checking participant and session identifiers")

  if (!(participant_col %in% colnames(data))) {
    stop("Error: The specified participant column does not exist in the data.")
  }
  if (!(session_col %in% colnames(data))) {
    stop("Error: The specified session column does not exist in the data.")
  }

  if (participant_col != "participant_id") {
    names(data)[names(data)==participant_col] <- "participant_id"
    message(paste("renamed variable:", participant_col, "-> participant_id"))
  }

  if (is.numeric(data[["participant_id"]])) {
    orig_ids <- data[["participant_id"]]
    renamed_ids <- sprintf("sub-%03d", as.numeric(orig_ids))

    data[, "participant_id"] <- renamed_ids

    message(paste("renamed ids to", paste(head(unique(renamed_ids)), collapse = ", "), "...")) #message which ids were renamed
  }
  else {
    stop("Error: The participant identifier column needs to be numeric")
  }

  if (session_col != "session") {
    names(data)[names(data)==session_col] <- "session"
    message(paste("renamed variable:", session_col, "-> session"))
  }

  if (is.numeric(data[["session"]])) {
    orig_ses <- data[["session"]]
    renamed_ses <- sprintf("ses-%02d", as.numeric(orig_ses))

    data[, "session"] <- renamed_ses

    message(paste("renamed sessions to", paste(head(unique(renamed_ses)), collapse = ", "), "...")) #message which ids were renamed
  }
  else {
    stop("Error: The session identifier column needs to be numeric")
  }

  # if exists: rename gender variable
  if (!is.null(gender_col)) {
    if (!(gender_col %in% colnames(data))) {
      stop("Error: The specified gender column does not exist in the data.")
    }

    if (gender_col != "gender") {
      names(data)[names(data)==gender_col] <- "gender"
      message(paste("renamed variable:", gender_col, "-> gender"))
    }
  }

  # Step 3: rename remaining column headers
  message("\nStep 3: checking if all variable names are snake_case")
  orig_names <- colnames(data)
  renamed_names <- to_snake_case(orig_names)

  if (!is.null(ignore_cols)) {
    renamed_names[orig_names %in% ignore_cols] <- orig_names[orig_names %in% ignore_cols]
  }

  names(data) <- renamed_names

  #message which labels were renamed
  renamed_cols_index <- orig_names != renamed_names
  renamed_cols_df <- unique(data.frame(original=orig_names, renamed=renamed_names)[renamed_cols_index, ])

  for (i in 1:nrow(renamed_cols_df)) {
    message(paste("renamed variable:", renamed_cols_df[i, "original"], "->", renamed_cols_df[i, "renamed"]))
  }

  # Optional step 4: check gender column
  if (!is.null(gender_col)) {
    message("\nStep 4: checking correct coding of gender variable")

    if (any(!data[["gender"]] %in% c("m", "f", "o"))) {
      warning(paste("Invalid values found in gender column. Please recode to 'm', 'f', or 'o'."))
    }
  }
  return(data)
}
