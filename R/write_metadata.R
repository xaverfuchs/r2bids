#' Write BIDS JSON Metadata
#'
#' This function creates a BIDS-compliant JSON metadata file for the task data.
#'
#' @param output_dir The directory where the BIDS metadata file will be saved.
#' @param task_name The name of the task to include in the JSON filename.
#' @param meta_data A named list containing metadata about the behavioral task.
#'
#' @return This function does not return anything but writes a JSON file to the output directory.
#' @export
#'
#' @examples
#' meta_data <- list(response_time = "Response time in milliseconds")
#' write_metadata(output_dir = getwd(), task_name = "reaction_time", meta_data = meta_data)
#'
write_metadata <- function(output_dir, task_name, meta_data) {
  json_file <- file.path(output_dir, sprintf("task-%s_beh.json", task_name))

  # Try to write metadata as a JSON file
  tryCatch({
    jsonlite::write_json(meta_data, json_file, pretty = TRUE, auto_unbox = TRUE)
    message(paste("Metadata JSON saved:", json_file))
  }, error = function(e) {
    stop(paste("Error: Failed to create metadata JSON file. Reason:", e$message))
  })
}
