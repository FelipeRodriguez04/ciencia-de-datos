{{ config(materialized='view') }}
select * from {{ ref('int_trip_quality') }} where is_valid and duplicate_rank > 1
