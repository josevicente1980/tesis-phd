# Central path resolver for the thesis project.

project_path <- function(...) {
  file.path(...)
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
