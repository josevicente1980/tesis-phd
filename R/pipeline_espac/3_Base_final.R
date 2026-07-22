library(dplyr)
library(stringr)
source(file.path("R", "paths.R"))
dir.create(path_pipeline_intermediate(), recursive = TRUE, showWarnings = FALSE)

#--------------------------------------------------
# 0) Limpieza de nombres (quita espacios raros)
#--------------------------------------------------
clean_names <- function(df){
  names(df) <- names(df) %>%
    str_replace_all("\\s+", "") %>%
    str_trim()
  df
}

#--------------------------------------------------
# 1) Asegurar que el ID exista como "Identificador"
#--------------------------------------------------
ensure_id <- function(df){
  df <- clean_names(df)
  id_pos <- which(tolower(names(df)) == "identificador")
  if (length(id_pos) == 0) stop("No se encontró la columna Identificador.")
  names(df)[id_pos[1]] <- "Identificador"
  df
}

#--------------------------------------------------
# 2) SI/NO -> TRUE/FALSE
#--------------------------------------------------
to_yes <- function(x){
  xs <- str_to_upper(str_trim(as.character(x)))
  case_when(
    xs == "SI" ~ TRUE,
    xs == "NO" ~ FALSE,
    TRUE ~ NA
  )
}

#--------------------------------------------------
# 3) Colapsar riego/fert/plag por Identificador
#--------------------------------------------------
collapse_inputs <- function(df, var_prefix, out_prefix = var_prefix){
  
  df <- ensure_id(df)
  
  v_riego <- paste0(var_prefix, "_riego")
  v_fert  <- paste0(var_prefix, "_aferti")
  v_plag  <- paste0(var_prefix, "_afito")
  
  df %>%
    select(Identificador, any_of(c(v_riego, v_fert, v_plag))) %>%
    mutate(across(-Identificador, to_yes)) %>%
    group_by(Identificador) %>%
    summarise(
      !!paste0(out_prefix, "_usa_riego") :=
        any(.data[[v_riego]] %in% TRUE, na.rm = TRUE),
      !!paste0(out_prefix, "_usa_fertiliz") :=
        any(.data[[v_fert]] %in% TRUE, na.rm = TRUE),
      !!paste0(out_prefix, "_usa_plaguicidas") :=
        any(.data[[v_plag]] %in% TRUE, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(across(-Identificador, ~ if_else(.x, "SI", "NO")))
}

#--------------------------------------------------
# 4) Insumos (pcnac2022 trae cp_...)
#--------------------------------------------------
ins_cp <- collapse_inputs(cpnac2022, "cp", "cp")
ins_ct <- collapse_inputs(ctnac2022, "ct", "ct")
ins_fp <- collapse_inputs(fpnac2022, "fp", "fp")
ins_ft <- collapse_inputs(ftnac2022, "ft", "ft")
ins_pc <- collapse_inputs(pcnac2022, "cp", "pc")

#--------------------------------------------------
# 5) Base final: TODO lo original + globales SIN NA
#--------------------------------------------------
Base_final_diciembre <- ensure_id(Base_final_noviembre_25) %>%
  left_join(ins_cp, by = "Identificador") %>%
  left_join(ins_ct, by = "Identificador") %>%
  left_join(ins_fp, by = "Identificador") %>%
  left_join(ins_ft, by = "Identificador") %>%
  left_join(ins_pc, by = "Identificador") %>%
  mutate(
    # 🔹 ÚNICA MODIFICACIÓN SOLICITADA
    productividad_trabajo = if_else(
      is.na(productividad_trabajo),
      0,
      productividad_trabajo
    ),
    
    usa_riego_global = coalesce(
      if_else(if_any(ends_with("_usa_riego"), ~ .x == "SI"), "SI", "NO"),
      "NO"
    ),
    usa_fert_global = coalesce(
      if_else(if_any(ends_with("_usa_fertiliz"), ~ .x == "SI"), "SI", "NO"),
      "NO"
    ),
    usa_plag_global = coalesce(
      if_else(if_any(ends_with("_usa_plaguicidas"), ~ .x == "SI"), "SI", "NO"),
      "NO"
    )
  ) %>%
  # Eliminamos columnas parciales y dejamos lo original + globales
  select(
    -matches("^(cp|ct|fp|ft|pc)_usa_")
  )

write.csv(
  Base_final_diciembre,
  path_pipeline_intermediate("15_Base_final_diciembre.csv"), 
  row.names = FALSE
)
