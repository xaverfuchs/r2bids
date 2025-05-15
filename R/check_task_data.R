#' Check and adjust the task data before writing task.tsv file
#'
#' @param data A data frame that contains the data set with the (behavioral) task data to be checked.
#' @param participant_col Name of the column containing participant IDs (default is "participant_id").
#' @param session_col Name of the column containing session IDs (default is "session").
#' @param ignore_cols Character vector with variable names to ignore. Sometimes the function will not rename the data in a desirable way (for example when special characters DO have a meaning in a factor). In this case you can ignore variables and rename/recode them manually instead.
#'
#' @description
#' This function checks that certain requirements are met by the data set, including variable names in snake_case,
#' valid participant IDs, and session description. It attempts to convert invalid data and
#' outputs warnings or errors if issues arise.
#'
#' @return A checked and possibly adjusted data frame with the appropriate formatting.
#'
#' @export
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(ParticipantID = c(1, 2), Session = c(1, 1), RT = c(435, 876), weird_variable=c("1_2", "3_4"))
#' check_task_data(data = example_data, participant_col = "ParticipantID", session_col = "Session", ignore_cols=c("weird_variable"))

check_task_data <- function(data, participant_col = "participant_id", session_col = "session", ignore_cols = NULL) {
  data <- as.data.frame(data)
  message("\nStep 1: checking variable labels in task data")

  character_cols <- sapply(data, is.character) | sapply(data, is.factor)
  character_cols <- names(data)[character_cols]
  character_cols <- setdiff(character_cols, c(participant_col, session_col, ignore_cols))

  for (i in character_cols) {
    message(paste("checking variable", i))
    orig_labels <- data[[i]]
    renamed_labels <- to_snake_case(orig_labels)
    renamed_labels_index <- orig_labels != renamed_labels
    renamed_labels_df <- unique(data.frame(original = orig_labels, renamed = renamed_labels)[renamed_labels_index, ])
    if (nrow(renamed_labels_df) > 0) {
      for (k in 1:nrow(renamed_labels_df)) {
        data[data[, i] == renamed_labels_df$original[k], i] <- renamed_labels_df$renamed[k]
        message(paste("renamed variable label:", renamed_labels_df[k, "original"], "->", renamed_labels_df[k, "renamed"]))
      }
    }
  }

  message("\nStep 2: checking participant and session identifiers")

  if (!(participant_col %in% colnames(data))) stop("The specified participant column does not exist in the data.")
  if (!(session_col %in% colnames(data))) stop("The specified session column does not exist in the data.")

  if (participant_col != "participant_id") {
    names(data)[names(data) == participant_col] <- "participant_id"
    message(paste("renamed variable:", participant_col, "-> participant_id"))
  }

  ids_stripped <- gsub("^sub-", "", data[["participant_id"]])
  if (any(!grepl("^[a-zA-Z0-9]+$", ids_stripped))) {
    stop("The participant identifier column must be alphanumeric (except for 'sub-' prefix).")
  }

  if (any(data[["participant_id"]] == ids_stripped)) {
    renamed_ids <- paste("sub-", ids_stripped, sep = "")
    message(paste("renamed ids to", paste(head(unique(renamed_ids)), collapse = ", "), "..."))
    data[["participant_id"]] <- renamed_ids
  }

  if (session_col != "session") {
    names(data)[names(data) == session_col] <- "session"
    message(paste("renamed variable:", session_col, "-> session"))
  }

  ses_stripped <- gsub("^ses-", "", data[["session"]])
  if (any(!grepl("^[0-9]+$", ses_stripped))) {
    stop("The session identifier column must be numeric (except for 'ses-' prefix).")
  }

  if (any(data[["session"]] == ses_stripped)) {
    renamed_ses <- paste("ses-", sprintf("%02d", as.numeric(ses_stripped)), sep = "")
    message(paste("renamed sessions to", paste(head(unique(renamed_ses)), collapse = ", "), "..."))
    data[["session"]] <- renamed_ses
  }

  message("\nStep 3: checking if all variable names are snake_case")
  orig_names <- colnames(data)
  renamed_names <- to_snake_case(orig_names)
  if (!is.null(ignore_cols)) {
    renamed_names[orig_names %in% ignore_cols] <- orig_names[orig_names %in% ignore_cols]
  }
  names(data) <- renamed_names

  renamed_cols_index <- orig_names != renamed_names
  renamed_cols_df <- unique(data.frame(original = orig_names, renamed = renamed_names)[renamed_cols_index, ])
  if (nrow(renamed_cols_df) > 0) {
    for (i in 1:nrow(renamed_cols_df)) {
      message(paste("renamed variable:", renamed_cols_df[i, "original"], "->", renamed_cols_df[i, "renamed"]))
    }
  }

  return(data)
}

