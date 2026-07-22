source(file.path("R", "paths.R"))
source(path_pipeline_reproducible("00_config.R"))
source(path_pipeline_reproducible("01_functions.R"))

load_required_packages(required_packages)
ensure_dirs(c(outputs_dir, intermediate_dir, reports_dir, processed_candidate_dir))

raw <- readRDS(file.path(intermediate_dir, "raw_objects.rds"))
price_info <- standardize_price_table(researcher_prices_file)
prices <- price_info$clean
write_report(price_info$audit, "03_price_input_audit.csv")

module_report <- list()
price_audit <- list()
price_imputation_detail <- list()

record_module <- function(name, input, output, grain, notes = "") {
  module_report[[length(module_report) + 1]] <<- data.frame(
    module = name,
    input_rows = nrow(input),
    input_unique_identifiers = length(unique(as_id(input$Identificador))),
    output_rows = nrow(output),
    output_unique_identifiers = length(unique(output$Identificador)),
    output_duplicate_identifiers = nrow(output) - length(unique(output$Identificador)),
    grain = grain,
    notes = notes,
    stringsAsFactors = FALSE
  )
  output
}

# Caracteristicas generales: base maestra UPA.
cgnac <- as.data.frame(raw$cgnac2022)
cgnac$Identificador <- as_id(cgnac$Identificador)
stop_if_not_unique(cgnac, "cgnac2022")
base_master <- cgnac[, intersect(
  c("Identificador", "ual_prov", "ual_estr", "ual_segm", "cg_k100", "cg_k101",
    "cg_k102", "cg_se_define", "edad_rango", "cg_superficie", "sup_ha",
    "Productor", "cg_dispo_internet"),
  names(cgnac)
), drop = FALSE]
base_master <- record_module("base_master_cgnac", cgnac, base_master, "UPA/cuestionario")

# Uso de suelo y tenencia.
sunac <- data.table::as.data.table(raw$sunac2022)
sunac[, Identificador := as_id(Identificador)]
sunac[, su_tenencia_label := as_label(su_tenencia)]
sunac[, tenencia_grupo := data.table::fcase(
  su_tenencia_label == "DUEÑO", "dueño",
  su_tenencia_label == "ARRENDATARIO", "arrendamiento",
  default = "especiales"
)]
sunac_agg <- sunac[, .(
  sup_total_ha = safe_sum(supertotal),
  sup_uso_total_ha = safe_sum(su_k202ha),
  area.total = safe_sum(su_k202ha),
  fact_exp_fin = first_non_missing(as.character(fact_exp_fin)),
  fact_exp_fin_unique_values = data.table::uniqueN(fact_exp_fin, na.rm = TRUE)
), by = Identificador]
tenencia_wide <- sunac[, .(area_ha = safe_sum(supertotal)), by = .(Identificador, tenencia_grupo)]
tenencia_wide[, tenencia_var := paste0("tenencia_area_", tenencia_grupo)]
tenencia_cast <- data.table::dcast(
  tenencia_wide,
  Identificador ~ tenencia_var,
  value.var = "area_ha",
  fill = 0
)
for (column in c("tenencia_area_dueño", "tenencia_area_arrendamiento", "tenencia_area_especiales")) {
  if (!column %in% names(tenencia_cast)) tenencia_cast[, (column) := 0]
}
tenencia_mayor <- tenencia_cast[, .(
  clase.mayoria = data.table::fcase(
    tenencia_area_dueño >= tenencia_area_arrendamiento &
      tenencia_area_dueño >= tenencia_area_especiales, "dueño",
    tenencia_area_arrendamiento >= tenencia_area_especiales, "arrendamiento",
    default = "especiales"
  )
), by = Identificador]
tenencia_mayor[, `:=`(
  dueño = as.integer(clase.mayoria == "dueño"),
  arrendamiento = as.integer(clase.mayoria == "arrendamiento"),
  especiales = as.integer(clase.mayoria == "especiales")
)]
tenencia_mayor <- tenencia_mayor[, .(
  Identificador, dueño, arrendamiento, especiales, clase.mayoria
)]
tenencia_area_report <- tenencia_cast[, .(
  Identificador,
  area_dueño = tenencia_area_dueño,
  area_arrendamiento = tenencia_area_arrendamiento,
  area_especiales = tenencia_area_especiales
)]
sunac_agg <- Reduce(function(x, y) merge(x, y, by = "Identificador", all.x = TRUE),
                    list(sunac_agg, tenencia_cast, tenencia_mayor, tenencia_area_report))
sunac_agg <- record_module("uso_suelo_tenencia", as.data.frame(sunac), as.data.frame(sunac_agg), "UPA agregada")

crop_value <- function(df, table_name, product_var, value_expr, prefix) {
  df <- as.data.frame(df)
  df$Identificador <- as_id(df$Identificador)
  with_prices <- add_prices(df, prices, product_var, table_name, price_audit)
  price_audit <<- attr(with_prices, "price_audit")
  with_prices$valor_tmp <- value_expr(with_prices)
  quantity_used <- if (prefix %in% c("ad", "cp", "ct")) {
    as_num(with_prices[[c(ad = "ad_prod", cp = "cp_prod", ct = "ct_prod")[[prefix]]]]) * 1000
  } else if (prefix %in% c("fp", "ft")) {
    as_num(with_prices[[c(fp = "fp_k709", ft = "ft_k723")[[prefix]]]]) / 20
  } else if (prefix == "pc") {
    as_num(with_prices$cp_k409ha) * 5000
  } else {
    rep(NA_real_, nrow(with_prices))
  }
  imputed_rows <- with_prices$precio_imputado %in% TRUE
  if (any(imputed_rows, na.rm = TRUE)) {
    price_imputation_detail[[length(price_imputation_detail) + 1]] <<- data.frame(
      module = table_name,
      variable = paste0("valor_", prefix),
      Identificador = with_prices$Identificador[imputed_rows],
      product_var = product_var,
      product = with_prices$Producto[imputed_rows],
      quantity_used = quantity_used[imputed_rows],
      imputed_price_usd_kg = imputed_price_usd_kg,
      imputation_reason = "producto_sin_precio_en_insumo_investigador",
      imputed_economic_value = with_prices$valor_tmp[imputed_rows],
      stringsAsFactors = FALSE
    )
  }
  dt <- data.table::as.data.table(with_prices)
  out <- dt[, .(
    valor = sum(valor_tmp, na.rm = TRUE),
    rows_source = .N,
    products_source = data.table::uniqueN(Producto),
    imputed_price_rows = sum(precio_imputado, na.rm = TRUE),
    imputed_price_products = paste(sort(unique(Producto[precio_imputado])), collapse = "|")
  ), by = Identificador]
  names(out) <- c("Identificador", paste0("valor_", prefix), paste0(prefix, "_rows"),
                  paste0(prefix, "_productos"), paste0(prefix, "_precio_imputado_rows"),
                  paste0(prefix, "_precio_imputado_productos"))
  record_module(table_name, df, as.data.frame(out), "UPA agregada")
}

adnac_agg <- crop_value(raw$adnac2022, "adnac2022", "rc_clacul",
                        function(x) as_num(x$ad_prod) * 1000 * x$Precio_kg, "ad")
cpnac_agg <- crop_value(raw$cpnac2022, "cpnac2022", "rc_clacul",
                        function(x) as_num(x$cp_prod) * 1000 * x$Precio_kg, "cp")
ctnac_agg <- crop_value(raw$ctnac2022, "ctnac2022", "rc_clacul",
                        function(x) as_num(x$ct_prod) * 1000 * x$Precio_kg, "ct")
fpnac_agg <- crop_value(raw$fpnac2022, "fpnac2022", "rc_clacul",
                        function(x) as_num(x$fp_k709) / 20 * x$Precio_kg, "fp")
ftnac_agg <- crop_value(raw$ftnac2022, "ftnac2022", "rc_clacul",
                        function(x) as_num(x$ft_k723) / 20 * x$Precio_kg, "ft")
pcnac_agg <- crop_value(raw$pcnac2022, "pcnac2022", "rc_clacul",
                        function(x) as_num(x$cp_k409ha) * 5000 * x$Precio_kg, "pc")

animal_aggregate <- function(df, table_name, value_expr, prefix) {
  df <- as.data.frame(df)
  df$Identificador <- as_id(df$Identificador)
  df$valor_tmp <- value_expr(df)
  dt <- data.table::as.data.table(df)
  out <- dt[, .(
    valor = sum(valor_tmp, na.rm = TRUE),
    rows_source = .N
  ), by = Identificador]
  names(out) <- c("Identificador", paste0("valor_", prefix), paste0(prefix, "_rows"))
  record_module(table_name, df, as.data.frame(out), "UPA agregada")
}

acnac_agg <- animal_aggregate(raw$acnac2022, "acnac2022", function(x) {
  gallina <- as_num(x$ac_k1201) * 1.86 * 2.34
  pollo <- as_num(x$ac_k1202) * 1.86 * 2.4
  pato <- as_num(x$ac_k1203) * 4.85 * 3.8
  huevo <- as_num(x$ac_k1216) * 0.09
  rowSums(data.frame(gallina, pollo, pato, huevo), na.rm = TRUE)
}, "ac")

apnac_agg <- animal_aggregate(raw$apnac2022, "apnac2022", function(x) {
  rowSums(data.frame(
    ponedoras = as_num(x$ap_ctponedoras) * 1.86 * 2.34,
    reproductoras = as_num(x$ap_ctreproductoras) * 1.86 * 2.34,
    pollitos = as_num(x$ap_ctpollitos) * 1.86 * 2.4,
    pavos = as_num(x$ap_ctpavos) * 5.22 * 15,
    codornices = as_num(x$ap_ctcodornices) * 3.38 * 0.2,
    huevos = as_num(x$ap_k1238) * 0.09,
    huevos_codor = as_num(x$ap_prod_hcodor) * 0.1
  ), na.rm = TRUE)
}, "ap")

glnac_agg <- animal_aggregate(raw$glnac2022, "glnac2022", function(x) {
  rowSums(data.frame(
    terneros = as_num(x$gl_k802) * 1.79 * 300,
    toretes = as_num(x$gl_k803) * 1.78 * 450,
    toros = as_num(x$gl_k804) * 1.78 * 650,
    terneras = as_num(x$gl_k805) * 1.55 * 200,
    vaconas = as_num(x$gl_k806) * 1.55 * 300,
    vacas = as_num(x$gl_k807) * 1.45 * 400,
    leche = as_num(x$litros_ordeñados) * 0.43
  ), na.rm = TRUE)
}, "gl")

gpnac_agg <- animal_aggregate(raw$gpnac2022, "gpnac2022", function(x) {
  rowSums(data.frame(
    lechon = as_num(x$gp_totanio_men2m) * 2.39 * 25,
    cerdo = as_num(x$gp_totanio_mas2m) * 1.97 * 120
  ), na.rm = TRUE)
}, "gp")

gvnac_agg <- animal_aggregate(raw$gvnac2022, "gvnac2022", function(x) {
  rowSums(data.frame(
    tierno = as_num(x$gv_k1002) * 6.78 * 25,
    adulto = as_num(x$gv_k1003) * 6.78 * 40
  ), na.rm = TRUE)
}, "gv")

oenac_agg <- animal_aggregate(raw$oenac2022, "oenac2022", function(x) {
  rowSums(data.frame(
    asno = as_num(x$oe_k1101) * 1.11 * 450,
    caballo = as_num(x$oe_k1102) * 4.41 * 500,
    mular = as_num(x$oe_k1103) * 7.77 * 500,
    cabra = as_num(x$oe_k1104) * 6.78 * 60
  ), na.rm = TRUE)
}, "oe")

eunac <- as.data.frame(raw$eunac2022)
eunac$Identificador <- as_id(eunac$Identificador)
eunac_agg <- data.table::as.data.table(eunac)[, .(
  eu_k1301 = sum(as_num(eu_k1301), na.rm = TRUE),
  eu_rows = .N
), by = Identificador]
eunac_agg <- record_module("eunac2022", eunac, as.data.frame(eunac_agg), "UPA agregada")

insumos_modulos <- Reduce(function(x, y) merge(x, y, by = "Identificador", all = TRUE), list(
  aggregate_inputs(raw$cpnac2022, "cp", "cp"),
  aggregate_inputs(raw$ctnac2022, "ct", "ct"),
  aggregate_inputs(raw$fpnac2022, "fp", "fp"),
  aggregate_inputs(raw$ftnac2022, "ft", "ft"),
  aggregate_inputs(raw$pcnac2022, "cp", "pc")
))

superficie_objetivo <- sunac[, .(
  superficie_objetivo_positiva = any(
    as_num(us_k301ha) > 0 |
      as_num(us_k302ha) > 0 |
      as_num(us_k305ha) > 0,
    na.rm = TRUE
  )
), by = Identificador]

insumos <- merge(
  superficie_objetivo,
  insumos_modulos,
  by = "Identificador",
  all.x = TRUE
)
registro_cols <- grep("_tiene_registro$", names(insumos), value = TRUE)
insumos <- as.data.frame(insumos)
insumos$tiene_modulo_cultivo <- rowSums(
  insumos[, registro_cols, drop = FALSE] == TRUE,
  na.rm = TRUE
) > 0
insumos <- record_module("insumos_agricolas", insumos, insumos, "UPA agregada")

modules <- list(
  base_master = as.data.frame(base_master),
  sunac = as.data.frame(sunac_agg),
  adnac = as.data.frame(adnac_agg),
  cpnac = as.data.frame(cpnac_agg),
  ctnac = as.data.frame(ctnac_agg),
  fpnac = as.data.frame(fpnac_agg),
  ftnac = as.data.frame(ftnac_agg),
  pcnac = as.data.frame(pcnac_agg),
  acnac = as.data.frame(acnac_agg),
  apnac = as.data.frame(apnac_agg),
  glnac = as.data.frame(glnac_agg),
  gpnac = as.data.frame(gpnac_agg),
  gvnac = as.data.frame(gvnac_agg),
  oenac = as.data.frame(oenac_agg),
  eunac = as.data.frame(eunac_agg),
  insumos = as.data.frame(insumos)
)

write_report(do.call(rbind, module_report), "04_module_grain_report.csv")
write_report(do.call(rbind, module_report), "module_aggregate_manifest.csv")
write_report(do.call(rbind, price_audit), "05_price_match_report.csv")
write_report(price_info$audit, "price_input_audit.csv")
if (length(price_imputation_detail) > 0) {
  write_report(do.call(rbind, price_imputation_detail), "price_imputation_detail.csv")
} else {
  write_report(data.frame(
    module = character(),
    variable = character(),
    Identificador = character(),
    product_var = character(),
    product = character(),
    quantity_used = numeric(),
    imputed_price_usd_kg = numeric(),
    imputation_reason = character(),
    imputed_economic_value = numeric()
  ), "price_imputation_detail.csv")
}
saveRDS(modules, file.path(intermediate_dir, "module_aggregates.rds"))
