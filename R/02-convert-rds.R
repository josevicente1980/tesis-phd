# ============================================================
# CONVERSIÓN DE ARCHIVOS SPSS (.sav) A FORMATO RDS (.rds)
# Tesis doctoral - José Vicente Ordóñez Yaguache
# ============================================================

library(haven)

source(file.path("R", "paths.R"))

# Definir directorios
dir_raw <- path_raw()

# Buscar todos los archivos .sav
archivos_sav <- list.files(
  path = dir_raw,
  pattern = "\\.sav$",
  full.names = TRUE
)

if (length(archivos_sav) == 0) {
  cat("No se encontraron archivos .sav en:", dir_raw, "\n")
} else {
  cat("Se encontraron", length(archivos_sav), "archivos .sav para convertir.\n\n")
  
  for (sav_path in archivos_sav) {
    base_name <- tools::file_path_sans_ext(basename(sav_path))
    rds_path <- file.path(dir_raw, paste0(base_name, ".rds"))
    
    # Si el archivo .rds ya existe, podemos omitir o sobreescribir.
    # Por seguridad, los sobreescribiremos para asegurar consistencia.
    cat("Procesando:", basename(sav_path), "->", basename(rds_path), "...\n")
    
    # Medir tiempo de lectura
    t_start <- Sys.time()
    
    datos <- tryCatch({
      haven::read_sav(sav_path)
    }, error = function(e) {
      cat("  Error al leer", basename(sav_path), ":", e$message, "\n")
      NULL
    })
    
    if (!is.null(datos)) {
      # Guardar como RDS
      tryCatch({
        saveRDS(datos, file = rds_path)
        t_end <- Sys.time()
        duracion <- round(as.numeric(difftime(t_end, t_start, units = "secs")), 1)
        cat("  Convertido exitosamente en", duracion, "segundos.\n")
      }, error = function(e) {
        cat("  Error al guardar", basename(rds_path), ":", e$message, "\n")
      })
    }
  }
  cat("\n¡Conversión completada!\n")
}
