source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))
source(path_pipeline_reproducible("01_functions.R"))

load_required_packages(required_packages)
ensure_dirs(c(outputs_dir, intermediate_dir, reports_dir, processed_candidate_dir))

candidate <- data.table::fread(candidate_file, colClasses = list(character = "Identificador"))
candidate <- as.data.frame(candidate)

join_cardinality <- data.table::fread(file.path(reports_dir, "join_cardinality_report.csv"))
module_manifest <- data.table::fread(file.path(reports_dir, "module_aggregate_manifest.csv"))
price_imputations <- data.table::fread(file.path(reports_dir, "price_imputation_detail.csv"))
value_columns <- grep("^valor_", names(candidate), value = TRUE)
value_columns <- value_columns[!grepl("_rows$|_productos$|_precio_imputado", value_columns)]
production_rebuilt <- rowSums(candidate[value_columns], na.rm = TRUE)
factor_exp <- if ("fact_exp_fin" %in% names(candidate)) as_num(candidate$fact_exp_fin) else NA_real_
surface_productivity_rebuilt <- ifelse(
  !is.na(candidate$cg_superficie) & as_num(candidate$cg_superficie) > 0,
  candidate$produccion_ec / as_num(candidate$cg_superficie),
  NA_real_
)
labor_productivity_rebuilt <- ifelse(
  !is.na(candidate$eu_k1301) & as_num(candidate$eu_k1301) > 0,
  candidate$produccion_ec / as_num(candidate$eu_k1301),
  NA_real_
)

validation <- data.frame(
  check = c(
    "rows_positive",
    "columns_positive",
    "identifier_unique",
    "identifier_17_digits",
    "identifier_no_missing",
    "duplicate_identifiers",
    "required_columns_present",
    "critical_variables_present",
    "join_cardinality_no_expansion",
    "join_cardinality_one_to_one",
    "factor_expansion_present",
    "factor_expansion_numeric_nonnegative",
    "production_economic_formula_consistent",
    "production_economic_nonnegative",
    "productivity_surface_formula_consistent",
    "productivity_labor_formula_consistent",
    "module_aggregates_unique",
    "module_aggregates_no_duplicate_identifiers",
    "price_imputation_trace_complete",
    "price_imputation_rule_010",
    "module_consistency_candidate_rows"
  ),
  passed = c(
    nrow(candidate) > 0,
    ncol(candidate) > 0,
    anyDuplicated(candidate$Identificador) == 0,
    all(grepl("^[0-9]{17}$", candidate$Identificador)),
    !any(is.na(candidate$Identificador) | candidate$Identificador == ""),
    sum(duplicated(candidate$Identificador)) == 0,
    all(c("Identificador", "produccion_ec", "productividad_superficie", "productividad_trabajo") %in% names(candidate)),
    all(critical_variables %in% names(candidate)),
    all(join_cardinality$expansion == 0),
    all(join_cardinality$cardinality == "uno a uno"),
    "fact_exp_fin" %in% names(candidate),
    all(!is.na(factor_exp) & factor_exp >= 0),
    all(abs(candidate$produccion_ec - production_rebuilt) < 1e-7, na.rm = TRUE),
    all(candidate$produccion_ec >= 0, na.rm = TRUE),
    all(abs(candidate$productividad_superficie - surface_productivity_rebuilt) < 1e-7 |
          (is.na(candidate$productividad_superficie) & is.na(surface_productivity_rebuilt)), na.rm = TRUE),
    all(abs(candidate$productividad_trabajo - labor_productivity_rebuilt) < 1e-7 |
          (is.na(candidate$productividad_trabajo) & is.na(labor_productivity_rebuilt)), na.rm = TRUE),
    all(module_manifest$output_rows == module_manifest$output_unique_identifiers),
    all(module_manifest$output_duplicate_identifiers == 0),
    all(c("module", "variable", "Identificador", "product", "quantity_used",
          "imputation_reason", "imputed_economic_value") %in% names(price_imputations)),
    if (nrow(price_imputations) == 0) TRUE else all(price_imputations$imputed_price_usd_kg == imputed_price_usd_kg),
    all(join_cardinality$result_rows == nrow(candidate))
  ),
  value = c(
    nrow(candidate),
    ncol(candidate),
    anyDuplicated(candidate$Identificador),
    sum(!grepl("^[0-9]{17}$", candidate$Identificador)),
    sum(is.na(candidate$Identificador) | candidate$Identificador == ""),
    sum(duplicated(candidate$Identificador)),
    sum(!c("Identificador", "produccion_ec", "productividad_superficie", "productividad_trabajo") %in% names(candidate)),
    sum(!critical_variables %in% names(candidate)),
    sum(join_cardinality$expansion),
    sum(join_cardinality$cardinality != "uno a uno"),
    sum(!"fact_exp_fin" %in% names(candidate)),
    sum(is.na(factor_exp) | factor_exp < 0),
    max(abs(candidate$produccion_ec - production_rebuilt), na.rm = TRUE),
    sum(candidate$produccion_ec < 0, na.rm = TRUE),
    max(abs(candidate$productividad_superficie - surface_productivity_rebuilt), na.rm = TRUE),
    max(abs(candidate$productividad_trabajo - labor_productivity_rebuilt), na.rm = TRUE),
    sum(module_manifest$output_rows != module_manifest$output_unique_identifiers),
    sum(module_manifest$output_duplicate_identifiers),
    nrow(price_imputations),
    if (nrow(price_imputations) == 0) 0 else sum(price_imputations$imputed_price_usd_kg != imputed_price_usd_kg),
    sum(join_cardinality$result_rows != nrow(candidate))
  )
)

technology_variables <- c(
  "usa_riego_global",
  "usa_fert_global",
  "usa_plag_global"
)
expected_technology_frequencies <- data.frame(
  variable = technology_variables,
  SI = c(9020L, 14556L, 11876L),
  NO = c(16306L, 10770L, 13450L),
  NO_APLICA = rep(16705L, 3),
  NA_real = rep(413L, 3),
  stringsAsFactors = FALSE
)

modules <- readRDS(file.path(intermediate_dir, "module_aggregates.rds"))
technology_source <- modules$insumos
technology_source <- technology_source[
  match(candidate$Identificador, technology_source$Identificador),
  ,
  drop = FALSE
]
source_presence_cols <- grep("_tiene_registro$", names(technology_source), value = TRUE)
source_has_module <- technology_source$tiene_modulo_cultivo %in% TRUE
source_target_surface <- technology_source$superficie_objetivo_positiva %in% TRUE

technology_details <- do.call(rbind, lapply(seq_along(technology_variables), function(i) {
  variable <- technology_variables[i]
  suffix <- c("_usa_riego$", "_usa_fertiliz$", "_usa_plaguicidas$")[i]
  source_columns <- grep(suffix, names(technology_source), value = TRUE)
  source_yes <- rowSums(technology_source[source_columns] == TRUE, na.rm = TRUE) > 0
  observed <- as.character(candidate[[variable]])
  data.frame(
    variable = variable,
    SI = sum(observed == "SI", na.rm = TRUE),
    NO = sum(observed == "NO", na.rm = TRUE),
    NO_APLICA = sum(observed == "NO_APLICA", na.rm = TRUE),
    NA_real = sum(is.na(observed) | observed == ""),
    invalid_domain = sum(
      !is.na(observed) & observed != "" &
        !observed %in% c("SI", "NO", "NO_APLICA")
    ),
    source_yes_ending_as_no = sum(source_yes & observed == "NO", na.rm = TRUE),
    no_without_applicable_record = sum(observed == "NO" & !source_has_module, na.rm = TRUE),
    no_aplica_with_record_or_surface = sum(
      observed == "NO_APLICA" & (source_has_module | source_target_surface),
      na.rm = TRUE
    ),
    missing_target_surface_without_detail = sum(
      (is.na(observed) | observed == "") & !source_has_module & source_target_surface,
      na.rm = TRUE
    ),
    stringsAsFactors = FALSE
  )
}))
write_report(technology_details, "11_technology_variables_validation.csv")

frequency_match <- all(
  technology_details[c("variable", "SI", "NO", "NO_APLICA", "NA_real")] ==
    expected_technology_frequencies
)
technology_validation <- data.frame(
  check = c(
    "final_rows_42444",
    "final_unique_identifiers_42444",
    "technology_variables_present",
    "technology_domain_exclusive",
    "technology_expected_frequencies",
    "technology_not_constant",
    "technology_source_yes_never_no",
    "technology_no_only_with_applicable_record",
    "technology_no_aplica_only_without_record_or_surface",
    "technology_413_target_surface_without_detail_are_na"
  ),
  passed = c(
    nrow(candidate) == 42444L,
    length(unique(candidate$Identificador)) == 42444L,
    all(technology_variables %in% names(candidate)),
    all(technology_details$invalid_domain == 0L),
    frequency_match,
    all(technology_details$SI > 0L & technology_details$NO > 0L),
    all(technology_details$source_yes_ending_as_no == 0L),
    all(technology_details$no_without_applicable_record == 0L),
    all(technology_details$no_aplica_with_record_or_surface == 0L),
    all(technology_details$missing_target_surface_without_detail == 413L)
  ),
  value = c(
    nrow(candidate),
    length(unique(candidate$Identificador)),
    sum(!technology_variables %in% names(candidate)),
    sum(technology_details$invalid_domain),
    sum(!technology_details[c("SI", "NO", "NO_APLICA", "NA_real")] ==
          expected_technology_frequencies[c("SI", "NO", "NO_APLICA", "NA_real")]),
    sum(technology_details$SI == 0L | technology_details$NO == 0L),
    sum(technology_details$source_yes_ending_as_no),
    sum(technology_details$no_without_applicable_record),
    sum(technology_details$no_aplica_with_record_or_surface),
    paste(technology_details$missing_target_surface_without_detail, collapse = "|")
  ),
  stringsAsFactors = FALSE
)
validation <- rbind(validation, technology_validation)
write_report(validation, "07_final_base_validation.csv")
write_report(validation, "final_base_validation.csv")

dimensions <- data.frame(
  metric = c("rows", "columns", "unique_identifiers"),
  candidate = c(nrow(candidate), ncol(candidate), length(unique(candidate$Identificador)))
)

if (file.exists(processed_official_file)) {
  official <- data.table::fread(processed_official_file, colClasses = list(character = "Identificador"))
  official <- as.data.frame(official)
  dimensions$official <- c(nrow(official), ncol(official), length(unique(official$Identificador)))
  common_columns <- intersect(names(official), names(candidate))
  column_report <- data.frame(
    variable = union(names(official), names(candidate)),
    in_official = union(names(official), names(candidate)) %in% names(official),
    in_candidate = union(names(official), names(candidate)) %in% names(candidate)
  )
  write_report(column_report, "08_columns_comparison.csv")

  common_ids <- intersect(official$Identificador, candidate$Identificador)
  official_aligned <- official[match(common_ids, official$Identificador), common_columns, drop = FALSE]
  candidate_aligned <- candidate[match(common_ids, candidate$Identificador), common_columns, drop = FALSE]
  numeric_common <- common_columns[
    vapply(official_aligned, is.numeric, logical(1)) &
      vapply(candidate_aligned, is.numeric, logical(1))
  ]
  numeric_diff <- do.call(rbind, lapply(numeric_common, function(column) {
    diff <- candidate_aligned[[column]] - official_aligned[[column]]
    data.frame(
      variable = column,
      max_abs_diff = max(abs(diff), na.rm = TRUE),
      mean_abs_diff = mean(abs(diff), na.rm = TRUE),
      n_diff = sum(abs(diff) > 1e-9, na.rm = TRUE)
    )
  }))
  if (is.null(numeric_diff)) numeric_diff <- data.frame()
  write_report(numeric_diff, "09_numeric_comparison.csv")
}

write_report(dimensions, "08_dimensions_comparison.csv")
