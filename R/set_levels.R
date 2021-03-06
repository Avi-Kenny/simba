#' Set simulation levels
#'
#' @description Set one or more simulation levels, which are things that vary
#'     between simulation replicates.
#' @param sim_obj A simulation object of class \code{simba}, usually created by
#'     \link{new_sim}
#' @param ... One or more key-value pairs representing simulation levels. Each
#'     value can either be a vector (for simple levels) or a list of lists (for
#'     more complex levels). See examples.
#' @param .add Only relevant if \link{set_levels} is called twice or more. On the
#'     second call, if add=FALSE (default) the old set of levels will be
#'     replaced by the new set, whereas if add=TRUE the new set of levels will
#'     be merged with the old set. See examples.
#' @return The original simulation object with the old set of levels replaced
#'     with the new set
#' @examples
#' # Basic usage is as follows:
#' sim <- new_sim()
#' sim %<>% set_levels(
#'   "n" = c(10, 100, 1000),
#'   "theta" = c(2, 3)
#' )
#' sim$levels
#'
#' # More complex levels can be set using lists:
#' sim %<>% set_levels(
#'   "n" = c(10, 100, 1000),
#'   "theta" = c(2, 3),
#'   "method" = list(
#'     "spline1" = list(knots=c(2,4), slopes=c(0.1,0.4)),
#'     "spline2" = list(knots=c(1,5), slopes=c(0.2,0.3))
#'   )
#' )
#' sim$levels
#'
#' # By default, set_levels will overwrite old levels if it is called twice:
#' sim %<>% set_levels(alpha=c(1,2), beta=c(5,6))
#' sim %<>% set_levels(alpha=c(3,4), gamma=c(7,8))
#' sim$levels
#'
#' # To merge the old levels with the new levels instead, specify .add=TRUE:
#' sim %<>% set_levels(alpha=c(1,2), beta=c(5,6))
#' sim %<>% set_levels(alpha=c(3,4), gamma=c(7,8), .add=TRUE)
#' sim$levels
#' @export
set_levels <- function(sim_obj, ..., .add=FALSE) UseMethod("set_levels")

#' @export
set_levels.simba <- function(sim_obj, ..., .add=FALSE) {

  handle_errors(sim_obj, "is.simba")
  handle_errors(.add, "is.boolean")
  if (length(list(...))==0) { stop("No levels supplied") }

  # Merge with existing levels if .add=TRUE; otherwise, overwrite
  if (.add) {

    new_list <- list(...)
    for (i in 1:length(new_list)) {
      sim_obj$levels[[names(new_list[i])]] <- c(
        sim_obj$levels[[names(new_list[i])]],
        new_list[[i]]
      )
    }

  } else {

    sim_obj$levels <- list(...)

  }


  if (!(is.list(sim_obj$levels)) || !(length(names(sim_obj$levels[which(names(sim_obj$levels) != "")])) == length(sim_obj$levels))) {
    stop("Simulation levels must be a list of key-value pairs.")
  }

  # handle_errors(sim_obj$levels, "is.named.list") # !!!!! This is not implemented

  # Extract names from lists
  levels_shallow <- list()
  levels_types <- c() # Stores whether level is a list (TRUE) or not (FALSE)
  for (i in 1:length(sim_obj$levels)) {
    if (class(sim_obj$levels[[i]])=="list") {
      # if the level is a list, it must be a named list of lists
      # first, make sure it has names
      if (length(names(sim_obj$levels[[i]])) != length(sim_obj$levels[[i]]) || "" %in% names(sim_obj$levels[[i]])){
        stop("Each item in a list level must have a name.")
      }
      # then, make sure each item in the list is, itself, a list
      for (j in 1:length(sim_obj$levels[[i]])){
        if (!is.list(sim_obj$levels[[i]][[j]])){
          stop("Each item in a list level must be a list.")
        }
      }
      levels_types <- c(levels_types, TRUE)
      levels_shallow[[names(sim_obj$levels)[i]]] <- names(sim_obj$levels[[i]])
    } else {
      levels_types <- c(levels_types, FALSE)
      levels_shallow[[names(sim_obj$levels)[i]]] <- sim_obj$levels[[i]]
    }
  }

  # Create levels_grid
  levels_grid <- expand.grid(levels_shallow, stringsAsFactors=FALSE)
  names_1 <- names(levels_grid)
  levels_grid <- cbind(1:nrow(levels_grid), levels_grid)
  names(levels_grid) <- c("level_id", names_1)

  # Attach created variables to sim_obj
  sim_obj$internals$levels_shallow <- levels_shallow
  sim_obj$internals$levels_types <- levels_types
  sim_obj$levels_grid <- levels_grid
  sim_obj$vars$num_sim_total <- nrow(sim_obj$levels_grid) *
                                     sim_obj$config$num_sim

  return (sim_obj)

}
