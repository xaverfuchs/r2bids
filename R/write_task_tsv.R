#' Create BIDS-compliant behavioral data files
#'
#' This function creates BIDS-compliant (behavioral) data files in `.tsv` format.
#' It generates individual task-based files for each participant and session.
#'
#' @param data A data frame containing the participant and other information and (behavioral) data.
#' @param bids_dir The directory where the BIDS data set will be saved.
#' @param data_type A string defining the data_type for the task files. In BIDS it is usually "events" or "beh" (the default) for "behavior"
#' @param filename_prefixes Character vector containing the prefixes used for the variables appearing in the file names of the tsv files. Default is c("sub-", "ses-", "task-", "run-") assuming that the file names would contain information about the partcipant, session, the task, and the run (in that order). Variables can be added or removed ad lib as long as the vector matches the information provided in the filename_variables vector.
#' @param filename_variables Character vector containing names of the variables in the data set that provide the information added to the filename_prefixes. Default is c("participant_id", "session", "task", "run"). Note that the lengths of filename_prefixes and filename_variables need to match. filename_variables can also define information that is NOT in the data set. In this case, a named vector can be provided. You can for example use c("participant_id", "session", "RTTask"="task", "run") if there is no variable "task" in the data set and then the task will be called "RTTask".
#' @param path_prefixes Character vector containing the prefixes for the filepath structure. Default is c("sub-", "ses-") resulting in a folder structure with subject/participants on the top level and folders for the sessions on the secondary level.
#' @param path_variables Analogous to filename_variables this is the character vector containing names of the variables used for path_prefixes. Default is c("participant_id", "session").
#' @param ignore_variables=c() A character vector of variables to explicitly exclude from the tsv file. If data contains participant information variables, they can be defined here as a character vector, for example as ignore_variables =  c("age", "sex").
#' @param include_variables=c() A character vector of variables to explicitly include in the tsv file. This can be useful in case you want to keep one of the variables that end up in the file name in the data.
#'
#' @return This function does not return anything but writes files to the output directory.
#' @export
#'
#' @examples
#' example_task_data <- data.frame(participant_id = c("sub-1", "sub-1", "sub-2", "sub-2"),
#'                    session = c("ses-1", "ses-2", "ses-1", "ses-2"),
#'                    run = c("run-1", "run-1", "run-1", "run-1"),
#'                    response_time = c(100, 200, 150, 180))
#'
#' write_task_tsv(example_task_data2, bids_dir = "example_bids", filename_prefixes = c("sub-", "ses-", "task-", "run-"),
#'                filename_variables = c("participant_id", "session", "RTTask"="task", "run"), ignore_variables =  c("age", "sex"))
#' #clean up
#' unlink("example_bids/", recursive = T)


write_task_tsv <- function(data, bids_dir, data_type = "beh",
                           filename_prefixes = c("sub-", "ses-", "task-", "run-"),
                           filename_variables = c("participant_id", "session", "task", "run"),
                           path_prefixes = c("sub-", "ses-"),
                           path_variables = c("participant_id", "session"),
                           ignore_variables=c(),
                           include_variables=c()) {

  # Convert data to data frame
  data <- as.data.frame(data)

  # Helper function. For simplicity it is easier to strip prefixes
  strip_prefixes <- function(x, to_replace = c("sub-", "ses-", "task-", "run-")) {
    x_stripped <- sapply(x, function(element) {
      gsub(paste(to_replace, collapse = "|"), "", element)
    })
    return(x_stripped)
  }

  # Remove NA from input variables
  filename_prefixes <- na.omit(filename_prefixes)
  filename_variables <- na.omit(filename_variables)
  path_prefixes <- na.omit(path_prefixes)
  path_variables <- na.omit(path_variables)

  # Check that path and name prefixes and variables vectors have equal lengths

  if (length(filename_prefixes) != length(filename_variables)) {
    stop("Error: The numbers of filename prefixes and variables need to match")
  }

  if (length(path_prefixes) != length(path_variables)) {
    stop("Error: The numbers of path prefixes and variables need to match")
  }

  # Check that all variables are actually in the data and impute if they are not (for example for task)
  for (i in 1:length(c(path_variables, filename_variables))) {
    var=c(path_variables, filename_variables)[i]
    if (! var %in% names(data)) {
      message(sprintf("Variable %s does not exist in the data and will be imputed as %s", var, names(var)))
      data[, var] <- names(var)
    }
  }

  # Strip all prefixes from the data and attach again to handle inconsistencies
  for (i in c(path_variables, filename_variables)) {
    data[, i] <- strip_prefixes(data[, i], to_replace = filename_prefixes)
  }

  # Create the main BIDS directory if it does not exist
  if (!dir.exists(bids_dir)) {
    dir.create(bids_dir, recursive = TRUE)
    message(paste("Main BIDS directory successfully created:", bids_dir))
  }

  # Create index variables the tsv file and path
  data_path_variables <- data[, path_variables]
  for (i in 1:length(path_variables)) {
    data_path_variables[, path_variables[i]] <- paste0(path_prefixes[i], data_path_variables[, path_variables[i]])
  }

  data_filename_variables <- data[, filename_variables]
  for (i in 1:length(filename_variables)) {
    data_filename_variables[, filename_variables[i]] <- paste0(filename_prefixes[i], data_filename_variables[, filename_variables[i]])
  }

  path_identifiers <- apply(data_path_variables, MARGIN = 1, FUN = function(x) (paste(x, collapse=.Platform$file.sep)))
  filename_identifiers <- apply(data_filename_variables, MARGIN = 1, FUN = function(x) (paste(x, collapse="_")))

  # Choose selected variables
  selected_variables <- names(data)[(! names(data) %in% c(filename_variables, path_variables, include_variables)) & (! names(data) %in% ignore_variables)]

  for (i in unique(filename_identifiers)) {
    # Select indices of data corresponding to the selected file
    selected_rows <- i==filename_identifiers
    data_selected <- data[selected_rows, selected_variables, drop = FALSE]

    # Directory and file names
    dir_name <- paste(bids_dir, c(unique(path_identifiers[selected_rows])), data_type, sep=.Platform$file.sep)
    filename <- sprintf("%s%s%s_%s.tsv",
                        dir_name,
                        .Platform$file.sep,
                        i,
                        data_type)

    # Create the directory
    if (!dir.exists(dir_name)) {
      dir.create(dir_name, recursive = TRUE)
      message(paste("Folder successfully created:", dir_name))
    }

    # Write the file
    write.table(data_selected, file = filename, sep = "\t", row.names = FALSE, quote = FALSE)
    message(paste("Task data saved:", filename))
  }
}
