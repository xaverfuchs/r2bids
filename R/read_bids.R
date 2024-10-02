#' Read a BIDS-formatted dataset
#'
#' @param bids_dir The directory where the BIDS dataset is located.
#' @param task_name Name of the task (used for identifying the task files).
#'
#' @description
#' This function reads the behavioral data from a BIDS-formatted dataset and returns the task data.
#' It looks for the appropriate task-related event files and loads them into an R data frame.
#'
#' @return A data frame containing the task-related event data from the BIDS dataset.
#'
#' @export
#'
#' @examples
#' # Assuming the BIDS dataset is stored in tempdir()
#' bids_data <- read_bids(bids_dir = tempdir(), task_name = "reaction")
#'
read_bids <- function(bids_dir, task_name) {
  event_file <- file.path(bids_dir, sprintf("sub-\\d+_task-%s_beh.tsv", task_name))
  event_file_path <- Sys.glob(event_file)[1]  # Get the first match, assuming one task per participant
  
  if (length(event_file_path) == 0) {
    stop("Error: No BIDS task file found.")
  }
  
  data <- tryCatch({
    read.table(event_file_path, sep = "\t", header = TRUE)
  }, error = function(e) {
    stop(paste("Error: Failed to read BIDS file:", event_file_path, ". Reason:", e$message))
  })
  
  message(paste("Task data loaded from:", event_file_path))
  return(data)
}
