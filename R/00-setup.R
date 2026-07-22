# ============================================================
# CONFIGURACIÓN GENERAL DEL PROYECTO
# Tesis doctoral - José Vicente Ordóñez Yaguache
# ============================================================

if (!exists("project_path", mode = "function")) {
  source(file.path("R", "paths.R"))
}

options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  scipen = 999,
  digits = 4,
  knitr.kable.NA = "",
  OutDec = ","
)

knitr::opts_chunk$set(
  fig.pos = "H",
  out.extra = ""
)

paquetes <- c(
  "tidyverse", "readr", "readxl", "haven", "janitor", "skimr",
  "knitr", "kableExtra", "ggplot2", "scales", "stringr", "stringi",
  "forcats", "broom", "broom.mixed", "modelsummary", "sjlabelled",
  "DBI", "odbc", "survey", "patchwork", "sf", "terra", "tmap",
  "classInt", "rnaturalearth", "frontier", "lme4", "lmerTest",
  "lmtest", "sandwich", "performance"
)

paquetes_faltantes <- paquetes[
  !paquetes %in% rownames(installed.packages())
]

if (length(paquetes_faltantes) > 0) {
  stop(
    paste0(
      "Faltan paquetes por instalar: ",
      paste(paquetes_faltantes, collapse = ", "),
      ". Instálalos una sola vez con install.packages()."
    )
  )
}

invisible(
  suppressPackageStartupMessages(
    lapply(paquetes, library, character.only = TRUE)
  )
)

# ============================================================
# LIMPIEZA PREVENTIVA DE GGTern
# ============================================================

if ("package:ggtern" %in% search()) {
  detach(
    "package:ggtern",
    unload = TRUE,
    character.only = TRUE
  )
}

if ("ggtern" %in% loadedNamespaces()) {
  try(
    unloadNamespace("ggtern"),
    silent = TRUE
  )
}

# ============================================================
# PALETA GRÁFICA GLOBAL DE LA TESIS
# ============================================================

paleta_tesis <- c(
  "#264653", # Azul petróleo oscuro
  "#3A5A6A", # Azul grisáceo
  "#5E7D8A", # Azul medio apagado
  "#89A9B8", # Azul claro
  "#B7D1DC", # Azul muy claro
  "#8C6A5D", # Marrón apagado
  "#A68A73", # Tierra suave
  "#6C757D", # Gris medio
  "#495057", # Gris oscuro
  "#ADB5BD"  # Gris claro
)

# Paleta secuencial en tonos azul claro
paleta_tesis_azul <- c(
  "#F4F8FA",
  "#DCEAF0",
  "#B7D1DC",
  "#78A4B8",
  "#3A5A6A"
)

# Colores principales
color_barra_tesis <- "#5E8799"
color_borde_tesis <- "#343A40"

# Colores para mapas
color_fondo_mapa <- "#F5F7F8"
color_borde_mapa <- "#C9D3D8"
color_na_mapa <- "#E8EDF0"

# ============================================================
# FUNCIONES AUXILIARES GLOBALES
# ============================================================

to_num <- function(x) {
  y <- suppressWarnings(
    as.numeric(
      haven::zap_labels(x)
    )
  )
  
  if (all(is.na(y))) {
    y <- suppressWarnings(
      as.numeric(
        as.character(x)
      )
    )
  }
  
  y
}

lab_val <- function(x) {
  stringr::str_squish(
    as.character(
      sjlabelled::as_label(
        x,
        fallback = as.character(x)
      )
    )
  )
}

w_mean <- function(x, w) {
  x <- to_num(x)
  w <- to_num(w)
  
  ok <- is.finite(x) &
    is.finite(w) &
    w > 0
  
  if (!any(ok)) {
    return(NA_real_)
  }
  
  sum(
    x[ok] * w[ok],
    na.rm = TRUE
  ) /
    sum(
      w[ok],
      na.rm = TRUE
    )
}

formato_num <- function(x, digits = 1) {
  formatC(
    x,
    format = "f",
    digits = digits,
    big.mark = ".",
    decimal.mark = ","
  )
}

formato_pct <- function(x, digits = 1) {
  paste0(
    formatC(
      x,
      format = "f",
      digits = digits,
      big.mark = ".",
      decimal.mark = ","
    ),
    " %"
  )
}

# ============================================================
# TEMA GLOBAL DE FIGURAS
# ============================================================

tema_tesis <- ggplot2::theme_minimal(
  base_family = "serif",
  base_size = 11
) +
  ggplot2::theme(
    text = ggplot2::element_text(
      family = "serif"
    ),
    plot.title = ggplot2::element_text(
      face = "bold",
      hjust = 0.5,
      size = 12
    ),
    plot.subtitle = ggplot2::element_text(
      hjust = 0.5,
      size = 10
    ),
    axis.title = ggplot2::element_text(
      face = "bold"
    ),
    axis.text = ggplot2::element_text(
      size = 9
    ),
    legend.title = ggplot2::element_text(
      face = "bold",
      size = 9
    ),
    legend.text = ggplot2::element_text(
      size = 8
    ),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "vertical",
    legend.key = ggplot2::element_rect(
      fill = "transparent",
      colour = NA
    ),
    panel.background = ggplot2::element_rect(
      fill = "white",
      colour = NA
    ),
    plot.background = ggplot2::element_rect(
      fill = "white",
      colour = NA
    ),
    panel.grid.major = ggplot2::element_line(
      colour = "#D9DEE3",
      linewidth = 0.3
    ),
    panel.grid.minor = ggplot2::element_blank(),
    plot.margin = ggplot2::margin(
      5, 5, 5, 5
    )
  )

tema_tesis_vacio <- ggplot2::theme_void(
  base_family = "serif",
  base_size = 11
) +
  ggplot2::theme(
    text = ggplot2::element_text(family = "serif"),
    plot.title = ggplot2::element_text(
      face = "bold",
      hjust = 0.5,
      size = 12
    ),
    plot.subtitle = ggplot2::element_text(
      hjust = 0.5,
      size = 10
    ),
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box = "vertical",
    legend.title = ggplot2::element_text(face = "bold", size = 9),
    legend.text = ggplot2::element_text(size = 8),
    legend.key = ggplot2::element_rect(fill = "transparent", colour = NA),
    plot.background = ggplot2::element_rect(fill = "white", colour = NA),
    plot.margin = ggplot2::margin(5, 5, 5, 5)
  )

ggplot2::theme_set(
  tema_tesis
)

# ============================================================
# ESCALAS GLOBALES PARA MAPAS Y FIGURAS
# ============================================================

escala_fill_tesis <- function(name = NULL, na.value = color_na_mapa) {
  ggplot2::scale_fill_manual(
    values = paleta_tesis,
    name = name,
    na.value = na.value
  )
}

escala_color_tesis <- function(name = NULL, na.value = color_na_mapa) {
  ggplot2::scale_color_manual(
    values = paleta_tesis,
    name = name,
    na.value = na.value
  )
}

escala_fill_continua_tesis <- function(name = NULL) {
  ggplot2::scale_fill_gradientn(
    colours = paleta_tesis_azul,
    name = name,
    labels = scales::label_number(
      big.mark = ".",
      decimal.mark = ","
    )
  )
}

# ============================================================
# CONFIGURACIÓN ESPACIAL
# ============================================================

sf::sf_use_s2(FALSE)

if ("tmap" %in% loadedNamespaces()) {
  tmap::tmap_mode("plot")
}
