options(scipen = 999)  # Desactiva notación científica en la consola de R
library(tidyverse)
source(file.path("R", "paths.R"))
dir.create(path_pipeline_intermediate(), recursive = TRUE, showWarnings = FALSE)
## Código para reducir las tablas originales a una única fila por explotación
## Última edición: 23 de mayo 2025

## El código está pensado para ser ejecutado en la misma sesión que el archivo "0_importacion.R"
## La necesidad de simplificación afecta a las tablas marcadas con registros
## duplicados (TRUE) en la tabla "dupli"


# Tabla de Usos del suelo (sunac2022) ----------------------------------------

# Pendiente de decidir si se simplifican las categorías de tenencia (su_tenencia)
# Utilizamos por el momento el área en "supertotal". Hay otra variable similar en "su_k202ha", pero los valores tienen menos sentido (?)

# Producimos una tabla temporal que sume los valores de área para cada forma de tenencia y explotación
# La tabla resultante tiene formato "largo": las explotaciones pueden seguir repetidas en filas
# distintas si tienen más de una forma de tenencia
temp_sunac <- sunac2022[ ,                                # No seleccionamos filas
                         .(provincia = unique(ual_prov),  # Establecemos qué columnas mantener o generar
                           area_ha   = sum(supertotal)
                         ),
                         .(Identificador, su_tenencia)]   # Equivalente a "group by" en SQL

# Pasamos a formato "ancho": una única línea por explotación
# Valores en las columnas indican el área total en cada forma de tenencia
agrup_sunac <- dcast(temp_sunac, 
                     Identificador ~ su_tenencia, 
                     value.var = "area_ha",
                     fill = 0)
rm(temp_sunac)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_sunac, 
          path_pipeline_intermediate("1_sunac.csv"),
          row.names = FALSE)

# Otras tablas ----------------------------------------------------------------

## Importación de precios (precisa del paquete readxl)
precios <- readxl::read_excel(path_docs("espac_2022", "precios", "Precio_Junio_25.xlsx"), 
                              sheet = "FINAL", range = "A1:b492") |> 
  data.table() |> 
  subset(select = c("Producto", "Precio_kg"))
# Convertimos el nombre de producto a minúsculas
precios$Producto <- tolower(precios$Producto)


## Tabla de árboles dispersos (adnac) -----------------------------------------
# Conversión a minúsculas
adnac2022$Producto <- tolower(adnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla ADNAC no están en la tabla de precios?
adnac2022$Producto[-which(adnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
adnac_precios <- merge(adnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 
agrup_adnac <- adnac_precios[ ,                           
                              .(valor_ad = sum(ad_prod * 1000 * `Precio_kg`)),
                              .(Identificador)]         

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_adnac, 
          path_pipeline_intermediate("2_adnac.csv"),
          row.names = FALSE)


# ============================================
# Replicar para otras tablas
# ============================================

## Tabla de cultivos permanentes (cpnac) -----------------------------------------
# Conversión a minúsculas
cpnac2022$Producto <- tolower(cpnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla CPNAC no están en la tabla de precios?
cpnac2022$Producto[-which(cpnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
cpnac_precios <- merge(cpnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 
agrup_cpnac <- cpnac_precios[ ,                           
                              .(valor_cp = sum(cp_prod * 1000 * `Precio_kg`)),
                              .(Identificador)]         

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_cpnac, 
          path_pipeline_intermediate("3_cpnac.csv"),
          row.names = FALSE)

## Tabla de cultivos transitorios (ctnac) -----------------------------------------
# Conversión a minúsculas
ctnac2022$Producto <- tolower(ctnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla CTNAC no están en la tabla de precios?
ctnac2022$Producto[-which(ctnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
ctnac_precios <- merge(ctnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 
agrup_ctnac <- ctnac_precios[ ,                           
                              .(valor_ct = sum(ct_prod * 1000 * `Precio_kg`)),
                              .(Identificador)]         

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_ctnac, 
          path_pipeline_intermediate("4_ctnac.csv"),
          row.names = FALSE)
## Tabla de aves de campo (acnac) -----------------------------------------

agrup_acnac <- acnac2022 %>%
  # 1) variables de interés 
  transmute(
    Identificador, # Se multiplica las unidades EXISTENCIA por el precio de la tabla precios y por el peso promedio en Kg (se deja URL)
    gallina  = ac_k1201  * 1.86 * 2.34, #https://repositorio.upse.edu.ec/server/api/core/bitstreams/ae5c91d6-cd9e-492c-b8d3-bd4b9fa7a4b7/content
    pollo    = ac_k1202  * 1.86 * 2.4, #https://www.agrocalidad.gob.ec/wp-content/uploads/2023/02/Manual-de-aplicabilidad-de-Buenas-Pra%CC%81cticas-Avi%CC%81colas.pdf
    pato     = ac_k1203  * 4.85 * 3.8, #https://repositorio.utc.edu.ec/server/api/core/bitstreams/f4e6396b-7aae-47a7-95df-c17850508311/content
    pavo     = ac_k1204  * 5.22 * 15, #https://dspace.utb.edu.ec/server/api/core/bitstreams/0212ba8a-96bd-4f0b-a526-8ce9fe7b978b/content
    huevo    = ac_k1216  * 0.09  
  ) %>%
  # 2) Suma categorías requeridas 
  mutate(
    valor_ac = rowSums(pick(huevo, gallina, pollo, pato), na.rm = TRUE)
  ) %>%
  # 3) Se deja las variables necesarias
  select(Identificador, valor_ac)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_acnac, 
          path_pipeline_intermediate("5_acnac.csv"),
          row.names = FALSE)

## Tabla de aves de plantel (apnac) -----------------------------------------
agrup_apnac <- apnac2022 %>%
  # 1) Variables de interés (producción anual por categoría)
  transmute(
    Identificador,
    ponedoras      = ap_ctponedoras     *1.86 * 2.34,   # Gallos–gallinas ponedoras_total al año  (multiplicar luego por precio/peso si corresponde)
    reproductoras  = ap_ctreproductoras *1.86 * 2.34, # Gallos–gallinas reproductoras_total al año
    pollitos       = ap_ctpollitos      *1.86 * 2.4,    # Pollitos, pollitas, pollas y pollos_total al año
    pavos          = ap_ctpavos         *5.22 * 15,       # Pavos_total al año
    codornices     = ap_ctcodornices    *3.38 * 0.2,  # Codornices_total al año
    huevos         = ap_k1238           *0.09,         # Producción de huevo
    huevos_codor   = ap_prod_hcodor     * 0.1    #https://www.tia.com.ec/huevos-de-codorniz-20-uni-251708000.html?srsltid=AfmBOormoY3gf9VcgxEmRwiJo-4Sr2UtDqvAqVz0I59QpAi5bPEfqYcF
  ) %>%
  # 2) Suma categorías requeridas
  mutate(
    valor_ap = rowSums(
      pick(ponedoras, reproductoras, pollitos, pavos,
           codornices, huevos, huevos_codor),
      na.rm = TRUE
    )
  ) %>%
  # 3) Se dejan las variables necesarias
  select(Identificador, valor_ap)

# 4) Exportamos la tabla resultante
write.csv(
  agrup_apnac,
  path_pipeline_intermediate("6_apnac.csv"),
  row.names = FALSE
)

## Tabla de flores permanentes (fpnac) -----------------------------------------
# Conversión a minúsculas
fpnac2022$Producto <- tolower(fpnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla fpnac no están en la tabla de precios?
fpnac2022$Producto[-which(fpnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
fpnac_precios <- merge(fpnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 
agrup_fpnac <- fpnac_precios[ ,                           
                              .(valor_fp = sum(fp_k709/20 * `Precio_kg`)),
                              .(Identificador)]      #el parámetro de 20 tallos por kilogramo, respaldado por la FAO (2019) y el Ministerio de Agricultura y Ganadería del Ecuador (MAG, 2022)
# quienes señalan que los ramos comerciales suelen agrupar entre veinte y veinticinco tallos por kilogramo        

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_fpnac, 
          path_pipeline_intermediate("7_fpnac.csv"),
          row.names = FALSE)

## Tabla de flores transitorias (ftnac) -----------------------------------------
# Conversión a minúsculas
ftnac2022$Producto <- tolower(ftnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla FPNAC no están en la tabla de precios?
ftnac2022$Producto[-which(ftnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
ftnac_precios <- merge(ftnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 
agrup_ftnac <- ftnac_precios[ ,                           
                              .(valor_ft = sum(ft_k723/20 * `Precio_kg`)),
                              .(Identificador)]   

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_ftnac, 
          path_pipeline_intermediate("8_ftnac.csv"),
          row.names = FALSE)

## Tabla de ganado vacuno (glnac) -----------------------------------------
agrup_glnac <- glnac2022 %>%
  # 1) variables de interés 
  transmute(
    Identificador, # Se multiplica las unidades EXISTENCIA por el precio de la tabla precios y por el peso promedio en Kg (https://gardenguide.decorexpro.com/es/krs/skolko-vesit-byk.html)
    terneros   = gl_k802  * 1.79 * 300, 
    toretes    = gl_k803  * 1.78 * 450, 
    toros      = gl_k804  * 1.78 * 650, 
    terneras   = gl_k805  * 1.55 * 200, 
    vaconas    = gl_k806  * 1.55 * 300,
    vacas      = gl_k807  * 1.45 * 400,
    leche      = litros_ordeñados * 0.43
  ) %>%
  # 2) Suma categorías requeridas 
  mutate(
    valor_gl = rowSums(pick(terneros, toretes, toros, terneras, vaconas, vacas, leche), na.rm = TRUE)
  ) %>%
  # 3) Se deja las variables necesarias
  select(Identificador, valor_gl)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_glnac, 
          path_pipeline_intermediate("9_glnac.csv"),
          row.names = FALSE)

## Tabla de ganado porcino (gpnac) -----------------------------------------
agrup_gpnac <- gpnac2022 %>%
  # 1) variables de interés 
  transmute(
    Identificador, # Se multiplica las unidades EXISTENCIA por el precio de la tabla precios y por el peso promedio en Kg (https://porkcheckoff.org/pork-branding/facts-statistics/life-cycle-of-a-market-pig/?utm_source=chatgpt.com)
    lechon   = gp_totanio_men2m  * 2.39 * 25, #menos de 2 meses  
    cerdo    = gp_totanio_mas2m  * 1.97 * 120 #mas de 2 meses
  ) %>%
  # 2) Suma categorías requeridas 
  mutate(
    valor_gp = rowSums(pick(lechon, cerdo), na.rm = TRUE)
  ) %>%
  # 3) Se deja las variables necesarias
  select(Identificador, valor_gp)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_gpnac, 
          path_pipeline_intermediate("10_gpnac.csv"),
          row.names = FALSE)

## Tabla de ganado ovino (gvnac) -----------------------------------------
agrup_gvnac <- gvnac2022 %>%
  # 1) variables de interés 
  transmute(
    Identificador, # Se multiplica las unidades EXISTENCIA por el precio de la tabla precios y por el peso promedio en Kg (https://revistas.lamolina.edu.pe/index.php/acu/article/download/2226/3094)
    tierno    = gv_k1002  * 6.78 * 25, #menos de 6 meses  
    adulto    = gv_k1003  * 6.78 * 40 #mas de 26 meses
  ) %>%
  # 2) Suma categorías requeridas 
  mutate(
    valor_gv = rowSums(pick(tierno, adulto), na.rm = TRUE)
  ) %>%
  # 3) Se deja las variables necesarias
  select(Identificador, valor_gv)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_gvnac, 
          path_pipeline_intermediate("11_gvnac.csv"),
          row.names = FALSE)

## Tabla de otras especies (oenac) -----------------------------------------
agrup_oenac <- oenac2022 %>%
  # 1) variables de interés 
  transmute(
    Identificador, # Se multiplica las unidades EXISTENCIA por el precio de la tabla precios.
    asno    = oe_k1101  * 1.11 * 450,  #https://datazone.darwinfoundation.org/es/checklist/?species=5209
    caballo = oe_k1102  * 4.41 * 500,  #https://www.researchgate.net/publication/329357072_ESTUDIO_ZOOMETRICO_DE_CABALLOS_CRIOLLOS_PARAMEROS_ECUATORIANOS_EN_LA_PROVINCIA_DE_CHIMBORAZO_ECUADOR
    mular   = oe_k1103  * 7.77 * 500,  #https://repositorio.uss.cl/handle/uss/19822
    cabra   = oe_k1104  * 6.78 * 60    #https://www.researchgate.net/publication/366717962_Determinacion_de_la_curva_de_crecimiento_en_la_cabra_Chusca_Lojana_del_bosque_seco_del_Sur_del_Ecuador
  ) %>%
  # 2) Suma categorías requeridas 
  mutate(
    valor_oe = rowSums(pick(asno, caballo, mular, cabra), na.rm = TRUE)
  ) %>%
  # 3) Se deja las variables necesarias
  select(Identificador, valor_oe)

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_oenac, 
          path_pipeline_intermediate("12_oenac.csv"),
          row.names = FALSE)

## Tabla de árboles dispersos (pcnac) -----------------------------------------
# Conversión a minúsculas
pcnac2022$Producto <- tolower(pcnac2022$rc_clacul)

# Comprobación: ¿qué productos de la tabla ADNAC no están en la tabla de precios?
pcnac2022$Producto[-which(pcnac2022$Producto %in% precios$Producto)] |> unique()

# Unión de las dos tablas
pcnac_precios <- merge(pcnac2022, precios, by = "Producto", all.x = TRUE, sort = FALSE)

# Resumen por explotación 

# La producción de pastos cultivados está en has así que se encontró en el estudio a continuación 
# que depende del tipo de pasto y como se maneje, pero se estableció que en promedio una ha, da 5 toneladas de pasto 
# https://repositorio.iniap.gob.ec/server/api/core/bitstreams/c4e5606b-4e26-489e-812d-3a032da97005/content


agrup_pcnac <- pcnac_precios[ ,                           
                              .(valor_pc = sum(cp_k409ha * 5000 * `Precio_kg`)),
                              .(Identificador)]         

# Exportamos la tabla resultante a un archivo temporal
write.csv(agrup_pcnac, 
          path_pipeline_intermediate("13_pcnac.csv"),
          row.names = FALSE)

# =======================================================================
# Combinar todas las bases para encontrar el valor total de la producción 
# =======================================================================

#### Alternativa para conservar los valores de cada producción por separado
valor_total <- merge(agrup_acnac, agrup_adnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_apnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_cpnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_ctnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_fpnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_ftnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_glnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_gpnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_gvnac, by = "Identificador", all = TRUE) |> 
  merge(agrup_oenac, by = "Identificador", all = TRUE) |> 
  merge(agrup_pcnac, by = "Identificador", all = TRUE)

valor_total$Identificador <- as.numeric(valor_total$Identificador)
setnafill(valor_total, fill = 0)

valor_total$produccion_ec <- apply(valor_total[,-"Identificador"], MARGIN = 1, sum)

