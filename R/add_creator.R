#' Add a "creator" function
#'
#' @description Add a "creator" function to your simulation object. A creator is
#'     a function that generates a dataset for use in your simulation.
#' @param sim_obj A simulation object of class \code{simba}, usually created by
#'     \link{new_sim}
#' @param name A name for the creator function
#' @param fn A creator function
#' @details \itemize{
#'   \item{There are two ways to use \code{add_creator}. If two arguments are
#'     supplied (\code{sim_obj} and \code{fn}), you can create a function
#'     separately and add it to your simulation object later. If three arguments
#'     are supplied, you can do both at the same time, using an anonymous
#'     function for the \code{fn} argument. See examples.}
#'   \item{Your creator will be stored in \code{sim_obj$creators}. If you added a
#'     creator called \code{create_data}, you can test it out by running
#'     \code{sim$creators$create_data()}. See examples.}
#' }
#' @return The original simulation object with the new creator function added
#' @examples
#' # The first way to use add_creator is to declare a function and add it to
#' # your simulation object later:
#'
#' sim <- new_sim()
#' create_data <- function (n) { rpois(n, lambda=5) }
#' sim %<>% add_creator(create_data)
#'
#' # The second way is to do both at the same time:
#'
#' sim <- new_sim()
#' sim %<>% add_creator("create_data", function(n) {
#'   rpois(n, lambda=5)
#' })
#'
#' # With either option, you can test your function as follows:
#'
#' sim$creators$create_data(10)
#' @export
add_creator <- function(sim_obj, name, fn) UseMethod("add_creator")

#' @export
add_creator.simba <- function(sim_obj, name, fn) {

  handle_errors(sim_obj, "is.simba")
  if (missing(name) && missing(fn)) {
    stop("You must provide a function to add_creator.")
  }

  # Handle case when only one of {name,fn} is given
  if (missing(name)) {
    name <- deparse(substitute(fn))
  }
  if (missing(fn)) {
    fn <- name
    name <- deparse(substitute(name))
  }

  handle_errors(name, "is.character")
  handle_errors(fn, "is.function")

  environment(fn) <- sim_obj$vars$env
  sim_obj$creators[[name]] <- fn
  assign(x=name, value=fn, envir=sim_obj$vars$env)

  return (sim_obj)

}
