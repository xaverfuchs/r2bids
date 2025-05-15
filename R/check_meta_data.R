#' Validate metadata
#'
#' This function compares the entries within metadata objects with variables in the data and reports mismatches.
#'
#' @param meta_data An object of class "metadata" with entries.
#' @param ... Any number of data sets provided as data.frames. Usually this would be task data and participant data.
#' @param data_type The data type  to include in the JSON filename. Default is "beh".
#' @param meta_data A named list containing meta_data about the behavioral task.
#'
#' @return This function does not return anything but prints a summary of correctly declared and mismatching varibales to the console.
#' @export
#'
#' @examples
#' meta_data <- create_meta_data()
#' meta_data <- add_meta_data(meta_data, variable_name = "participant_id", Description = "Identifier for participants in the form of sub-XXX") #add an existing variable
#' meta_data <- add_meta_data(meta_data = meta_data, variable_name = "condition", labels = list("experimental"="500 ml of pure alcohol", "control"="a sober session"))
#' example_participant_data <- data.frame(participant_id = c("sub-001", "sub-002"), age = c(24, 45), sex=c("male", "female"))
#' example_task_data <- data.frame(participant_id = c("sub-001", "sub-002"), session = c("ses-01", "ses-01"), dv_var=c(0.564, 2.123))
#' check_meta_data(meta_data, example_task_data, example_participant_data)
#'

check_meta_data <- function(meta_data, ...) {
  stopifnot(inherits(meta_data, "metadata"))
  data_list <- list(...)

  # Collect all variable names from all data frames
  all_data_vars <- unique(unlist(lapply(data_list, names)))

  # Variables declared in meta_data
  meta_vars <- names(meta_data)

  cat("🔍 Validating meta_data against data...\n\n")

  # Check for meta_data variables missing in data
  for (var in meta_vars) {
    if (var %in% all_data_vars) {
      cat("✔", var, "...ok\n")
    } else {
      warning(paste("⚠ Variable", var, "declared in meta_data but not found in any dataset."))
    }
  }

  # Check for data variables missing in meta_data
  for (var in all_data_vars) {
    if (!(var %in% meta_vars)) {
      warning(paste("⚠ Variable", var, "found in data but not declared in meta_data."))
    }
  }
}
