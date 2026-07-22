# Politica del pipeline oficial de datos

## Estado vigente

Desde la publicacion de la version 1.0, el pipeline oficial de construccion de la base analitica de la tesis es:

```text
R/pipeline_reproducible/
```

La base oficial vigente de la tesis doctoral es:

```text
data/processed/base_final_v1.0.csv
```

El pipeline oficial genera la base reproducible en:

```text
outputs/pipeline_espac/processed/base_final_v1.0.csv
```

## Estado historico

El pipeline historico queda congelado como respaldo en:

```text
R/pipeline_espac/
```

No debe modificarse salvo instruccion explicita del investigador.

El nombre:

```text
15_Base_final_diciembre.csv
```

queda documentado unicamente como nombre historico o de compatibilidad. No debe usarse como referencia activa en nuevos analisis.

## Fuentes oficiales

La documentacion oficial ESPAC utilizada para validar decisiones metodologicas se encuentra en:

```text
docs/espac_2022/manuales/
docs/espac_2022/sintaxis_txt/
```

El archivo:

```text
docs/espac_2022/precios/Precio_Junio_25.xlsx
```

no es documentacion oficial ESPAC. Es un insumo metodologico construido por el investigador y se utiliza como fuente oficial de valoracion economica dentro del pipeline de la tesis.

## Jerarquia de autoridad metodologica

El JRA debera respetar siempre la siguiente jerarquia:

1. Documentacion oficial ESPAC: manuales, metodologia y guia de uso.
2. Sintaxis oficial de las bases de datos ESPAC.
3. Reglas metodologicas explicitas del investigador.
4. Archivo de precios del investigador para valoracion economica.
5. Pipeline oficial `R/pipeline_reproducible/`.
6. Base oficial `data/processed/base_final_v1.0.csv`.
7. Capitulos de la tesis.

Si existe conflicto entre el codigo historico y la documentacion oficial ESPAC, prevalece la documentacion oficial ESPAC.

## Reglas permanentes del pipeline oficial

- Una fila final representa una UPA/cuestionario ESPAC.
- La llave primaria es `Identificador` textual de 17 digitos.
- `Identificador` nunca debe convertirse a numerico.
- Todo modulo de detalle debe agregarse por `Identificador` antes de unirse.
- Las uniones muchos-a-muchos estan prohibidas.
- Toda union debe validar cardinalidad antes de incorporarse a la base final.
- Toda imputacion de precio debe quedar trazada por modulo, producto, UPA, cantidad, motivo y valor imputado.
- El pipeline debe generar reportes de trazabilidad y validacion.

## Politica permanente de auditoria

Antes de aceptar cualquier calculo realizado por el pipeline, el JRA debera auditarlo utilizando la documentacion oficial y la trazabilidad generada por el pipeline.

Para cada transformacion importante debera verificar:

- que la variable utilizada corresponda a la sintaxis oficial ESPAC;
- que las unidades de medida sean correctas;
- que las conversiones sean metodologicamente validas;
- que las agregaciones respeten la unidad final de UPA/cuestionario;
- que las recodificaciones esten justificadas;
- que las imputaciones sean trazables;
- que los calculos economicos respeten las reglas metodologicas vigentes;
- que la trazabilidad desde los datos crudos hasta la base final sea completa.

## Procedimiento ante discrepancias

Si el JRA detecta una contradiccion entre el pipeline oficial y la documentacion oficial debera:

1. detener el analisis correctivo;
2. identificar exactamente el script, linea o bloque donde aparece la discrepancia;
3. citar la evidencia de la documentacion oficial;
4. explicar el impacto metodologico sobre la tesis;
5. proponer una solucion tecnicamente fundamentada;
6. solicitar autorizacion explicita del investigador antes de modificar el pipeline.

## Principio de reproducibilidad

La base oficial `base_final_v1.0.csv` debe poder regenerarse ejecutando:

```text
Rscript R/pipeline_reproducible/run_pipeline.R
```

Todo analisis econometrico o capitulo de tesis debe usar `data/processed/base_final_v1.0.csv` salvo que se indique explicitamente que se esta trabajando con un artefacto historico.
