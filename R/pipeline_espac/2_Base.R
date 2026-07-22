##### Configuración básica ######

options(scipen = 999)  # Desactiva notación científica en la consola de R
library(tidyverse)
library(purrr)

###### Guión para analizar formas de tenencia #####

library(data.table)
library(cluster)
library(ggtern)
library(writexl)
source(file.path("R", "paths.R"))
dir.create(path_pipeline_intermediate(), recursive = TRUE, showWarnings = FALSE)
dir.create(path_pipeline_figures(), recursive = TRUE, showWarnings = FALSE)

tenencia <- read.csv(path_pipeline_intermediate("1_sunac.csv"),
                     colClasses = c("factor", rep("numeric", 10))) |>
  data.table()

# Agrupamos formas de tenencia
tenencia2 <- tenencia[ , .(Identificador = Identificador, 
                           dueño         = DUEÑO + HERENCIA + USUFRUCTO + POSECIÓN,
                           arrendamiento = ARRENDATARIO + APARCERÍA.O.AL.PARTIR,
                           especiales    = COMUNERO + INVASIÓN + LITIGIO + OTRO,
                           total = DUEÑO + HERENCIA + USUFRUCTO + POSECIÓN + ARRENDATARIO + APARCERÍA.O.AL.PARTIR + COMUNERO + INVASIÓN + LITIGIO + OTRO)]
#ver en cuanto a resultados si este compendio es definitivo
#Edelmiro: Herencia probar fuera, arrendamiento y aparcería en dos categorías distintas Probar 
#porque hay diferencias lo de los especiales: comunero solo (PENSAR) y (litigio e invasión se agrupan)
#Eduardo: Revisar el factor de expansión ver que de las categorías de tenencia en la muestra e incorporarlo al cálculo 
# Calculamos proporción en cada forma de tenencia
#radiografía detallada (de las explotaciones con respecto al régimen de tenencia)
#luego ver con la productividad (analisis de varianzas para ver las diferencias entre grupos)
tenencia3 <- tenencia2[, .(Identificador = Identificador, 
                           area.total    = total,
                           dueño         = dueño / total,
                           arrendamiento = arrendamiento/ total,
                           especiales    = especiales / total)]

# Guardar archivo en carpeta temporal
ruta_archivo <- path_pipeline_intermediate("tenencia3.xlsx")

# Exportar a Excel
write_xlsx(tenencia3, path = ruta_archivo)

# Alternativa 1: Clasificamos las explotaciones por régimen de tenencia
# Para determinar el número óptimo de grupos (resultados no concluyentes)
pdf(path_outputs("pipeline_espac", "reports", "clara.pdf"), width = 7*1.7, height = 7)
for(n in 2:10) {
  clasif <- clara(tenencia3[, -c(1:2)],
                  k = n,
                  metric = "euclidean",
                  stand = FALSE,
                  samples = 100,
                  sampsize = 300)
  si <- silhouette(clasif, full = FALSE)
  plot(si, col = 1:n)
}
dev.off()

# Probamos con n grupos
clasif <- clara(tenencia3[, -c(1:2)],
                k = 4,
                metric = "euclidean",
                stand = FALSE,
                samples = 100,
                sampsize = 300)
tenencia3$clustering <- factor(clasif$clustering)

# Alternativa 2 - Determinamos la forma de tenencia mayoritaria
tenencia3$clase.mayoria <- yaImpute::whatsMax(tenencia3[,c("dueño", "arrendamiento", "especiales")])[1]

# Pasamos a formato largo
tenencia3.long <- melt(tenencia3, 
                       id.vars = c("Identificador", "clase.mayoria", "clustering"),
                       measure.vars = c("dueño", "arrendamiento", "especiales"))


# Guardar archivo en carpeta temporal
ruta_archivo <- path_pipeline_intermediate("tenencia3_long.xlsx")

# Exportar a Excel
write_xlsx(tenencia3.long, path = ruta_archivo)

# GRÁFICOS
png(path_pipeline_figures("Grafico_tenencia1.png"), width = 17, height = 10, units = "cm", res = 300)
ggplot(tenencia3.long, aes(x = variable, y = value)) + 
  geom_boxplot() + 
  facet_wrap("clase.mayoria") +
  xlab("Régimen de tenencia") +
  ylab("Proporción del área total") +
  theme(axis.text = element_text(size = 6))
dev.off()


png(path_pipeline_figures("Grafico_tenencia2.png"), width = 15, height = 10, units = "cm", res = 300)
ggplot(tenencia3.long, aes(x = variable, y = value)) + 
  geom_boxplot() + 
  facet_wrap("clustering") +
  xlab("Régimen de tenencia") +
  ylab("Proporción del área total")
dev.off()

png(path_pipeline_figures("Grafico_tenencia3.png"), width = 15, height = 10, units = "cm", res = 300)
ggplot(tenencia3, aes(x = clase.mayoria, y = area.total)) + 
  geom_boxplot() + 
  xlab("Régimen de tenencia mayoritario") +
  ylab("Área total (ha)") +
  scale_y_log10()
dev.off()


# Exportamos el gráfico ternario
png(path_pipeline_figures("Grafico_tenencia4.png"), width = 15, height = 10, units = "cm", res = 300)
ggtern(tenencia3, aes(x = dueño, y = arrendamiento, z = especiales, col = clustering)) + 
  geom_point(alpha = .5) +
  theme_rgbw() + 
  labs(x="Dueño",y="Arrendamiento",z="Especiales",title="")
dev.off()

# Resumen de formas de tenencia
table(tenencia3$clase.mayoria) # Número de explotaciones por clase mayoritaria
table(tenencia3$clustering) # Número de explotaciones por clase de la clasificación

tenencia3[, .(sum(area.total)), .(clase.mayoria)]# Número de hectáreas por clase mayoritaria
tenencia3[, .(sum(area.total)), .(clustering)]# Número de hectáreas por clase de la clasificación

# Exportamos los datos
write.csv(tenencia3, path_pipeline_intermediate("1_sunac_reclasificada.csv"), row.names = FALSE)


######### Base preliminar #########

Preliminar <- list(
  valor_total,
  
  cgnac2022 %>% 
    mutate(cg_superficie = as.numeric(cg_superficie)),
  
  eunac2022 %>% 
    select(Identificador, eu_k1301) %>% 
    mutate(eu_k1301 = as.numeric(eu_k1301))
  
) %>%
  reduce(full_join, by = "Identificador") %>% 
  
  # Calcular productividades
  mutate(
    productividad_superficie = produccion_ec / cg_superficie,
    productividad_trabajo    = produccion_ec / eu_k1301
  )

# Exportamos la tabla resultante a un archivo temporal
write.csv(Preliminar, 
          path_pipeline_intermediate("13_Preliminar.csv"),
          row.names = FALSE)


######### UNIR PRELIMINAR CON TENENCIA ##############

Base_parcial <- merge(Preliminar, tenencia3, by = "Identificador", all = TRUE)

sunac2022_SD <- sunac2022 %>% # Sunac sin duplicados
  distinct(Identificador, .keep_all = TRUE)

Base_final_noviembre_25 <- list(
  Base_parcial, 
  
  sunac2022_SD %>% 
    select(Identificador, fact_exp_fin) %>% 
    mutate(fact_exp_fin = as.numeric(fact_exp_fin))
  
) %>%
  reduce(full_join, by = "Identificador")

write.csv(Base_final_noviembre_25,
          path_pipeline_intermediate("14_Base_final_noviembre_25.csv"), 
          row.names = FALSE)


