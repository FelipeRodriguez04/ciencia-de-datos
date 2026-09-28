# Laboratorio Integrador I — NYC Yellow Taxi

La ingesta Kestra está en [`kestra/ingesta_yellow_taxi.yml`](kestra/ingesta_yellow_taxi.yml). El proyecto de transformación y pruebas está en [`dbt/`](dbt/README.md). Configura `.env` siguiendo `.env.example`; el archivo `.env` está ignorado por Git.

1. `docker compose up -d` y ejecuta el flow en `http://localhost:8080`.
2. `docker compose --profile tools build dbt`.
3. `docker compose --profile tools run --rm dbt build`.
4. Consulta `SILVER.SILVER_YELLOW_TRIPS`, `GOLD.FCT_YELLOW_TRIPS` y `GOLD.QUALITY_BY_MONTH` en la base configurada.

Los diagramas están en [`docs/arquitectura.md`](docs/arquitectura.md). Las reglas de limpieza, grano, pruebas y la situación del mes de agosto de 2026 se describen en [`dbt/README.md`](dbt/README.md).
