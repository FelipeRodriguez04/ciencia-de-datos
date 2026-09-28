# Laboratorio Integrador I — NYC Yellow Taxi

La ingesta Kestra está en [`kestra/ingesta_yellow_taxi.yml`](kestra/ingesta_yellow_taxi.yml). El proyecto de transformación y pruebas está en [`dbt/`](dbt/README.md). Configura `.env` siguiendo `.env.example`; el archivo `.env` está ignorado por Git.

1. `docker compose up -d`, importa el YAML del flow en `http://localhost:8080` y ejecútalo. El flow crea el warehouse, la base, Bronze y el manifiesto de cargas.
2. `docker compose --profile tools build dbt`.
3. Cuando Kestra termine con estado `SUCCESS`, ejecuta `docker compose --profile tools run --rm dbt build`.
4. Consulta `SILVER.SILVER_YELLOW_TRIPS`, `GOLD.FCT_YELLOW_TRIPS` y `GOLD.QUALITY_BY_MONTH` en la base configurada.

Una segunda ejecución del flow con `force_reload=false` consulta el manifiesto y omite los meses ya completos: no vuelve a descargar ni subir los 19 Parquet. `force_reload=true` reemplaza cada mes dentro de una transacción si se necesita corregir la fuente. El flow procesa hasta dos meses a la vez. El stage interno es temporal y se limpia después de cada mes; Snowflake exige pasar el archivo descargado por un stage para cargarlo con `COPY INTO`.

Para comprobar la carga, ejecuta en Snowflake:

```sql
SELECT COUNT(*) AS meses, SUM(row_count) AS filas
FROM BRONZE.YELLOW_TAXI_LOADS;

SELECT source_period, COUNT(*) AS filas, COUNT(DISTINCT source_row) AS filas_distintas
FROM BRONZE.RAW_YELLOW_TAXI
GROUP BY source_period
ORDER BY source_period;
```

La cuenta de cada mes debe coincidir con `YELLOW_TAXI_LOADS.ROW_COUNT` y con `filas_distintas`. Repetir el flow con `force_reload=false` debe dejar ambas cuentas sin cambios.

Los diagramas están en [`docs/arquitectura.md`](docs/arquitectura.md). Las reglas de limpieza, grano, pruebas y la situación del mes de agosto de 2026 se describen en [`dbt/README.md`](dbt/README.md).
