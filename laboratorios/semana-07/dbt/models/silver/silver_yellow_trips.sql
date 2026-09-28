select
    trip_key, source_file, source_period, source_row, loaded_at,
    file_content_key, execution_id, pickup_at, dropoff_at,
    vendor_id, rate_code_id, payment_type_id,
    pickup_location_id, dropoff_location_id,
    iff(passenger_count_raw between 1 and 8, passenger_count_raw, null) as passenger_count,
    iff(store_and_fwd_raw in ('Y', 'N'), store_and_fwd_raw, 'UNKNOWN') as store_and_fwd_flag,
    trip_distance,
    fare_amount,
    coalesce(extra, 0) as extra,
    coalesce(mta_tax, 0) as mta_tax,
    coalesce(tip_amount, 0) as tip_amount,
    coalesce(tolls_amount, 0) as tolls_amount,
    coalesce(improvement_surcharge, 0) as improvement_surcharge,
    total_amount,
    coalesce(congestion_surcharge, 0) as congestion_surcharge,
    coalesce(airport_fee, 0) as airport_fee,
    coalesce(cbd_congestion_fee, 0) as cbd_congestion_fee,
    datediff('second', pickup_at, dropoff_at) as duration_seconds,
    date_trunc('month', pickup_at)::date <> source_period as period_mismatch,
    datediff('second', pickup_at, dropoff_at) > 86400 as duration_outlier,
    trip_distance = 0 as zero_distance,
    total_amount < 0 or fare_amount < 0 as negative_adjustment,
    abs(total_amount - (fare_amount + coalesce(extra, 0) + coalesce(mta_tax, 0)
        + coalesce(tip_amount, 0) + coalesce(tolls_amount, 0)
        + coalesce(improvement_surcharge, 0) + coalesce(congestion_surcharge, 0)
        + coalesce(airport_fee, 0) + coalesce(cbd_congestion_fee, 0))) > 0.05
        as amount_mismatch
from {{ ref('int_trip_quality') }}
where is_valid and duplicate_rank = 1
