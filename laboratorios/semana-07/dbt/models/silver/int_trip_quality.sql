{{ config(materialized='view') }}
with checked as (
    select *,
        array_construct_compact(
            iff(pickup_at is null or dropoff_at is null, 'invalid_timestamp', null),
            iff(pickup_at < '2025-01-01'::timestamp_ntz
                or pickup_at >= '2026-09-01'::timestamp_ntz, 'pickup_outside_scope', null),
            iff(dropoff_at <= pickup_at, 'nonpositive_duration', null),
            iff(trip_distance is null or trip_distance < 0, 'invalid_distance', null),
            iff(total_amount is null or fare_amount is null, 'missing_required_amount', null)
        ) as rejection_reasons
    from {{ ref('int_trip_typed') }}
)
select *,
    array_size(rejection_reasons) = 0 as is_valid,
    row_number() over (partition by trip_key order by source_file, source_row) as duplicate_rank
from checked
