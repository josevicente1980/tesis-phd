source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))
source(path_pipeline_reproducible("01_functions.R"))

load_required_packages(required_packages)
ensure_dirs(c(outputs_dir, intermediate_dir, reports_dir, processed_candidate_dir, dirname(certification_report_file)))

candidate <- data.table::fread(candidate_file, colClasses = list(character = "Identificador"))
validation <- data.table::fread(file.path(reports_dir, "final_base_validation.csv"))
joins <- data.table::fread(file.path(reports_dir, "join_cardinality_report.csv"))
modules <- data.table::fread(file.path(reports_dir, "module_aggregate_manifest.csv"))
price_audit <- data.table::fread(file.path(reports_dir, "price_input_audit.csv"))
price_imputations <- data.table::fread(file.path(reports_dir, "price_imputation_detail.csv"))
dimensions <- data.table::fread(file.path(reports_dir, "08_dimensions_comparison.csv"))
numeric_comparison <- if (file.exists(file.path(reports_dir, "09_numeric_comparison.csv"))) {
  data.table::fread(file.path(reports_dir, "09_numeric_comparison.csv"))
} else {
  data.table::data.table()
}

doc_files <- list.files(official_docs_dirs, recursive = TRUE, full.names = FALSE)
all_validation_passed <- all(validation$passed)

methodological_decisions <- c(
  "# Decisiones metodologicas del pipeline oficial",
  "",
  paste("Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Fuentes oficiales",
  "",
  "- Documentacion oficial ESPAC: `datos/espac_2022/manuales/`.",
  "- Sintaxis oficial ESPAC: `datos/espac_2022/sintaxis_txt/`.",
  "- Datos crudos: `data/raw/`.",
  "",
  "## Insumo metodologico del investigador",
  "",
  "- Archivo de precios: `datos/espac_2022/precios/Precio_Junio_25.xlsx`.",
  "- Este archivo no es documentacion oficial ESPAC.",
  "- Se utiliza como fuente oficial de valoracion economica dentro de la tesis.",
  "",
  "## Unidad y llave",
  "",
  "- Unidad final: una fila por UPA/cuestionario ESPAC.",
  "- Llave primaria: `Identificador` textual de 17 digitos.",
  "- El pipeline no convierte `Identificador` a numerico.",
  "",
  "## Agregacion y uniones",
  "",
  "- Cada modulo de detalle se agrega por `Identificador` antes de unirse.",
  "- Las uniones finales son `left_join` uno a uno contra la base maestra.",
  "- Toda union valida unicidad izquierda, unicidad derecha y expansion cero.",
  "- No se permiten uniones muchos-a-muchos.",
  "",
  "## Precios",
  "",
  "- Para `avena`, se usa siempre el menor precio observado.",
  paste0("- Para productos sin precio, se imputa precio fijo de `", imputed_price_usd_kg, " USD/kg`."),
  "- Cada imputacion se registra por modulo, UPA, producto, cantidad, motivo y valor imputado.",
  "",
  "## Produccion y productividad",
  "",
  "- `produccion_ec` es la suma de las variables `valor_*` construidas por modulo.",
  "- `productividad_superficie = produccion_ec / cg_superficie` cuando `cg_superficie > 0`.",
  "- `productividad_trabajo = produccion_ec / eu_k1301` cuando `eu_k1301 > 0`."
)
writeLines(methodological_decisions, file.path(reports_dir, "methodological_decisions.md"), useBytes = TRUE)

top_differences <- if (nrow(numeric_comparison) > 0) {
  numeric_comparison[order(-max_abs_diff)][1:min(.N, 10)]
} else {
  data.table::data.table(variable = character(), max_abs_diff = numeric(), mean_abs_diff = numeric(), n_diff = integer())
}

imputed_products <- if (nrow(price_imputations) > 0) {
  paste(sort(unique(price_imputations$product)), collapse = ", ")
} else {
  "ninguno"
}

certification <- c(
  "# Certificacion del pipeline oficial reproducible",
  "",
  paste("Fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  "",
  "## Declaracion",
  "",
  "El pipeline `R/pipeline_reproducible/` queda definido como pipeline oficial reproducible de la tesis. El pipeline historico `R/pipeline_espac/` queda congelado como respaldo y no fue modificado por esta ejecucion.",
  "",
  paste0("Base oficial vigente: `data/processed/", official_base_filename, "`."),
  "",
  "Nombre historico documentado solo por compatibilidad: `15_Base_final_diciembre.csv`.",
  "",
  "## Documentacion oficial utilizada",
  "",
  paste0("- `", official_docs_dirs[1], "`"),
  paste0("- `", official_docs_dirs[2], "`"),
  "",
  "Archivos de documentacion y sintaxis detectados:",
  "",
  paste0("- `", doc_files, "`"),
  "",
  "## Insumos utilizados",
  "",
  paste0("- Datos crudos: `", raw_dir, "`."),
  paste0("- Precios del investigador: `", researcher_prices_file, "`."),
  "",
  "## Metodologia aplicada",
  "",
  "- Una fila final por UPA/cuestionario.",
  "- `Identificador` textual de 17 digitos.",
  "- Agregacion de cada modulo antes de uniones.",
  "- Uniones finales uno a uno con validacion de cardinalidad.",
  "- Produccion economica por suma de modulos de valoracion.",
  "- Productividades calculadas desde `produccion_ec`, superficie y trabajo.",
  "",
  "## Reglas de imputacion",
  "",
  "- `avena`: menor precio observado.",
  paste0("- Productos sin precio: `", imputed_price_usd_kg, " USD/kg`."),
  paste0("- Filas imputadas: ", nrow(price_imputations), "."),
  paste0("- Productos imputados: ", imputed_products, "."),
  "",
  "## Reglas de agregacion",
  "",
  "- `valor_cp = sum(cp_prod * 1000 * Precio_kg)` por `Identificador`.",
  "- `valor_ct = sum(ct_prod * 1000 * Precio_kg)` por `Identificador`.",
  "- `valor_fp = sum(fp_k709 / 20 * Precio_kg)` por `Identificador`.",
  "- `valor_ft = sum(ft_k723 / 20 * Precio_kg)` por `Identificador`.",
  "- `valor_pc = sum(cp_k409ha * 5000 * Precio_kg)` por `Identificador`.",
  "- Modulos pecuarios se agregan por `Identificador` despues de aplicar sus formulas de valoracion.",
  "",
  "## Reglas de union",
  "",
  paste0("- Uniones auditadas: ", nrow(joins), "."),
  paste0("- Expansion total detectada: ", sum(joins$expansion), "."),
  paste0("- Uniones no uno a uno: ", sum(joins$cardinality != "uno a uno"), "."),
  "",
  "## Validaciones ejecutadas",
  "",
  paste0("- Validaciones totales: ", nrow(validation), "."),
  paste0("- Validaciones aprobadas: ", sum(validation$passed), "."),
  paste0("- Validaciones fallidas: ", sum(!validation$passed), "."),
  paste0("- Resultado global: ", ifelse(all_validation_passed, "satisfactorio", "no satisfactorio"), "."),
  "",
  "## Dimensiones",
  "",
  paste0("- Filas de la base oficial v1.0: ", dimensions$candidate[dimensions$metric == "rows"], "."),
  paste0("- Columnas de la base oficial v1.0: ", dimensions$candidate[dimensions$metric == "columns"], "."),
  paste0("- Identificadores unicos de la base oficial v1.0: ", dimensions$candidate[dimensions$metric == "unique_identifiers"], "."),
  "",
  "## Diferencias contra base anterior",
  "",
  if (nrow(top_differences) == 0) {
    "No se genero comparacion numerica contra base anterior."
  } else {
    apply(top_differences, 1, function(row) {
      paste0("- `", row[["variable"]], "`: max_abs_diff=", row[["max_abs_diff"]],
             ", mean_abs_diff=", row[["mean_abs_diff"]], ", n_diff=", row[["n_diff"]], ".")
    })
  },
  "",
  "## Limitaciones conocidas",
  "",
  "- El archivo de precios es un insumo metodologico del investigador, no documentacion oficial ESPAC.",
  "- La imputacion `0.10 USD/kg` para productos sin precio es una regla metodologica explicita del investigador.",
  "- La base v1.0 no busca reproducir exactamente la base historica; la reemplaza como base analitica oficial reproducible.",
  paste0("- El pipeline oficial genera `", official_base_filename, "`."),
  "",
  "## Trazabilidad",
  "",
  "- `outputs/pipeline_espac/reports/identifier_validation.csv`.",
  "- `outputs/pipeline_espac/reports/module_aggregate_manifest.csv`.",
  "- `outputs/pipeline_espac/reports/price_input_audit.csv`.",
  "- `outputs/pipeline_espac/reports/price_imputation_detail.csv`.",
  "- `outputs/pipeline_espac/reports/join_cardinality_report.csv`.",
  "- `outputs/pipeline_espac/reports/final_base_validation.csv`.",
  "- `outputs/pipeline_espac/reports/methodological_decisions.md`.",
  "",
  "## Declaracion de reproducibilidad",
  "",
  paste0("Con los datos crudos, la documentacion oficial ESPAC, el archivo de precios del investigador y los scripts en `R/pipeline_reproducible/`, `", official_base_filename, "` puede regenerarse ejecutando `Rscript R/pipeline_reproducible/run_pipeline.R`."),
  "",
  "## Recomendacion tecnica",
  "",
  if (all_validation_passed) {
    "Las validaciones tecnicas son satisfactorias. La base v1.0 queda certificada como base oficial de la tesis doctoral."
  } else {
    "No se recomienda reemplazar la base anterior hasta resolver las validaciones fallidas."
  }
)

writeLines(unlist(certification), certification_report_file, useBytes = TRUE)
