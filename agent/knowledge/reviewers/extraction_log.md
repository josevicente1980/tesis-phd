# Bitacora de extraccion de comentarios de revisores

Fecha de consolidacion: 2026-07-05

## Fuentes revisadas originalmente

| Documento | Paginas |
|---|---:|
| `docs/revisiones/Cronologia_ultimas revisiones.pdf` | 2 |
| `docs/revisiones/Segundo.pdf` | 158 |
| `docs/revisiones/Tercero.pdf` | 25 |
| Total | 185 |

## Metodo aplicado en la auditoria original

La extraccion original combino:

- texto nativo extraido por pagina;
- OCR por pagina;
- revision visual de todas las paginas;
- hojas de contacto;
- escaneo de pixeles morados y rojos;
- inspeccion individual de paginas con marcas;
- contraste contra archivos `.qmd` para clasificar estados.

## Artefactos existentes

- `agent/reports/reviewer_comments_audit.md`
- `agent/reports/reviewer_comments_tracking_matrix.csv`
- `agent/reports/reviewer_ocr_pages/`
- `agent/reports/reviewer_ocr_page_inventory.csv`
- `agent/reports/reviewer_ocr_comment_hits.csv`
- `agent/reports/reviewer_visual_pages/`
- `agent/reports/reviewer_visual_contact_sheets/`
- `agent/reports/reviewer_visual_purple_scan.csv`
- `agent/reports/reviewer_visual_red_scan.csv`

## Decision de no repetir OCR

Para esta consolidacion no se repitio OCR, no se reescanearon visualmente los PDF y no se modificaron capitulos ni scripts. La fuente de verdad fue la auditoria ya realizada.

No debe repetirse OCR salvo que ocurra al menos una de estas condiciones:

- se agreguen nuevos documentos a `docs/revisiones/`;
- se reemplacen los PDF existentes por nuevas versiones;
- se detecte que un artefacto OCR/visual fue eliminado o corrompido;
- el investigador indique que existe un documento comentado adicional no incorporado a la auditoria.

## Limitacion registrada

El OCR original se ejecuto con los idiomas disponibles localmente (`eng` y `osd`). Algunos acentos o simbolos matematicos pueden aparecer degradados en los TXT, pero la matriz se apoyo tambien en texto nativo y revision visual.
