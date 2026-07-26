# Informe de auditoría de consistencia interna de la tesis

**Fecha:** 24 de julio de 2026  
**Alcance:** preámbulo, ocho capítulos, dos anexos, tablas, figuras, referencias cruzadas y artefactos internos empleados como fuente de verificación.  
**Restricción aplicada:** no se modificaron metodología, modelos econométricos, scripts de R, datos, resultados estadísticos, bibliografía ni diseño gráfico.

## Fuentes internas utilizadas para dirimir cifras

La versión oficial vigente de la base se determinó mediante la evidencia interna más reciente y reproducible:

- `R/pipeline_reproducible/00_config.R` declara `base_final_v1.1.csv` como archivo oficial.
- `outputs/pipeline_espac/reports/10_pipeline_execution_trace.csv`, fechado el 13 de julio de 2026, registra la ejecución completa de los scripts `02_import_validate.R` a `06_certify.R`.
- `outputs/pipeline_espac/reports/07_final_base_validation.csv` certifica 42.444 filas, 42.444 identificadores únicos y 93 columnas.
- `data/processed/base_final_v1.1.csv` y `outputs/pipeline_espac/processed/base_final_v1.1.csv` tienen el mismo hash SHA-256: `B55DEC690C72CCEB7EE8488478D27B47EAD47590111714C8922BB8A2FA6086DC`.
- La compilación completa del 24 de julio de 2026 confirmó las muestras de 22.075 UPA para OLS/multinivel y 21.430 UPA para SFA, así como los coeficientes, ICC, parámetros SFA y eficiencias citados en el resumen, el abstract, el Capítulo VII y el Capítulo VIII.

## Inconsistencias encontradas y corregidas

### 1. Referencias a anexos no funcionales

- **Ubicación:** `capitulos/CapituloV.qmd`.
- **Evidencia:** el texto utilizaba `Anexo [1]` y `Anexo [2]`, que no eran referencias cruzadas válidas y no estaban vinculadas a identificadores.
- **Corrección:** se añadieron identificadores a los encabezados de ambos anexos y se sustituyeron las menciones por enlaces internos a `Anexo I` y `Anexo II`.
- **Impacto:** las referencias ahora apuntan a los anexos correctos sin depender de numeración manual ambigua.

### 2. Primer cuartil de eficiencia técnica de la tierra

- **Ubicación:** `capitulos/CapituloVII.qmd`, texto que interpreta la tabla de distribución de eficiencia SFA.
- **Evidencia:** el texto indicaba `0,296`; la tabla generada por `frontier::efficiencies()` y redondeada a tres decimales muestra `0,295`.
- **Corrección:** `0,296` se sustituyó por `0,295`.
- **Fuente dirimente:** tabla `tbl-eficiencia-sfa-cap7` producida durante la compilación.

### 3. Dirección de las asociaciones de tenencia en las conclusiones

- **Ubicación:** `capitulos/CapituloVIII.qmd`.
- **Evidencia:** la conclusión afirmaba que la dirección y la magnitud de las asociaciones de tenencia diferían entre productividad de la tierra y del trabajo. Las seis especificaciones del Capítulo VII muestran la misma dirección: propiedad y tenencias especiales presentan coeficientes negativos frente a arrendamiento/aparcería; lo que cambia es la magnitud.
- **Corrección:** la conclusión se ajustó para indicar coincidencia de dirección y diferencia de magnitudes, manteniendo explícitamente la interpretación no causal.
- **Fuente dirimente:** tablas OLS, multinivel y SFA del Capítulo VII y su síntesis comparativa.

### 4. Denominación del objeto empírico en el Capítulo VII

- **Ubicación:** título, objetivo y definiciones del Capítulo VII.
- **Evidencia:** varias menciones denominaban el resultado como “productividad agrícola”, mientras el objetivo general, la metodología, las variables dependientes y las conclusiones definen y estiman productividad **agropecuaria**, construida con componentes agrícolas y pecuarios.
- **Corrección:** se normalizó a “productividad agropecuaria” en los pasajes que describen el objeto empírico del capítulo. No se alteraron usos del término “productividad agrícola” referidos a la literatura.

### 5. Convención numérica del abstract

- **Ubicación:** `preambulo/abstract.qmd`.
- **Evidencia:** el texto en inglés conservaba separadores españoles (`22.075`, `-0,173`, `15,0 %`), aunque los valores coincidían con el resumen y los resultados.
- **Corrección:** se aplicó la convención inglesa (`22,075`, `-0.173`, `15.0%`, etc.) sin cambiar ninguna cifra.

## Comprobaciones sin inconsistencias demostradas

- La base oficial vigente contiene 42.444 UPA únicas.
- OLS y multinivel emplean una muestra común de 22.075 UPA.
- SFA emplea 21.430 UPA; la diferencia respecto de 22.075 es 645.
- Los coeficientes SFA de tenencia repetidos en resumen, abstract y Capítulo VII coinciden: propiedad `-0,173` y `-0,286`; tenencias especiales `-0,399` y `-0,699`.
- Los ICC nulos coinciden: `15,0 %` para tierra y `9,2 %` para trabajo.
- Los ICC completos coinciden: `11,8 %` para tierra y `7,2 %` para trabajo.
- Gamma coincide entre tablas, texto, resumen y conclusiones: `0,6572` y `0,5114` (`65,7 %` y `51,1 %`).
- Las eficiencias medias coinciden: `0,406` y `0,391` (`40,6 %` y `39,1 %`).
- Las conclusiones conservan el carácter asociativo y no causal establecido en los objetivos, el alcance y la metodología.
- El resumen y el abstract contienen las mismas muestras, métodos, resultados centrales y cautelas inferenciales.
- Las variables centrales mantienen nombres trazables: `produccion_ec`, `productividad_superficie`, `productividad_trabajo`, `clase.mayoria` e `Identificador`.
- La compilación ejecutó 180 bloques, incluidas todas las tablas y figuras de los capítulos II, III, VI y VII.
- No se detectaron referencias `@tbl-*` o `@fig-*` sin destino ni etiquetas de tabla o figura duplicadas.

## Inconsistencias pendientes que requieren decisión del investigador

### 1. El Capítulo VI usa una base histórica

- **Ubicación:** `capitulos/CapituloVI.qmd`, carga de datos.
- **Evidencia:** el capítulo utiliza `data/processed/15_Base_final_diciembre.csv`; la configuración oficial vigente, el Capítulo V, el Capítulo VII, el Anexo II y el pipeline certificado utilizan `base_final_v1.1.csv`.
- **Por qué no se corrigió:** cambiar la ruta puede modificar tablas, figuras, porcentajes y resultados descriptivos del Capítulo VI. Esto excede una corrección documental y entra en las prohibiciones expresas de no modificar datos ni resultados.
- **Decisión requerida:** autorizar una regeneración y recertificación completa del Capítulo VI con `base_final_v1.1.csv`, seguida de una nueva auditoría de todas sus afirmaciones numéricas.

### 2. Políticas y manifiestos internos obsoletos

- **Ubicación:** `agent/memory/thesis_consistency_policy.md`, `agent/memory/pipeline_policy.md`, `agent/memory/doctoral_review_policy.md` y `outputs/pipeline_espac/reports/10_publication_manifest.csv`.
- **Evidencia:** estos archivos todavía designan `base_final_v1.0.csv` o `15_Base_final_diciembre.csv` como base oficial. Son anteriores o contradictorios respecto de la configuración y certificación del 13 de julio de 2026.
- **Por qué no se corrigió:** no forman parte del manuscrito y algunos son registros históricos de ejecución; reescribirlos podría borrar trazabilidad.
- **Decisión requerida:** definir si deben archivarse explícitamente como históricos o actualizarse mediante un nuevo procedimiento de publicación del pipeline.

### 3. Comparabilidad de las descripciones entre capítulos

- **Ubicación:** principalmente capítulos II, III y VI.
- **Evidencia:** conviven tabulados expandidos construidos desde módulos oficiales, tabulados muestrales de 42.444 UPA y descripciones calculadas con la base histórica del Capítulo VI.
- **Por qué no se corrigió:** las diferencias de universo están generalmente declaradas y no constituyen por sí mismas una contradicción; sin embargo, no puede certificarse una plena identidad transversal mientras el Capítulo VI no use la base oficial vigente.
- **Decisión requerida:** resolver primero la base del Capítulo VI y después recertificar sus cuadros descriptivos frente a los capítulos II y III.

## Verificación de compilación

- **Comando:** `C:\Program Files\RStudio\resources\app\bin\quarto\bin\quarto.exe render index.qmd`
- **Resultado diagnóstico previo a las correcciones:** exitoso.
- **Resultado final posterior a las correcciones:** exitoso; 180 bloques ejecutados, tres pasadas de XeLaTeX completadas y PDF regenerado.
- **Salida:** `_book/index.pdf`.
- **Observación de entorno:** `quarto` no está disponible directamente en `PATH`; se utilizó la instalación incluida con RStudio.
