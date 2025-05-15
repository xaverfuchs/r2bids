#' Instantiate a meta data structure
#'
#' This function creates an object of the class "metadata". This class serves as a collector for variables to be declared in the metadata JSON file.
#'
#' @return Object of class "metadata".
#' @export
#'
#' @examples
#' meta_data <- create_meta_data()
#'
#'
create_meta_data <- function() {
  meta_data <- list()
  class(meta_data) <- "metadata"
  return(meta_data)
}





#overview of data set: list type and if character or factor: list unique labels









#next step: a function to show data set variables



#now the validater function





