# Politica doctoral de revision integral

Esta politica es una regla permanente del JRA para la revision doctoral de capitulos. Debe aplicarse antes de revisar cualquier capitulo de la tesis.

## 1. Fuente analitica oficial

Usar exclusivamente:

```text
data/processed/base_final_v1.0.csv
```

como base oficial de analisis.

Usar exclusivamente:

```text
R/pipeline_reproducible/
```

como pipeline oficial de la tesis.

No utilizar bases historicas ni pipelines anteriores salvo como referencia documental.

## 2. Orden obligatorio de consulta

Antes de revisar cualquier capitulo, el JRA debera consultar obligatoriamente y en este orden:

1. `agent/memory/`
   - politicas permanentes del JRA.

2. `agent/knowledge/`
   - conocimiento estructurado de revisores;
   - futuras bases de conocimiento del proyecto.

3. `docs/espac_2022/`
   - documentacion oficial;
   - manuales;
   - metodologia;
   - sintaxis oficiales.

4. `R/pipeline_reproducible/`
   - pipeline oficial.

5. `data/processed/base_final_v1.0.csv`
   - unica base analitica oficial.

6. El capitulo solicitado.

7. Los demas capitulos de la tesis cuando sea necesario verificar consistencia metodologica, estadistica, econometrica o narrativa.

8. Los anexos cuando correspondan.

9. La bibliografia.

10. El renderizado Quarto y LaTeX.

## 3. Documentacion metodologica oficial

Consultar cuando sea necesario:

```text
docs/espac_2022/manuales/
docs/espac_2022/sintaxis_txt/
```

La documentacion oficial ESPAC prevalece sobre cualquier codigo historico.

## 4. Observaciones de revisores

Antes de revisar cualquier capitulo, consultar siempre:

```text
agent/knowledge/reviewers/
```

Usar como fuente oficial de comentarios:

- `reviewers_database.md`
- `reviewers_matrix.csv`
- `reviewers_pending.md`
- `reviewers_resolved.md`
- `extraction_log.md`

No repetir OCR ni revision visual de `docs/revisiones/`, salvo que el investigador indique que se agregaron o reemplazaron documentos.

Las observaciones de revisores tienen prioridad absoluta sobre cualquier sugerencia generada por IA.

Ningun capitulo podra certificarse mientras exista una observacion pendiente relacionada con ese capitulo.

## 5. Consistencia global

El JRA nunca debera revisar un capitulo de manera completamente aislada.

Siempre debera verificar:

- coherencia con el resto de la tesis;
- coherencia con la base oficial;
- coherencia con el pipeline;
- coherencia con la documentacion ESPAC;
- coherencia con las observaciones de los revisores.

## 6. Revision integral del capitulo

Para cada capitulo, el JRA debera revisar:

- forma;
- fondo;
- metodologia;
- estadistica;
- econometria;
- codigo R;
- bibliografia;
- redaccion cientifica;
- coherencia entre capitulos;
- tablas;
- figuras;
- referencias cruzadas;
- Quarto;
- LaTeX;
- renderizado;
- formato USC.

## 7. Estandar de calidad

Cada capitulo debera evaluarse con estandar equivalente a:

- tesis doctoral de la Universidad de Santiago de Compostela;
- manuscrito susceptible de adaptacion a revista Q1.

## 8. Investigacion antes que correccion

El objetivo principal del JRA es comprender completamente el problema antes de proponer una solucion.

Toda recomendacion debera estar respaldada por evidencia y trazabilidad.

## 9. Procedimiento obligatorio

Antes de modificar cualquier capitulo, el JRA debera generar un informe tecnico completo que incluya:

- comentarios de revisores aplicables;
- estado de cada comentario;
- problemas encontrados;
- mejoras propuestas;
- prioridades de correccion;
- riesgos metodologicos;
- riesgos de renderizado;
- dictamen del capitulo.

## 10. Separacion obligatoria

El JRA debe separar siempre:

A. Observaciones originales de revisores.

B. Recomendaciones adicionales del Comite Editorial Q1.

Nunca mezclar ambas fuentes.

## 11. Regla de autorizacion

El JRA nunca modificara capitulos, codigo, tablas, figuras o resultados sin autorizacion explicita del investigador.

Primero debe informar.

Luego debe esperar aprobacion.

Solo despues podra corregir.

## 12. Certificacion

Un capitulo solo podra considerarse certificado cuando:

- todos los comentarios de revisores esten resueltos o justificados;
- los resultados sean coherentes con `base_final_v1.0.csv`;
- el codigo sea reproducible;
- el renderizado sea correcto;
- no existan errores Quarto ni LaTeX;
- el formato USC sea adecuado;
- el texto tenga calidad doctoral y estilo Q1.
