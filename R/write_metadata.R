#' Write BIDS JSON Metadata
#'
#' This function creates a BIDS-compliant JSON metadata file for the task data.
#'
#' @param bids_dir The directory where the BIDS metadata file will be saved.
#' @param task_name The name of the task to include in the JSON filename.
#' @param data_type The data type  to include in the JSON filename. Default is "beh".
#' @param meta_data A named list containing metadata about the behavioral task.
#'
#' @return This function does not return anything but writes a JSON file to the output directory.
#' @export
#'
#' @examples
#' meta_data <- list(response_time = list(Description = "Response time in milliseconds", Units = "ms"))
#' write_metadata(bids_dir = "bids_dir", task_name = "RTTask", data_type = "beh", meta_data = meta_data)
#'
write_metadata <- function(bids_dir, task_name, data_type = "beh", meta_data) {
  json_file <- file.path(bids_dir, sprintf("task-%s_%s.json", task_name, data_type))

  # Try to write metadata as a JSON file
  tryCatch({
    jsonlite::write_json(meta_data, json_file, pretty = TRUE, auto_unbox = TRUE)
    message(paste("Metadata JSON saved:", json_file))
  }, error = function(e) {
    stop(paste("Error: Failed to create metadata JSON file. Reason:", e$message))
  })
}
