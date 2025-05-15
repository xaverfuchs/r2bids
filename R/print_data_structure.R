#' Print the data structure to facilitate writing metadata
#'
#' This function creates a BIDS-compliant JSON meta_data file for the task data.
#'
#' @param ... Any number of data sets provided as data.frames. Usually this would be task data and participant data.
#'
#' @return This function does not return anything but prints a summary of included variables to the console.
#' @export
#'
#' @examples
#' example_task_data <- data.frame(participant_id = c("sub-001", "sub-002"), session = c("ses-01", "ses-01"), dv_var=c(0.564, 2.123))
#' example_participant_data <- data.frame(participant_id = c("sub-001", "sub-002"), age = c(24, 45), sex=c("male", "female"))
#' print_data_structure(example_task_data, example_participant_data)

print_data_structure <- function(...) {
  data_list <- list(...)

  for (i in seq_along(data_list)) {
    data <- data_list[[i]]
    cat("\n--- Dataset", i, "---\n")

    for (var_name in names(data)) {
      cat("\nvariable:", var_name, "\n")
      var_now <- data[[var_name]]
      var_class <- class(var_now)[1]
      cat("Type:", var_class, "\n")

      if (anyNA(var_now)) {
        cat("Missing values:", sum(is.na(var_now)), "\n")
      }

      if (is.numeric(var_now) || is.integer(var_now)) {
        cat("Range:", paste(range(var_now, na.rm = TRUE), collapse = " - "), "\n")
      } else if (is.factor(var_now)) {
        cat("Levels:", paste(levels(var_now), collapse = ", "), "\n")
      } else if (is.character(var_now)) {
        unique_values <- unique(var_now)
        n_unique_values <- length(unique_values)
        if (n_unique_values > 10) {
          cat("Unique values (first 10 of", n_unique_values, "):", paste(head(unique_values, 10), collapse = ", "), ", ...\n")
        } else {
          cat("Unique values:", paste(unique_values, collapse = ", "), "\n")
        }
      }
    }
  }
}
