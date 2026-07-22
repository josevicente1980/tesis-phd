## Código para importar los datos de la ESPAC repartidos en diferentes tablas
## Última edición: 14 mayo2025 2024

library(foreign)
library(data.table)
library(R.utils)

source(file.path("R", "paths.R"))

# Inventario de archivos para importar
# Listado archivos:
archivos <- list.files(path_raw(), 
                       pattern = "*.sav",
                       full.names = TRUE)

# Listado de nombres:
nombres  <- list.files(path_raw(), 
                       pattern = "*.sav",
                       full.names = FALSE) |> 
  substr(start = 1, stop = 9)

# Importación de todas las tablas
# Creamos una lista vacía
dat <- list() 
# Importamos recursivamente las tablas como elementos de la lista y los convertimos en objetos de tipo data.table
for(x in 1:length(archivos)){ 
  dat[[x]] <- read.spss(archivos[x], to.data.frame = TRUE) |> as.data.table()
} 
# Asignamos nombres a cada elemento de la lista (tablas)
names(dat) <- nombres 

# Análisis de identificadores de explotación duplicados en cada tabla
dupli <- data.frame()
for (i in 1:length(dat)) { # Para cada elemento de la lista
  temp <- data.frame(tabla = names(dat)[i],
                     registros.duplicados = length(which(duplicated(dat[[i]]$Identificador))) > 1)
  dupli<- rbind(dupli, temp)
  rm(temp)
}
print(dupli)

# Extraemos los elementos de la lista al espacio de trabajo
invisible(list2env(dat ,.GlobalEnv)) 
# Borramos la lista y los otros datos auxiliares
rm(dat, archivos, nombres, x, i) 
