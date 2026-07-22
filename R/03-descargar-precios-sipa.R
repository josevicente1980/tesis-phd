library(here)
library(rvest)
library(xml2)

url_sipa <- paste0(
  "http://sipa.agricultura.gob.ec/index.php/",
  "sipa-estadisticas/estadisticas-economicas"
)

ruta_archivos_excel <- here::here(
  "data", "external", "sipa", "archivos_excel"
)

dir.create(
  ruta_archivos_excel,
  recursive = TRUE,
  showWarnings = FALSE
)

pagina <- rvest::read_html(url_sipa)

enlaces_excel <- pagina |>
  rvest::html_elements("a[href]") |>
  rvest::html_attr("href")

enlaces_excel <- enlaces_excel[
  grepl("\\.xlsx(?:[?#].*)?$", enlaces_excel, ignore.case = TRUE)
]
enlaces_excel <- unique(xml2::url_absolute(enlaces_excel, url_sipa))

descargados <- character()
existentes <- character()
errores <- character()

for (enlace in enlaces_excel) {
  nombre_archivo <- utils::URLdecode(basename(sub("[?#].*$", "", enlace)))
  ruta_destino <- here::here(
    "data", "external", "sipa", "archivos_excel", nombre_archivo
  )

  if (file.exists(ruta_destino)) {
    existentes <- c(existentes, nombre_archivo)
    message("Ya existía: ", nombre_archivo)
    next
  }

  descarga_correcta <- tryCatch(
    {
      codigo <- utils::download.file(
        enlace,
        destfile = ruta_destino,
        mode = "wb",
        quiet = TRUE
      )
      identical(codigo, 0L) &&
        file.exists(ruta_destino) &&
        file.info(ruta_destino)$size > 0
    },
    error = function(e) FALSE,
    warning = function(w) FALSE
  )

  if (isTRUE(descarga_correcta)) {
    descargados <- c(descargados, nombre_archivo)
    message("Descargado: ", nombre_archivo)
  } else {
    errores <- c(errores, nombre_archivo)
    if (file.exists(ruta_destino)) {
      unlink(ruta_destino)
    }
    message("Error al descargar: ", nombre_archivo)
  }
}

message("Descargados: ", length(descargados))
message("Ya existentes: ", length(existentes))
message("Errores: ", length(errores))
