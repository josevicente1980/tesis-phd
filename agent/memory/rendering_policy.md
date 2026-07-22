# Rendering Policy

Fecha de consolidacion: 2026-07-05

Esta politica es permanente para todo el proceso de renderizado de la tesis doctoral y se aplica automaticamente a todos los capitulos.

## Principio general

Un capitulo nunca puede certificarse unicamente porque compile correctamente. La compilacion sin errores es una condicion necesaria, pero no suficiente.

La certificacion exige, ademas, una revision visual completa del PDF renderizado y la verificacion de estandares editoriales equivalentes a una tesis doctoral de la Universidad de Santiago de Compostela y a un manuscrito publicable en una revista Q1.

## Regla de revision visual obligatoria

Cada render debe someterse a una auditoria visual pagina por pagina del PDF completo. El agente debe revisar, como minimo:

- encabezados
- pies de figura
- pies de tabla
- referencias cruzadas
- numeracion
- tablas
- figuras
- mapas
- ecuaciones
- espacios verticales
- saltos de pagina
- ubicacion de flotantes

No se acepta certificacion sin evidencia de esa revision visual completa.

## Reglas editoriales obligatorias

### 1. Paginacion eficiente

No se permiten paginas con grandes espacios en blanco.

Toda pagina debe aprovechar razonablemente el area imprimible. No deben existir zonas vacias amplias provocadas por flotantes, tablas o figuras. Si aparecen, el render debe corregirse antes de certificar.

### 2. Tablas

Nunca colocar una tabla antes del subtitulo que la introduce.

Toda tabla debe aparecer despues del encabezado y despues del primer parrafo que la menciona.

Nunca separar una tabla de su interpretacion.

La tabla y el texto que la interpreta deben permanecer proximos.

### 3. Figuras

Nunca colocar una figura antes del subtitulo que la introduce.

Toda figura debe aparecer despues del encabezado y despues del texto introductorio correspondiente.

Nunca separar una figura de su explicacion.

La explicacion inmediata debe permanecer junto a la figura. No deben existir paginas donde la figura quede aislada y el analisis aparezca posteriormente.

### 4. Uso de paginas

Se debe minimizar el uso de paginas dedicadas unicamente a una figura.

Si una figura puede compartir pagina con texto, debe preferirse esa opcion.

### 5. Saltos de pagina

Evitar saltos de pagina innecesarios.

No introducir saltos manuales salvo que sean estrictamente imprescindibles para la claridad editorial o para resolver un problema real de composicion.

## Optimizacion de flotantes

El agente puede modificar unicamente parametros de renderizado y composicion tipografica cuando ello mejore la calidad editorial:

- `fig-pos`
- `tbl-pos`
- `out.width`
- `fig.width`
- `fig.height`
- `dpi`
- `hold_position`
- `longtable`
- `scale_down`
- `landscape`
- opciones Quarto
- opciones LaTeX
- parametros de flotantes

Estas modificaciones solo son aceptables si no alteran el contenido cientifico y solo persiguen mejorar la lectura, la proximidad entre elementos y la calidad visual del PDF.

## Prohibiciones

Nunca sacrificar el contenido cientifico para mejorar el diseno.

No se permite:

- insertar texto de relleno
- dividir parrafos artificialmente
- mover resultados cientificos
- alterar tablas
- alterar figuras
- modificar analisis

## Criterio de aceptacion

Un capitulo solo puede certificarse cuando se cumplan simultaneamente estas condiciones:

1. Compila sin errores.
2. No existen paginas con espacios en blanco evitables.
3. Ninguna figura aparece antes del subtitulo que la introduce.
4. Ninguna tabla aparece antes del subtitulo que la introduce.
5. Todas las figuras estan proximas a su explicacion.
6. Todas las tablas estan proximas a su interpretacion.
7. El diseno cumple estandares editoriales equivalentes a una tesis doctoral de la USC y a un manuscrito publicable en una revista Q1.

Si cualquiera de estas condiciones falla, el capitulo no puede certificarse y el render debe corregirse antes de continuar.
