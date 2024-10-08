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
#' # Another example with an alphanumeric participant id
#' example_data2 <- data.frame(participant_id = c("ab123", "sub-123C3"), session = c("ses-01", "ses-01"), dv_var=c(0.564, 2.123))
#' check_input_data(data = example_data2)


check_input_data <- function(data, participant_col = "participant_id", session_col = "session", gender_col = NULL, ignore_cols=NULL) {

  # Step 1: convert all character variables to snake_case
  message("\nStep 1: checking variable labels")

  character_cols <- sapply(data, is.character) | sapply(data, is.factor)
  character_cols <- names(data)[character_cols]

  #ignore the participant and session cols
  character_cols <- character_cols[!character_cols %in% c(participant_col, session_col)]

  #ignore the ignore col and gender col
  if (!is.null(ignore_cols)) {
    character_cols <- character_cols[!character_cols %in% ignore_cols]
  }

  if (!is.null(gender_col)) {
    character_cols <- character_cols[!character_cols %in% gender_col]
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
        data[data[, i]==renamed_labels_df$original[k], i] <- renamed_labels_df$renamed[k]
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

  #scrutinize participant id: they can either be numeric, or alphanumeric, it can start with "sub-" already or it needs be added
  if (participant_col != "participant_id") {
    names(data)[names(data)==participant_col] <- "participant_id"
    message(paste("renamed variable:", participant_col, "-> participant_id"))
  }

  ids_stripped <- gsub(pattern = "^sub-", replacement="", x=data[["participant_id"]]) #initially strip sub-

  if (any(!grepl("^[a-zA-Z0-9]+$", ids_stripped))) {
    stop(paste("The participant identifier column needs to be alphanumeric, except for a 'sub-' prefix. \nThese ids are not allowed:",
               paste(unique(ids_stripped[!grepl("^[a-zA-Z0-9]+$", ids_stripped)]), collapse = "\n")))
  }

  if (any(data[["participant_id"]]==ids_stripped)) {
    orig_ids <- ids_stripped

    #add trailing zeroes if the id is numeric
    if (is.numeric(orig_ids)) {
      renamed_ids <- paste("sub-", sprintf("%03d", as.numeric(orig_ids)), sep="") #add sub- and zero padding
    }
    else {
      renamed_ids <- paste("sub-", orig_ids, sep="") #add sub-
    }
    message(paste("renamed ids to", paste(head(unique(renamed_ids)), collapse = ", "), "..."))
    data[["participant_id"]] <- renamed_ids
  }

  #scrutinize session id
  if (session_col != "session") {
    names(data)[names(data)==session_col] <- "session"
    message(paste("renamed variable:", session_col, "-> session"))
  }

  ses_stripped <- gsub(pattern = "^ses-", replacement="", x=data[["session"]]) #initially strip sub-

  if (any(!grepl("^[0-9]+$", ses_stripped))) {
    stop(paste("The session identifier column needs to numeric, except for a 'ses-' prefix. \nThese sessions are not allowed:",
               paste(unique(ses_stripped[!grepl("^[0-9]+$", ses_stripped)]), collapse = "\n")))
  }

  if (any(data[["session"]]==ses_stripped)) {
    orig_ses <- ses_stripped

    #add trailing zeroes if the ses id is numeric
    if (is.numeric(orig_ses)) {
      renamed_ses <- paste("ses-", sprintf("%02d", as.numeric(orig_ses)), sep="") #add sub- and zero padding
    }
    else {
      renamed_ses <- paste("ses-", orig_ses, sep="") #add sub-
    }
    message(paste("renamed sessions to", paste(head(unique(renamed_ses)), collapse = ", "), "..."))
    data[["session"]] <- renamed_ses
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
  if (nrow(renamed_cols_df)>0) {
    for (i in 1:nrow(renamed_cols_df)) {
      message(paste("renamed variable:", renamed_cols_df[i, "original"], "->", renamed_cols_df[i, "renamed"]))
    }
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
