source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))

scripts <- file.path(
  pipeline_root,
  c(
    "02_import_validate.R",
    "03_build_modules.R",
    "04_join_final.R",
    "05_validate.R",
    "06_certify.R"
  )
)

trace <- data.frame(
  order = seq_along(scripts),
  script = scripts,
  status = "pending",
  start = as.POSIXct(NA),
  end = as.POSIXct(NA)
)

for (i in seq_along(scripts)) {
  trace$status[i] <- "running"
  trace$start[i] <- Sys.time()
  source(scripts[i], local = .GlobalEnv)
  trace$end[i] <- Sys.time()
  trace$status[i] <- "completed"
  dir.create(reports_dir, recursive = TRUE, showWarnings = FALSE)
  data.table::fwrite(trace, file.path(reports_dir, "10_pipeline_execution_trace.csv"))
}

message("Pipeline oficial reproducible ejecutado. Base oficial v1.1: ", candidate_file)
