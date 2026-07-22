# Politica permanente de analisis de causa raiz

Cada problema encontrado por el JRA debe analizarse utilizando un enfoque de causa raiz.

El JRA nunca debe limitarse a describir sintomas. Siempre debe identificar el origen real del problema antes de recomendar una accion.

## Flujo obligatorio

Todo problema debe documentarse siguiendo este flujo:

```text
Problema
|
v
Evidencia
|
v
Origen
|
v
Causa raiz
|
v
Impacto
|
v
Alternativas
|
v
Evaluacion de alternativas
|
v
Recomendacion
|
v
Riesgos
|
v
Prioridad
```

## Definiciones operativas

### Problema

Descripcion precisa de la inconsistencia, error, riesgo o debilidad detectada.

### Evidencia

Datos, archivos, lineas, resultados, documentos o trazas que demuestran o sugieren el problema.

### Origen

Lugar donde surge el problema. Puede estar en datos crudos, documentacion, pipeline, transformacion estadistica, modelo econometrico, codigo R, Quarto, LaTeX, bibliografia, redaccion o interpretacion.

### Causa raiz

Explicacion del mecanismo que produce el problema. No debe confundirse con el sintoma visible.

### Impacto

Consecuencias metodologicas, estadisticas, econometricas, cientificas, editoriales o de reproducibilidad.

### Alternativas

Opciones tecnicas posibles para resolver o mitigar el problema.

### Evaluacion de alternativas

Comparacion de ventajas, desventajas, riesgos y condiciones de aplicacion de cada alternativa.

### Recomendacion

Accion final propuesta, tecnicamente justificada y reproducible.

### Riesgos

Riesgos residuales de la recomendacion y riesgos de no actuar.

### Prioridad

Nivel de urgencia de la accion recomendada, considerando su impacto sobre la tesis.

## Regla de suficiencia

Un hallazgo no esta completo si solo describe que ocurre algo. Debe explicar por que ocurre, donde se origina y cual es la accion mas razonable frente a las alternativas disponibles.

## Regla de incertidumbre

Si no existe evidencia suficiente para identificar la causa raiz, el JRA debe declararlo explicitamente y clasificar el hallazgo como pendiente de investigacion adicional.
