source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))
source(path_pipeline_reproducible("01_functions.R"))

load_required_packages(required_packages)
ensure_dirs(c(outputs_dir, intermediate_dir, reports_dir, processed_candidate_dir))

modules <- readRDS(file.path(intermediate_dir, "module_aggregates.rds"))
base <- modules$base_master
stop_if_not_unique(base, "base_master")

join_report <- list()
for (name in setdiff(names(modules), "base_master")) {
  base <- join_one_to_one(base, modules[[name]], name, join_report)
  join_report <- attr(base, "join_report")
}

value_columns <- grep("^valor_", names(base), value = TRUE)
for (column in value_columns) {
  base[[column]][is.na(base[[column]])] <- 0
}
base$produccion_ec <- rowSums(base[value_columns], na.rm = TRUE)

base$productividad_superficie <- ifelse(
  !is.na(base$cg_superficie) & as_num(base$cg_superficie) > 0,
  base$produccion_ec / as_num(base$cg_superficie),
  NA_real_
)
base$productividad_trabajo <- ifelse(
  !is.na(base$eu_k1301) & as_num(base$eu_k1301) > 0,
  base$produccion_ec / as_num(base$eu_k1301),
  NA_real_
)

input_cols <- grep("_usa_", names(base), value = TRUE)
riego_cols <- grep("_usa_riego$", input_cols, value = TRUE)
fert_cols <- grep("_usa_fertiliz$", input_cols, value = TRUE)
plag_cols <- grep("_usa_plaguicidas$", input_cols, value = TRUE)
presence_cols <- grep("_tiene_registro$", names(base), value = TRUE)
has_module <- base$tiene_modulo_cultivo %in% TRUE
target_surface_positive <- base$superficie_objetivo_positiva %in% TRUE

base$usa_riego_global <- classify_global_input(
  consolidate_logical_inputs(base, riego_cols, presence_cols),
  has_module,
  target_surface_positive
)
base$usa_fert_global <- classify_global_input(
  consolidate_logical_inputs(base, fert_cols, presence_cols),
  has_module,
  target_surface_positive
)
base$usa_plag_global <- classify_global_input(
  consolidate_logical_inputs(base, plag_cols, presence_cols),
  has_module,
  target_surface_positive
)

base <- base[, !names(base) %in% c(
  presence_cols,
  "tiene_modulo_cultivo",
  "superficie_objetivo_positiva"
), drop = FALSE]

base <- base[order(base$Identificador), ]

data.table::fwrite(base, candidate_file)
write_report(do.call(rbind, join_report), "06_join_cardinality_report.csv")
write_report(do.call(rbind, join_report), "join_cardinality_report.csv")

saveRDS(base, file.path(intermediate_dir, "candidate_base.rds"))
