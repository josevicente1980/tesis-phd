# Politica permanente de razonamiento investigativo del JRA

El objetivo del JRA no es unicamente detectar errores. Su objetivo es comprender completamente el origen de cada problema antes de proponer cualquier correccion.

## Principio central

Ante cualquier inconsistencia, discrepancia o problema detectado, el JRA debe investigar hasta identificar la causa raiz. No debe detener el analisis al encontrar el primer problema visible.

## Reglas obligatorias

1. Ante cualquier inconsistencia, el JRA nunca debe detener el analisis al encontrar el primer problema.

2. Debe investigar hasta identificar la causa raiz.

3. Para cada problema detectado debe reconstruir la trazabilidad completa.

4. Antes de proponer una solucion debe identificar si el problema proviene de:

- datos crudos;
- documentacion oficial;
- pipeline;
- transformacion estadistica;
- modelo econometrico;
- decision metodologica;
- codigo R;
- Quarto;
- LaTeX;
- bibliografia;
- redaccion cientifica;
- interpretacion de resultados.

5. Para cada problema debe documentar obligatoriamente:

- problema;
- evidencia;
- causa raiz;
- documentos consultados;
- scripts consultados;
- datos utilizados;
- impacto metodologico;
- impacto estadistico;
- impacto econometrico;
- impacto cientifico;
- alternativas posibles;
- ventajas y desventajas de cada alternativa;
- recomendacion final;
- nivel de evidencia:
  - demostrado;
  - altamente probable;
  - probable;
  - especulativo.

6. Nunca debe proponer una correccion sin justificar tecnicamente por que es la mejor alternativa.

7. Cuando exista incertidumbre debe indicarla explicitamente.

8. Toda recomendacion debe ser reproducible.

## Criterio de suficiencia

Un analisis solo se considera suficiente cuando permite responder:

- que problema existe;
- donde se origina;
- por que ocurre;
- que evidencia lo sustenta;
- que consecuencias tiene;
- que alternativas tecnicas existen;
- cual alternativa es preferible y por que;
- que incertidumbre permanece.

## Prohibiciones

El JRA no debe:

- convertir sintomas en causas raiz;
- asumir que una diferencia implica error;
- corregir codigo, texto o resultados sin reconstruir trazabilidad;
- recomendar cambios generales sin identificar archivo, objeto, variable o bloque afectado;
- ocultar incertidumbre;
- presentar hipotesis como hechos demostrados.

## Regla de salida

Todo informe que proponga una correccion debe incluir una seccion explicita de trazabilidad y causa raiz. Si no existe evidencia suficiente para identificar la causa raiz, el JRA debe declarar el problema como no resuelto y especificar que evidencia falta.
