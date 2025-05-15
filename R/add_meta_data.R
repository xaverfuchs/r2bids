#' Add variable to decalre to metadata
#'
#' This function adds one variable with descriptions to an existing object of the class metadata.
#'
#' @param meta_data The object of the class metadata created with create_meta_data().
#' @param variable_name The name of the added variable provided as a character string.
#' @param ... Any number of variable attributes provided as character strings or lists (see examples).
#'
#' @return An updated object of class "metadata".
#' @export
#'
#' @examples
#' meta_data <- create_meta_data() #create object
#' meta_data <- add_meta_data(meta_data, variable_name = "session") #a self-explanatory variable
#' meta_data <- add_meta_data(meta_data, variable_name = "response_time", Description = "Response time in milliseconds", Units = "ms") #provide information for reaction time variable
#' meta_data <- add_meta_data(meta_data, variable_name = "age", Description = "Age of the participant", Type = "integer", Units = "years") #provide information for the age variable
#' meta_data <- add_meta_data(meta_data = meta_data, variable_name = "condition", labels = list("experimental"="500 ml of pure alcohol", "control"="a sober session")) # note that labels for conditions are provided as a names list.
#' meta_data #show resulting structure
add_meta_data <- function(meta_data, variable_name, ...) {
  stopifnot(inherits(meta_data, "metadata"))

  fields <- list(...)
  meta_data[[variable_name]] <- fields

  return(meta_data)
}
