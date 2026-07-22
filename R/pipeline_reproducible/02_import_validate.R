source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))
source(path_pipeline_reproducible("01_functions.R"))

load_required_packages(required_packages)
ensure_dirs(c(outputs_dir, intermediate_dir, reports_dir, processed_candidate_dir))

raw <- read_raw_rds(raw_dir)

inventory <- data.frame(
  object = names(raw),
  rows = vapply(raw, nrow, integer(1)),
  columns = vapply(raw, ncol, integer(1)),
  source = file.path(raw_dir, paste0(names(raw), ".rds")),
  stringsAsFactors = FALSE
)
write_report(inventory, "00_raw_inventory.csv")

identifier_validation <- do.call(
  rbind,
  lapply(names(raw), function(name) validate_identifier(as.data.frame(raw[[name]]), name))
)
write_report(identifier_validation, "01_identifier_validation.csv")
write_report(identifier_validation, "identifier_validation.csv")

official_sources <- data.frame(
  source_type = c("manuales", "sintaxis_txt", "raw_data", "researcher_input"),
  path = c(
    official_docs_dirs[1],
    official_docs_dirs[2],
    raw_dir,
    researcher_prices_file
  ),
  role = c(
    "documentacion_oficial_ESPAC",
    "documentacion_oficial_ESPAC",
    "datos_crudos_ESPAC",
    "insumo_propio_investigador_no_documentacion_oficial"
  )
)
write_report(official_sources, "02_source_manifest.csv")

saveRDS(raw, file.path(intermediate_dir, "raw_objects.rds"))
