# Chapter Certification Workflow

Fecha de consolidacion: 2026-07-05

Este workflow es permanente y debe aplicarse automaticamente a todos los capitulos de la tesis doctoral.

## Fase 1. Verificacion de la base oficial

- Utilizar exclusivamente `data/processed/base_final_v1.1.csv`.

## Fase 2. Verificacion del pipeline

- Comprobar coherencia con `R/pipeline_reproducible/`.

## Fase 3. Verificacion metodologica

- Metodologia.
- Variables.
- Muestra.
- Modelos.
- Indicadores.
- Resultados.

## Fase 4. Verificacion documental

Consultar obligatoriamente:

- `docs/espac_2022/`
- `agent/knowledge/reviewers/`
- `agent/memory/`

## Fase 5. Verificacion respecto a revisores

- Revisar todas las observaciones.
- Cerrar unicamente aquellas realmente resueltas.
- Nunca asumir que una observacion esta cerrada sin verificar el capitulo.

## Fase 6. Correccion cientifica

Corregir:

- Metodologia.
- Estadistica.
- Econometria.
- Redaccion cientifica.
- Narrativa.
- Discusion.
- Bibliografia.
- Coherencia con capitulos anteriores.

## Fase 7. Correccion editorial

Corregir:

- Quarto.
- LaTeX.
- Tablas.
- Figuras.
- Captions.
- Referencias cruzadas.
- Formato USC.
- Render.

Aplicar la politica:

- `agent/memory/rendering_policy.md`

## Fase 8. Render completo del capitulo

## Fase 9. Auditoria visual del PDF

- Revisar pagina por pagina.
- Corregir inmediatamente cualquier problema detectado.

## Fase 10. Nuevo render

- Repetir las fases 8-10 hasta que:
  - no existan errores de render;
  - no existan errores metodologicos;
  - no existan observaciones criticas abiertas;
  - el capitulo tenga calidad editorial USC;
  - el capitulo tenga nivel cientifico equivalente a un articulo Q1.

## Fase 11. Certificacion

Solo podra certificarse un capitulo cuando:

- todas las observaciones criticas esten cerradas;
- todas las validaciones metodologicas sean satisfactorias;
- el render sea editorialmente correcto;
- el capitulo tenga calidad doctoral USC;
- el investigador autorice la certificacion.

Ningun capitulo podra certificarse mientras exista una observacion critica abierta.
