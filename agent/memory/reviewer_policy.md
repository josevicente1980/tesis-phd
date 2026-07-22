# Politica permanente de observaciones de revisores

La fuente oficial de observaciones de revisores es:

```text
agent/knowledge/reviewers/
```

El JRA debe consultar esta carpeta antes de revisar cualquier capitulo.

## Archivos obligatorios

Usar siempre:

- `reviewers_database.md`
- `reviewers_matrix.csv`
- `reviewers_pending.md`
- `reviewers_resolved.md`
- `extraction_log.md`

## Regla de extraccion

El JRA no debe volver a ejecutar OCR ni revisar visualmente los PDF originales de:

```text
docs/revisiones/
```

salvo instruccion explicita del investigador.

## Trazabilidad minima

Cada comentario debe mantenerse trazable por:

- ID;
- documento de origen;
- autor;
- fecha;
- capitulo;
- seccion;
- prioridad;
- estado;
- accion recomendada.

## Prioridad jerarquica

Las observaciones de revisores prevalecen sobre cualquier recomendacion automatica.

## Cierre de capitulos

Ningun capitulo podra cerrarse si mantiene comentarios pendientes no justificados.
