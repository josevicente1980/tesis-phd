# TESIS_PhD

Proyecto Quarto/R portable y reproducible para la tesis doctoral de Jose Vicente Ordonez Yaguache.

## Estructura

- `index.qmd`: documento maestro de la tesis.
- `_quarto.yml`: configuracion Quarto para render PDF.
- `capitulos/`, `preambulo/`, `anexos/`: contenido de la tesis.
- `R/paths.R`: resolvedor central de rutas del proyecto.
- `R/pipeline_reproducible/`: pipeline oficial para reconstruir la base analitica.
- `R/pipeline_espac/`: pipeline historico conservado como respaldo.
- `data/raw/`: datos crudos requeridos por el pipeline.
- `data/processed/`: bases oficiales procesadas.
- `docs/`: documentacion ESPAC, sintaxis, manuales y revisiones.
- `outputs/`: salidas reproducibles del pipeline y figuras.
- `references/`: bibliografia y estilo CSL.
- `styles/`: configuracion LaTeX.
- `agent/`: memoria, politicas y reportes tecnicos del JRA.

## Requisitos verificados

- R 4.6.1.
- Quarto 1.9.38.
- Motor PDF: XeLaTeX.
- Proyecto abierto desde la raiz `TESIS_PhD/` en RStudio, VS Code o terminal.

## Paquetes R

El render de la tesis usa:

`tidyverse`, `readr`, `readxl`, `haven`, `janitor`, `skimr`, `knitr`, `kableExtra`, `ggplot2`, `scales`, `stringr`, `stringi`, `forcats`, `broom`, `broom.mixed`, `modelsummary`, `sjlabelled`, `DBI`, `odbc`, `survey`, `patchwork`, `sf`, `terra`, `tmap`, `classInt`, `rnaturalearth`, `frontier`, `lme4`, `lmerTest`, `lmtest`, `sandwich`, `performance`.

El pipeline oficial requiere:

`data.table`, `dplyr`, `haven`, `readxl`.

## Rutas

Todas las rutas operativas se resuelven desde `R/paths.R`. No se requiere modificar rutas al copiar el proyecto a otro computador, siempre que se abra o ejecute desde la raiz del proyecto.

## Ejecutar el pipeline

Desde la raiz del proyecto:

```bash
Rscript R/pipeline_reproducible/run_pipeline.R
```

Salida principal:

```text
outputs/pipeline_espac/processed/base_final_v1.1.csv
```

La base oficial incluida para la tesis se encuentra en:

```text
data/processed/base_final_v1.1.csv
```

## Renderizar la tesis

Desde la raiz del proyecto:

```bash
quarto render index.qmd
```

Salida:

```text
_book/index.pdf
```

Si R o Quarto no estan en el `PATH`, abrir `tesis.Rproj` desde RStudio y usar el render de Quarto desde la raiz del proyecto.

## Reproducibilidad completa

1. Copiar la carpeta completa `TESIS_PhD/`.
2. Abrir `tesis.Rproj` o la carpeta desde VS Code.
3. Verificar que R, Quarto y los paquetes requeridos esten instalados.
4. Ejecutar `Rscript R/pipeline_reproducible/run_pipeline.R`.
5. Ejecutar `quarto render index.qmd`.
6. Confirmar que se generan `outputs/pipeline_espac/processed/base_final_v1.1.csv` y `_book/index.pdf`.
