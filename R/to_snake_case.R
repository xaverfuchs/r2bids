#' Convert a string to snake_case
#'
#' @param string A character string that needs to be converted to snake_case.
#'
#' @description
#' This function converts a given string to snake_case by replacing spaces and special characters
#' with underscores and converting all letters to lowercase.
#'
#' @return A snake_case version of the input string.
#'
#' @export
#'
#' @examples
#' to_snake_case("Hello World")
#' to_snake_case("ConvertThisString")
#'
to_snake_case <- function(string) {
  string <- gsub("([a-z])([A-Z])", "\\1_\\2", string) # Add underscores before capital letters
  string <- gsub("[^[:alnum:]]+", "_", string)        # Replace non-alphanumeric characters with underscores
  string <- tolower(string)                           # Convert the string to lowercase
  string <- gsub("^_|_$", "", string)                 # Remove leading or trailing underscores
  return(string)
}
