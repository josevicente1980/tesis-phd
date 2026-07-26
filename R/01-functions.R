# ============================================================
# FUNCIONES GLOBALES PARA TABLAS Y FIGURAS
# Tesis doctoral - José Vicente Ordóñez Yaguache
# Estilo USC / EDIUS
# ============================================================

tabla_usc <- function(
    data,
    align = NULL,
    digits = 2,
    font_size = 8,
    position = "center",
    scale_down = TRUE,
    hold_position = TRUE
) {
  
  font_size <- 8
  opciones_latex <- character(0)

  if (hold_position) {
    opciones_latex <- c(
      opciones_latex,
      "hold_position"
    )
  }
  
  if (scale_down) {
    opciones_latex <- c(
      opciones_latex,
      "scale_down"
    )
  }
  
  knitr::kable(
    data,
    format = "latex",
    booktabs = TRUE,
    longtable = FALSE,
    digits = digits,
    align = align,
    escape = TRUE,
    format.args = list(
      big.mark = ".",
      decimal.mark = ","
    )
  ) |>
    kableExtra::kable_styling(
      latex_options = opciones_latex,
      font_size = font_size,
      full_width = FALSE,
      position = position
    ) |>
    kableExtra::row_spec(
      row = 0,
      bold = TRUE
    ) |>
    kableExtra::column_spec(
      column = seq_len(ncol(data)),
      latex_valign = "m"
    )
}


nota_tabla <- function(
    tabla,
    nota = NULL,
    fuente = "Elaboración propia."
) {
  
  # ----------------------------------------------------------
  # CAMBIO 1:
  # Se verifica si realmente existe una nota.
  # Si nota = NULL, "", NA o un vector vacío, no se imprimirá
  # la palabra "Nota:".
  # ----------------------------------------------------------
  
  tiene_nota <- !is.null(nota) &&
    length(nota) > 0 &&
    !all(is.na(nota)) &&
    trimws(
      paste(
        nota,
        collapse = " "
      )
    ) != ""
  
  # ----------------------------------------------------------
  # CAMBIO 2:
  # Cuando sí existe nota, se construyen dos elementos:
  #   1) el texto de la nota
  #   2) la fuente
  #
  # Al usar un vector con dos elementos y footnote_as_chunk = FALSE,
  # kableExtra coloca la fuente en una línea nueva.
  #
  # Cuando no existe nota, se imprime únicamente la fuente.
  # ----------------------------------------------------------
  
  texto <- if (tiene_nota) {
    c(
      paste(
        nota,
        collapse = " "
      ),
      paste0(
        "Fuente: ",
        fuente
      )
    )
  } else {
    paste0(
      "Fuente: ",
      fuente
    )
  }
  
  # ----------------------------------------------------------
  # CAMBIO 3:
  # Si hay nota, se imprime el título "Nota:".
  # Si no hay nota, el título queda vacío y solo aparece la fuente.
  # ----------------------------------------------------------
  
  titulo <- if (tiene_nota) {
    "Nota: "
  } else {
    ""
  }
  
  tabla |>
    kableExtra::footnote(
      general_title = titulo,
      general = texto,
      footnote_as_chunk = FALSE,
      threeparttable = TRUE,
      escape = TRUE
    )
}


guardar_figura <- function(
    plot,
    filename,
    width = 7,
    height = 5,
    dpi = 300
) {
  
  figures_dir <- path_outputs("figures")
  
  if (!dir.exists(figures_dir)) {
    dir.create(
      figures_dir,
      recursive = TRUE
    )
  }
  
  ggplot2::ggsave(
    filename = path_outputs("figures", filename),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
}


# ============================================================
# CONSTANTES Y FUNCIONES CENTRALIZADAS DE MODELAMIENTO
# ============================================================

NOTA_SIGNIFICANCIA <- "*** p < 0,001; ** p < 0,01; * p < 0,05; . p < 0,10."

formatear_pvalor <- function(p) {
  dplyr::case_when(
    is.na(p) ~ "",
    p < 0.001 ~ "<0,001",
    TRUE ~ formato_num(p, digits = 3)
  )
}

estrellas_significancia <- function(p) {
  dplyr::case_when(
    is.na(p) ~ "",
    p < 0.001 ~ "***",
    p < 0.01 ~ "**",
    p < 0.05 ~ "*",
    p < 0.10 ~ ".",
    TRUE ~ ""
  )
}

z_score <- function(x) {
  x <- as.numeric(x)
  media <- mean(
    x,
    na.rm = TRUE
  )
  desviacion <- stats::sd(
    x,
    na.rm = TRUE
  )
  dplyr::case_when(
    is.finite(x) &
      is.finite(desviacion) &
      desviacion > 0 ~
      (x - media) / desviacion,
    TRUE ~ NA_real_
  )
}

to_si_no <- function(x) {
  xs <- stringr::str_to_upper(
    stringr::str_trim(
      as.character(x)
    )
  )
  dplyr::case_when(
    xs %in% c("SI", "SÍ") ~ "SI",
    xs == "NO" ~ "NO",
    TRUE ~ NA_character_
  )
}

normalizar_texto <- function(x) {
  x |>
    stringr::str_to_upper() |>
    stringi::stri_trans_general(
      "Latin-ASCII"
    ) |>
    stringr::str_squish()
}

crear_fondo_vecinos <- function(
    mapa_base,
    margen = 200000
) {
  vecinos <- rnaturalearth::ne_countries(
    scale = "small",
    returnclass = "sf"
  ) |>
    dplyr::filter(
      admin %in% c(
        "Colombia",
        "Peru",
        "Ecuador"
      )
    ) |>
    sf::st_transform(
      sf::st_crs(mapa_base)
    ) |>
    sf::st_make_valid()

  caja <- sf::st_bbox(
    mapa_base
  )

  caja_expandida <- caja
  caja_expandida["xmin"] <- caja["xmin"] - margen
  caja_expandida["ymin"] <- caja["ymin"] - margen
  caja_expandida["xmax"] <- caja["xmax"] + margen
  caja_expandida["ymax"] <- caja["ymax"] + margen

  sf::st_crop(
    vecinos,
    caja_expandida
  )
}
