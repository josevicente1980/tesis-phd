# Base de conocimiento de revisores

Fecha de consolidacion: 2026-07-05

## Fuente de verdad

Esta base de conocimiento deriva exclusivamente de la auditoria ya realizada:

- `agent/reports/reviewer_comments_audit.md`
- `agent/reports/reviewer_comments_tracking_matrix.csv`
- `agent/reports/reviewer_ocr_pages/`
- `agent/reports/reviewer_ocr_page_inventory.csv`
- `agent/reports/reviewer_ocr_comment_hits.csv`
- `agent/reports/reviewer_visual_pages/`
- `agent/reports/reviewer_visual_contact_sheets/`
- `agent/reports/reviewer_visual_purple_scan.csv`
- `agent/reports/reviewer_visual_red_scan.csv`

No se repitio OCR, no se reescanearon visualmente los PDF y no se modificaron capitulos ni scripts.

## Cobertura de extraccion original

La auditoria original reviso 185 paginas:

| Documento | Paginas | Metodo |
|---|---:|---|
| `Cronologia_ultimas revisiones.pdf` | 2 | Texto extraido, OCR y revision visual |
| `Segundo.pdf` | 158 | Texto extraido, OCR y revision visual |
| `Tercero.pdf` | 25 | Texto extraido, OCR y revision visual |

Regla de mantenimiento: no repetir OCR ni escaneo visual salvo que se agreguen nuevos documentos a `docs/revisiones/` o se reemplacen los PDF existentes por versiones distintas.

## Resumen ejecutivo

| Estado | Observaciones |
|---|---:|
| pendiente | 22 |
| parcialmente resuelto | 1 |
| resuelto | 2 |
| total | 25 |

El Capitulo VII concentra la mayor prioridad: contiene 8 observaciones de prioridad `Muy alta`, ademas de una observacion parcialmente resuelta que mantiene bloqueada la certificacion del capitulo.

## Regla de uso

Antes de revisar o certificar un capitulo:

1. Consultar `reviewers_matrix.csv`.
2. Filtrar por `capitulo_afectado`.
3. Resolver o justificar cada observacion pendiente.
4. Actualizar el estado solo con evidencia explicita.
5. Separar siempre observaciones de revisores de recomendaciones editoriales adicionales.

No se puede certificar un capitulo si conserva al menos una observacion con estado `pendiente` o `parcialmente resuelto`.

## Observaciones por capitulo

### Capitulo I

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-001 | Alta | resuelto | Introduccion |

### Capitulos II-IV

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-002 | Alta | pendiente | General |

### Capitulo V

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-003 | Alta | pendiente | General |

### Capitulo VI

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-004 | Alta | pendiente | General |
| REV-011 | Alta | pendiente | 6.2.3 Uso del suelo / Figura 6.2 |
| REV-012 | Media | pendiente | Distribucion regional de cultivos |

### Capitulos II-VI

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-007 | Alta | pendiente | General |

### Capitulo VII

| ID | Prioridad | Estado | Seccion |
|---|---|---|---|
| REV-006 | Muy alta | pendiente | Analisis e interpretacion de resultados |
| REV-008 | Muy alta | pendiente | 7.5.2 Productividad del trabajo |
| REV-009 | Muy alta | resuelto | Productividad negativa |
| REV-010 | Muy alta | pendiente | 7.5.3 Evaluacion del ajuste de modelos lineales |
| REV-017 | Muy alta | pendiente | 7.5.1 Productividad de la tierra |
| REV-019 | Muy alta | pendiente | 7.5.2 Productividad del trabajo |
| REV-020 | Muy alta | pendiente | 7.5.3 Evaluacion del ajuste |
| REV-023 | Muy alta | pendiente | 7.7 Frontera estocastica |
| REV-024 | Muy alta | pendiente | 7.7 Resultados SFA |
| REV-005 | Alta | parcialmente resuelto | General |
| REV-015 | Alta | pendiente | 7.3 Construccion de la base analitica |
| REV-018 | Alta | pendiente | 7.5.1 cierre |
| REV-021 | Alta | pendiente | 7.6 Modelos multinivel |
| REV-013 | Media | pendiente | 7.1 Introduccion |
| REV-014 | Media | pendiente | 7.2 Fundamentos conceptuales |
| REV-016 | Media | pendiente | Figura 7.1 |
| REV-025 | Media | pendiente | 7.7 Parametros de varianza SFA |
| REV-022 | Baja | pendiente | 7.7 Frontera estocastica |

## Prioridades criticas

Las observaciones de prioridad `Muy alta` se concentran en:

- Interpretacion de resultados econometricos del Capitulo VII.
- Uso incorrecto de AIC/BIC para comparar modelos con variables dependientes distintas.
- Productividad del trabajo y notas/propuestas de texto no visibles en 7.5.2.
- Interpretacion de OLS, multinivel y frontera estocastica.
- Delimitacion de la muestra de UPA con productividad positiva.

## Archivos de consulta

- `reviewers_matrix.csv`: matriz canonica de 25 comentarios.
- `reviewers_pending.md`: pendientes y parcialmente resueltos.
- `reviewers_resolved.md`: comentarios resueltos.
- `extraction_log.md`: bitacora de extraccion y regla para no repetir OCR.
