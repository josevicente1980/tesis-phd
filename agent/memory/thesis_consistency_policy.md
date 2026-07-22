# Politica permanente de coherencia integral de tesis

Ningun capitulo puede revisarse de manera aislada.

Antes de revisar cualquier capitulo, el JRA debe verificar automaticamente la coherencia transversal de la tesis. La revision de un capitulo siempre debe considerar su relacion con el conjunto completo del trabajo doctoral.

## Verificaciones obligatorias

Antes de revisar cualquier capitulo, el JRA debera verificar:

- coherencia con los objetivos de investigacion;
- coherencia con hipotesis;
- coherencia metodologica;
- coherencia entre variables;
- coherencia entre capitulos;
- coherencia entre resultados;
- coherencia entre tablas;
- coherencia entre figuras;
- coherencia entre anexos;
- coherencia bibliografica;
- coherencia entre el pipeline reproducible y los resultados reportados;
- coherencia entre `base_final_v1.0.csv` y todos los analisis.

## Regla de alcance

El JRA nunca debera limitarse unicamente al capitulo solicitado si durante la revision detecta una inconsistencia que afecta otra parte de la tesis.

Si encuentra inconsistencias, debera documentarlas aunque pertenezcan a otro capitulo, anexo, tabla, figura, resultado, base de datos, pipeline, bibliografia o elemento de renderizado.

## Regla de trazabilidad

Toda inconsistencia transversal debe documentarse con:

- elemento revisado;
- elemento relacionado;
- ubicacion de ambos elementos;
- evidencia observada;
- tipo de coherencia afectada;
- impacto sobre el capitulo solicitado;
- impacto sobre la tesis completa;
- accion recomendada;
- nivel de evidencia.

## Regla de base y pipeline oficiales

Toda revision de coherencia debe tomar como referencia:

```text
data/processed/base_final_v1.0.csv
R/pipeline_reproducible/
```

Los resultados reportados en capitulos, tablas, figuras y anexos deben ser coherentes con la base oficial y con el pipeline reproducible oficial.

## Criterio de cierre

Un capitulo no podra considerarse revisado ni certificado si:

- contradice objetivos, hipotesis o metodologia general;
- reporta resultados no coherentes con `base_final_v1.0.csv`;
- contiene tablas o figuras incompatibles con el texto;
- presenta referencias cruzadas inconsistentes;
- depende de un resultado o variable no trazable al pipeline oficial;
- mantiene inconsistencias transversales no justificadas.
