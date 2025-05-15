#' Check and adjust the participant data before writing participants.tsv file
#'
#' @param data A data frame that contains the participant data to be bids-converted.
#' @param participant_col Name of the column containing participant IDs (default is "participant_id").
#' @param sex_col Name of the column containing sex information, if any (default is NULL, assuming there is no sex column).
#' @param ignore_cols Character vector with variable names to ignore. Sometimes the function will not rename the data in a desirable way (for example when special characters DO have a meaning in a factor). In this case you can ignore variables and rename/recode them manually instead.
#'
#' @description
#' This function checks that certain requirements are met by the data set, including variable names in snake_case,
#' and valid participant IDs description. The function can optionally also check for proper sex encoding ("m", "f", or "o"). It attempts to convert invalid data and
#' outputs warnings or errors if issues arise.
#'
#' @return A checked and possibly adjusted data frame with the appropriate formatting.
#'
#' @export
#'
#' @examples
#' # Example dataset
#' example_data <- data.frame(ParticipantID = c(1, 2), sex = c("Male", "Female"), Age = c(24, 45))
#' check_participant_data(data = example_data, participant_col = "ParticipantID", sex_col = "sex")
#' # Another example with an alphanumeric participant id
#' example_data2 <- data.frame(participant_id = c("ab123", "sub-123C3"), WeirdVar=c(NA, -666))
#' check_participant_data(data = example_data2, ignore_cols="WeirdVar")

check_participant_data <- function(data, participant_col = "participant_id", sex_col = NULL, age_col = NULL, ignore_cols = NULL) {
  data <- as.data.frame(data)
  message("\nStep 1: checking participant data")

  if (!(participant_col %in% colnames(data))) stop("The specified participant column does not exist in the data.")
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

  if (!is.null(sex_col)) {
    if (!(sex_col %in% colnames(data))) {
      warning("Warning: The specified sex column does not exist.")
    } else {
      if (sex_col != "sex") {
        names(data)[names(data) == sex_col] <- "sex"
        message(paste("renamed variable:", sex_col, "-> sex"))
      }

      message("\nStep 2: checking correct coding of sex variable")
      if (any(!data[["sex"]] %in% c("m", "f", "o"))) {
        warning("Invalid values found in sex column. Please recode to 'm', 'f', or 'o'.")
      }
    }
  } else {
    warning("Sex column not provided. Skipping sex validation.")
  }

  if (!is.null(age_col)) {
    if (!(age_col %in% colnames(data))) {
      warning("Warning: The specified age column does not exist.")
    } else if (age_col != "age") {
      names(data)[names(data) == age_col] <- "age"
      message(paste("renamed variable:", age_col, "-> age"))
    }
  } else {
    warning("Age column not provided.")
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


