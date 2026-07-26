# Central path resolver for the thesis project.

find_project_root <- function(start = getwd()) {
  current <- normalizePath(
    start,
    winslash = "/",
    mustWork = TRUE
  )

  repeat {
    if (
      file.exists(file.path(current, "_quarto.yml")) &&
        dir.exists(file.path(current, "R"))
    ) {
      return(current)
    }

    parent <- dirname(current)

    if (identical(parent, current)) {
      stop(
        "No se pudo localizar la raíz del proyecto TESIS_PhD desde: ",
        start,
        call. = FALSE
      )
    }

    current <- parent
  }
}

project_root <- find_project_root()

project_path <- function(...) {
  file.path(project_root, ...)
}

path_raw <- function(...) {
  project_path("data", "raw", ...)
}

path_processed <- function(...) {
  project_path("data", "processed", ...)
}

path_shapes <- function(...) {
  project_path("data", "shapes", ...)
}

path_docs <- function(...) {
  project_path("docs", ...)
}

path_outputs <- function(...) {
  project_path("outputs", ...)
}

path_reports <- function(...) {
  project_path("agent", "reports", ...)
}

path_pipeline_reproducible <- function(...) {
  project_path("R", "pipeline_reproducible", ...)
}

path_pipeline_intermediate <- function(...) {
  path_outputs("pipeline_espac", "intermediate", ...)
}

path_pipeline_figures <- function(...) {
  path_outputs("pipeline_espac", "reports", "figures", ...)
}
