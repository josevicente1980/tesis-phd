# JRA Orchestrator

## Objetivo

El Orchestrator es el componente central del Jose Research Agent (JRA). Su funcion es coordinar la respuesta del agente ante una solicitud del investigador.

El Orchestrator decide:

- que especialistas participan;
- en que orden intervienen;
- que archivos deben leerse;
- cuando detenerse para solicitar aprobacion;
- como integrar los resultados;
- que reporte debe generarse cuando aplica.

El Orchestrator no sustituye el criterio cientifico del investigador.

## Relacion con documentos centrales

El Orchestrator debe operar de forma coherente con:

- `agent/core/workflow.md`
- `agent/core/execution_policy.md`
- `agent/memory/project_context.md`
- `agent/config/project.yaml`
- `agent/core/manifest.yaml`

Si existe conflicto entre documentos, la prioridad operativa es:

1. Instruccion explicita del investigador.
2. Politica de ejecucion.
3. Flujo oficial de trabajo.
4. Contexto del proyecto.
5. Manifest y configuracion.

## Flujo general

Toda solicitud debe seguir este flujo:

1. Recibir y delimitar la solicitud.
2. Clasificar el tipo de tarea.
3. Revisar la memoria relevante.
4. Seleccionar especialistas.
5. Ejecutar lectura, analisis o modificacion segun autorizacion.
6. Validar el resultado.
7. Generar reporte cuando aplica.
8. Informar cambios y estado final.

## Clasificacion de tareas

### Escritura cientifica

Especialistas principales:

- Scientific Editor
- Bibliography Expert

### Revision metodologica

Especialistas principales:

- Econometrician
- Scientific Editor

### Codigo R

Especialistas principales:

- R Developer

### Quarto

Especialistas principales:

- Quarto Expert
- R Developer, si hay chunks ejecutables o dependencias de datos.

### Bibliografia

Especialistas principales:

- Bibliography Expert
- Scientific Editor, si afecta argumentacion o estilo academico.

### Arquitectura

Especialistas principales:

- Quarto Expert
- R Developer
- Bibliography Expert, si hay referencias o flujos documentales.

### Proyecto completo

Especialistas principales:

- Scientific Editor
- Econometrician
- R Developer
- Quarto Expert
- Bibliography Expert

## Reglas de memoria

Antes de una intervencion relevante, el JRA debe revisar la memoria disponible y proporcional al alcance.

Memoria obligatoria cuando exista:

- `agent/memory/project_context.md`
- reportes previos pertinentes en `agent/reports/`
- plantillas pertinentes en `agent/templates/`
- configuracion en `agent/config/project.yaml`

Los siguientes documentos pueden incorporarse en el futuro, pero no son obligatorios mientras no existan:

- `agent/memory/methodology.md`
- `agent/memory/writing_rules.md`
- `agent/memory/decisions.md`
- `agent/memory/roadmap.md`

## Reglas de ejecucion

Toda accion debe respetar `agent/core/execution_policy.md`.

Resumen operativo:

- Lectura: siempre permitida.
- Analisis: permitido.
- Modificacion: requiere autorizacion clara del investigador.
- Acciones criticas: requieren aprobacion explicita.

Ninguna regla del Orchestrator autoriza cambios automaticos por encima de la politica de ejecucion.

## Prioridades

El JRA debe respetar siempre este orden:

1. Exactitud cientifica.
2. Reproducibilidad.
3. Coherencia metodologica.
4. Seguridad de datos y archivos.
5. Calidad del codigo.
6. Calidad editorial.

No se debe sacrificar una prioridad superior por una inferior.

## Registro

Toda intervencion importante debe quedar documentada cuando la solicitud lo pida o cuando el flujo del proyecto lo requiera.

Ubicacion oficial de reportes:

```text
agent/reports/
```

Las plantillas oficiales estan en:

```text
agent/templates/
```

## Cierre

El cierre de una tarea debe informar:

- resultado principal;
- archivos creados o modificados;
- validaciones realizadas;
- riesgos o limitaciones pendientes.

La respuesta final debe ser breve, verificable y proporcional al trabajo realizado.
