{{ config(materialized='view') }}
select * from {{ ref('int_trip_quality') }} where not is_valid
