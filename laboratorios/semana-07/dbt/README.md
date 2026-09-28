# dbt — NYC Yellow Taxi

Este proyecto usa como fuente `BRONZE.RAW_YELLOW_TAXI` y `BRONZE.YELLOW_TAXI_LOADS`, creadas por el flow de Kestra de esta misma carpeta. Requiere que la ingesta haya concluido y que el usuario de `.env` tenga permisos para crear objetos en los esquemas `SILVER` y `GOLD`. El rol que creó la base con el flow suele ser propietario y tener esos permisos.

Desde `laboratorios/semana-07`:

```bash
docker compose --profile tools build dbt
docker compose --profile tools run --rm dbt debug
docker compose --profile tools run --rm dbt build
```

`dbt build` carga el catálogo oficial de zonas mediante un seed, materializa modelos y ejecuta las pruebas. Los nombres de proveedor, tarifa y pago están definidos en sus modelos SQL según el diccionario TLC. Repetir el comando reconstruye tablas/vistas sin añadir viajes duplicados. Para ver el grafo y los modelos compilados:

```bash
docker compose --profile tools run --rm dbt ls
docker compose --profile tools run --rm dbt compile
```

## Capas y decisiones

- **Bronze:** `BRONZE_YELLOW_TRIPS` expone las columnas originales de `RAW_YELLOW_TAXI`, incluyendo `PAYLOAD` VARIANT, período, archivo, fila y fecha de carga. No limpia datos.
- **Silver:** `INT_TRIP_TYPED` convierte tipos con `TRY_TO_*` y nombres consistentes. `INT_TRIP_QUALITY` se materializa una vez, marca registros rechazados y asigna rango de duplicado usando SHA-256 del contenido original. `SILVER_YELLOW_TRIPS` conserva solo registros con fechas válidas, recogida entre enero de 2025 y agosto de 2026, llegada posterior a recogida, distancia no negativa y tarifa/total presentes. `SILVER_REJECTED_TRIPS` y `SILVER_DUPLICATE_TRIPS` permiten auditar exclusiones.
- **Gold:** `FCT_YELLOW_TRIPS` tiene grano de **un viaje válido y único**. `TRIP_KEY` es la clave lógica. Dimensiones de fecha, hora, zona de origen y destino, proveedor, tarifa y pago permiten distintas perspectivas. Las claves ajenas desconocidas se asignan a `-1`; las fechas y horas válidas siempre apuntan a sus dimensiones.

Los valores nulos opcionales de componentes monetarios se convierten a cero; no se inventan valores para `FARE_AMOUNT` ni `TOTAL_AMOUNT`. Un número de pasajeros fuera de 1–8 se convierte en NULL, sin descartar el viaje. El indicador de almacenamiento se estandariza a `Y`, `N` o `UNKNOWN`. Distancia cero, duración >24 horas, importe negativo, diferencia entre componentes y total >0.05, y período de recogida distinto al archivo se **marcan**; pueden ser viajes reales, ajustes o errores de origen, por lo que no se eliminan automáticamente. Los registros idénticos según el JSON original se colapsan; sin ID de viaje en TLC no es posible distinguir dos viajes totalmente idénticos, por lo que esta regla puede eliminar un caso legítimo indistinguible. Las métricas monetarias conservan el signo para analizar ajustes.

`QUALITY_BY_MONTH` concilia filas Bronze, rechazos, duplicados y aceptados. Los tests incluyen `not_null`, `unique`, `relationships`, conciliación de Bronze con su manifiesto y conciliación Silver/Gold. En Snowflake, las claves primarias y foráneas de tablas estándar no se aplican automáticamente; estas pruebas dbt las verifican en cada ejecución.

El catálogo `taxi_zones.csv` procede del [lookup oficial TLC](https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv), descargado el 28-09-2026 (SHA-256: `1a99e105092230f8620f301edcca7f80d3080642ff404d28ed957d3fa222c8ed`). Los códigos de proveedor, tarifa y pago siguen el [diccionario Yellow Taxi de TLC](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf).

El flow actual ingiere 19 meses hasta julio de 2026; agosto de 2026 aún no figura en la [página de TLC](https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page) al 28-09-2026. dbt procesa los meses realmente presentes en Bronze. Cuando TLC publique agosto, agrega `"2026-08"` a `vars.periods` del flow, cambia la validación final de 19 a 20 y el límite de fecha a `2026-08-01`, vuelve a importar y ejecutar el flow y repite `dbt build`. Los 19 meses anteriores se omitirán sin volver a transferirlos.
