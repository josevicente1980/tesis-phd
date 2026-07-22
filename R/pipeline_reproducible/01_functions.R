load_required_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop("Faltan paquetes requeridos: ", paste(missing, collapse = ", "))
  }
  invisible(lapply(packages, library, character.only = TRUE))
}

ensure_dirs <- function(paths) {
  for (path in paths) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
}

as_id <- function(x) {
  trimws(as.character(x))
}

as_num <- function(x) {
  suppressWarnings(as.numeric(haven::zap_labels(x)))
}

as_label <- function(x) {
  trimws(as.character(haven::as_factor(x)))
}

yes_no <- function(x) {
  z <- toupper(trimws(as.character(haven::as_factor(x))))
  dplyr::case_when(
    z == "SI" ~ TRUE,
    z == "NO" ~ FALSE,
    TRUE ~ NA
  )
}

validate_identifier <- function(df, object_name) {
  if (!"Identificador" %in% names(df)) {
    stop(object_name, " no contiene Identificador.")
  }
  df$Identificador <- as_id(df$Identificador)
  invalid <- is.na(df$Identificador) | !grepl("^[0-9]{17}$", df$Identificador)
  data.frame(
    object = object_name,
    rows = nrow(df),
    unique_identifiers = length(unique(df$Identificador)),
    duplicate_rows_by_identifier = nrow(df) - length(unique(df$Identificador)),
    invalid_identifier_count = sum(invalid),
    stringsAsFactors = FALSE
  )
}

stop_if_not_unique <- function(df, object_name, key = "Identificador") {
  duplicated_rows <- nrow(df) - length(unique(df[[key]]))
  if (duplicated_rows > 0) {
    stop(object_name, " no es unico por ", key, ". Duplicados: ", duplicated_rows)
  }
}

join_one_to_one <- function(left, right, right_name, join_report, key = "Identificador") {
  stop_if_not_unique(left, "left", key)
  stop_if_not_unique(right, right_name, key)
  before_rows <- nrow(left)
  result <- dplyr::left_join(left, right, by = key)
  after_rows <- nrow(result)
  if (after_rows != before_rows) {
    stop("Union con ", right_name, " cambio filas: ", before_rows, " -> ", after_rows)
  }
  join_report[[length(join_report) + 1]] <- data.frame(
    left_object = "base_master",
    right_object = right_name,
    key = key,
    join_type = "left_join",
    left_rows = before_rows,
    left_unique = length(unique(left[[key]])),
    right_rows = nrow(right),
    right_unique = length(unique(right[[key]])),
    result_rows = after_rows,
    result_unique = length(unique(result[[key]])),
    expansion = after_rows - before_rows,
    cardinality = "uno a uno",
    stringsAsFactors = FALSE
  )
  attr(result, "join_report") <- join_report
  result
}

safe_sum <- function(x) sum(as_num(x), na.rm = TRUE)

first_non_missing <- function(x) {
  x <- x[!is.na(x) & x != ""]
  if (length(x) == 0) NA else x[1]
}

write_report <- function(x, filename) {
  data.table::fwrite(x, file.path(reports_dir, filename))
}

read_raw_rds <- function(raw_dir) {
  files <- list.files(raw_dir, pattern = "[.]rds$", full.names = TRUE)
  objects <- lapply(files, readRDS)
  names(objects) <- sub("[.]rds$", "", basename(files))
  objects
}

standardize_price_table <- function(path) {
  prices <- readxl::read_excel(path, sheet = "FINAL", range = "A1:b492")
  prices <- as.data.frame(prices)
  prices$Producto <- tolower(trimws(as.character(prices$Producto)))
  prices$Precio_kg <- as_num(prices$Precio_kg)
  audit <- aggregate(
    Precio_kg ~ Producto,
    prices,
    function(x) paste(sort(unique(x)), collapse = "|")
  )
  audit$n_values <- vapply(strsplit(audit$Precio_kg, "[|]", fixed = FALSE), length, integer(1))
  audit$rule <- ifelse(
    audit$n_values > 1,
    "conflicto_resuelto_con_precio_minimo",
    "precio_unico"
  )
  clean <- aggregate(Precio_kg ~ Producto, prices, function(x) {
    x <- x[!is.na(x)]
    if (length(x) == 0) NA_real_ else min(x)
  })
  clean$precio_origen <- "observado"
  list(clean = clean, audit = audit)
}

add_prices <- function(df, price_table, product_var, table_name, audit_list,
                       imputed_price = imputed_price_usd_kg) {
  df$Producto <- tolower(as_label(df[[product_var]]))
  before_rows <- nrow(df)
  out <- dplyr::left_join(df, price_table, by = "Producto")
  if (nrow(out) != before_rows) {
    stop("La union de precios cambio filas en ", table_name)
  }
  missing_price <- is.na(out$Precio_kg)
  out$precio_imputado <- missing_price
  out$precio_origen[missing_price] <- "imputado_provisional"
  out$Precio_kg[missing_price] <- imputed_price
  audit_list[[length(audit_list) + 1]] <- data.frame(
    table = table_name,
    product_var = product_var,
    rows = before_rows,
    unique_products = length(unique(df$Producto)),
    imputed_price_usd_kg = imputed_price,
    imputed_price_products = paste(sort(unique(df$Producto[missing_price])), collapse = "|"),
    imputed_price_rows = sum(missing_price),
    stringsAsFactors = FALSE
  )
  attr(out, "price_audit") <- audit_list
  out
}

aggregate_inputs <- function(df, prefix, out_prefix) {
  df <- as.data.frame(df)
  df$Identificador <- as_id(df$Identificador)
  v_riego <- paste0(prefix, "_riego")
  v_fert <- paste0(prefix, "_aferti")
  v_plag <- paste0(prefix, "_afito")
  vars <- intersect(c(v_riego, v_fert, v_plag), names(df))
  if (length(vars) == 0) {
    return(data.frame(Identificador = unique(df$Identificador)))
  }
  dt <- data.table::as.data.table(df[, c("Identificador", vars), drop = FALSE])
  for (v in vars) dt[, (v) := yes_no(get(v))]
  dt[, c(
    setNames(list(aggregate_logical_response(get(v_riego))), paste0(out_prefix, "_usa_riego")),
    setNames(list(aggregate_logical_response(get(v_fert))), paste0(out_prefix, "_usa_fertiliz")),
    setNames(list(aggregate_logical_response(get(v_plag))), paste0(out_prefix, "_usa_plaguicidas")),
    setNames(list(TRUE), paste0(out_prefix, "_tiene_registro"))
  ), by = Identificador]
}

aggregate_logical_response <- function(x) {
  if (any(x %in% TRUE)) return(TRUE)
  if (any(is.na(x))) return(NA)
  if (length(x) > 0 && all(x %in% FALSE)) return(FALSE)
  NA
}

consolidate_logical_inputs <- function(df, value_columns, presence_columns) {
  values <- as.matrix(df[, value_columns, drop = FALSE])
  presence <- as.matrix(df[, presence_columns, drop = FALSE])
  presence[is.na(presence)] <- FALSE

  has_yes <- rowSums(values == TRUE, na.rm = TRUE) > 0
  has_module <- rowSums(presence == TRUE, na.rm = TRUE) > 0
  has_incomplete_module <- rowSums(presence & is.na(values), na.rm = TRUE) > 0
  all_observed_no <- rowSums(presence & values == FALSE, na.rm = TRUE) == rowSums(presence)

  out <- rep(NA, nrow(df))
  out[has_yes] <- TRUE
  out[!has_yes & has_module & !has_incomplete_module & all_observed_no] <- FALSE
  out
}

classify_global_input <- function(consolidated, has_module, target_surface_positive) {
  dplyr::case_when(
    consolidated %in% TRUE ~ "SI",
    consolidated %in% FALSE ~ "NO",
    !has_module & !target_surface_positive ~ "NO_APLICA",
    TRUE ~ NA_character_
  )
}
