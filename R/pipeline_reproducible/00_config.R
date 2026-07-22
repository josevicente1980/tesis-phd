# Pipeline final reproducible ESPAC 2022
# Unidad final: una fila por UPA/cuestionario. Llave: Identificador textual de 17 digitos.

source(file.path("R", "paths.R"))

pipeline_root <- path_pipeline_reproducible()
raw_dir <- path_raw()
official_docs_dirs <- c(
  path_docs("espac_2022", "manuales"),
  path_docs("espac_2022", "sintaxis_txt")
)

# Insumo propio del investigador, no documentacion oficial ESPAC.
researcher_prices_file <- path_docs("espac_2022", "precios", "Precio_Junio_25.xlsx")
imputed_price_usd_kg <- 0.10

outputs_dir <- path_outputs("pipeline_espac")
intermediate_dir <- file.path(outputs_dir, "intermediate")
reports_dir <- file.path(outputs_dir, "reports")
processed_candidate_dir <- file.path(outputs_dir, "processed")
official_base_filename <- "base_final_v1.1.csv"
processed_official_file <- path_processed(official_base_filename)
candidate_file <- file.path(processed_candidate_dir, official_base_filename)
certification_report_file <- path_reports("final_pipeline_certification.md")

required_packages <- c("data.table", "dplyr", "haven", "readxl")

critical_variables <- c(
  "Identificador",
  "produccion_ec",
  "productividad_superficie",
  "productividad_trabajo",
  "fact_exp_fin"
)
