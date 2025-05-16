#' Write BIDS JSON Metadata
#'
#' This function creates a BIDS-compliant JSON metadata file for the task data.
#'
#' @param meta_data A named list containing metadata about the behavioral task.
#' @param bids_dir The directory where the BIDS metadata file will be saved.
#' @param task_name The name of the task to include in the task JSON filename. Default is NULL, which will not add a "task-task_name" prefix.
#' @param data_type The data type to include in the JSON filename. Can be "beh", "participants" or any other prefix.
#'
#' @return This function does not return anything but writes a JSON file to the output directory.
#' @export
#'
#' @examples
#' meta_data <- list(response_time = list(Description = "Response time in milliseconds", Units = "ms"))
#' write_metadata(bids_dir = "bids_dir", task_name = "RTTask", data_type = "beh", meta_data = meta_data)
#'
write_meta_data <- function(meta_data, bids_dir, task_name=NULL, data_type = c("beh", "participants")) {

  # Create the main BIDS directory if it does not exist
  if (!dir.exists(bids_dir)) {
    dir.create(bids_dir, recursive = TRUE)
    message(paste("Main BIDS directory successfully created:", bids_dir))
  }

  if (!is.null(task_name)) {
    json_file <- file.path(bids_dir, sprintf("task-%s_%s.json", task_name, data_type))
  }
  if (is.null(task_name)) {
    json_file <- file.path(bids_dir, sprintf("%s.json", data_type))
  }

  # In case the meta_data is an object of class "meta_data", remove class to make it writable
  if (class(meta_data)=="metadata") {
    meta_data <- unclass(meta_data)
  }

  # Try to write metadata as a JSON file
  tryCatch({
    jsonlite::write_json(meta_data, json_file, pretty = TRUE, auto_unbox = TRUE)
    message(paste("Metadata JSON saved:", json_file))
  }, error = function(e) {
    stop(paste("Error: Failed to create metadata JSON file. Reason:", e$message))
  })
}
