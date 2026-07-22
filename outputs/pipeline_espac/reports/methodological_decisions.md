# Decisiones metodologicas del pipeline oficial

Fecha: 2026-07-13 11:40:47 -05

## Fuentes oficiales

- Documentacion oficial ESPAC: `docs/espac_2022/manuales/`.
- Sintaxis oficial ESPAC: `docs/espac_2022/sintaxis_txt/`.
- Datos crudos: `data/raw/`.

## Insumo metodologico del investigador

- Archivo de precios: `docs/espac_2022/precios/Precio_Junio_25.xlsx`.
- Este archivo no es documentacion oficial ESPAC.
- Se utiliza como fuente oficial de valoracion economica dentro de la tesis.

## Unidad y llave

- Unidad final: una fila por UPA/cuestionario ESPAC.
- Llave primaria: `Identificador` textual de 17 digitos.
- El pipeline no convierte `Identificador` a numerico.

## Agregacion y uniones

- Cada modulo de detalle se agrega por `Identificador` antes de unirse.
- Las uniones finales son `left_join` uno a uno contra la base maestra.
- Toda union valida unicidad izquierda, unicidad derecha y expansion cero.
- No se permiten uniones muchos-a-muchos.

## Precios

- Para `avena`, se usa siempre el menor precio observado.
- Para productos sin precio, se imputa precio fijo de `0.1 USD/kg`.
- Cada imputacion se registra por modulo, UPA, producto, cantidad, motivo y valor imputado.

## Produccion y productividad

- `produccion_ec` es la suma de las variables `valor_*` construidas por modulo.
- `productividad_superficie = produccion_ec / cg_superficie` cuando `cg_superficie > 0`.
- `productividad_trabajo = produccion_ec / eu_k1301` cuando `eu_k1301 > 0`.
